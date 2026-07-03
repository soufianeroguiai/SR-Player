// player_control_service.dart (كامل)
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import 'subtitle_service.dart';
import 'smart_enhance_service.dart';
import 'video_info_service.dart';
import '../screens/player/player_state.dart';
import '../screens/player/player_fit_mode.dart';

class PlayerControlService {
  final Player player;
  final PlayerUIState state;
  final VideoItem video;
  final LibraryProvider libraryProvider;
  final SettingsProvider settingsProvider;
  final BuildContext context;
  SharedPreferences? _prefs;
  Timer? _saveTimer;
  Timer? _hideTimer;
  double? _preLongPressSpeed;
  final List<StreamSubscription> _playerSubscriptions = [];

  PlayerControlService({
    required this.player,
    required this.state,
    required this.video,
    required this.libraryProvider,
    required this.settingsProvider,
    required this.context,
  });

  void disposeTimers() {
    _saveTimer?.cancel();
    _hideTimer?.cancel();
  }

  void startLongPressSpeedBoost() {
    if (!settingsProvider.longPressSpeedEnabled) return;
    if (_preLongPressSpeed != null) return;
    _preLongPressSpeed = state.speed;
    player.setRate(settingsProvider.longPressSpeedValue);
    state.isSpeedBoosted = true;
    state.notifyListeners();
  }

  void endLongPressSpeedBoost() {
    if (_preLongPressSpeed == null) return;
    player.setRate(_preLongPressSpeed!);
    _preLongPressSpeed = null;
    state.isSpeedBoosted = false;
    state.notifyListeners();
  }

  void savePositionOnExit() {
    if (settingsProvider.rememberPosition &&
        state.position.inSeconds > 5 &&
        !state.showResumeDialog &&
        (state.duration.inSeconds - state.position.inSeconds) > 5) {
      libraryProvider.savePosition(video.path, state.position);
    }
  }

  Future<void> initSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getDouble('player_volume_level');
    if (saved != null) {
      state.volumeLevel = saved.clamp(0.0, 2.0);
    }
    state.notifyListeners();
  }

  Future<void> savePersistedVolume() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setDouble('player_volume_level', state.volumeLevel);
  }

  Future<void> initPlayer() async {
    try {
      Duration? positionToResume;
      if (settingsProvider.rememberPosition) {
        final saved = await libraryProvider.getPosition(video.path);
        if (saved != null && saved.inSeconds > 5) {
          positionToResume = saved;
          state.savedPosition = saved;
        }
      }

      await player.open(Media(video.path), play: false);
      player.setRate(state.speed);

      final videoInfo = await VideoInfoService.read(player);
      final native = player.platform as NativePlayer;
      final currentHw = await native.getProperty('hwdec-current') ?? 'no';
      state.hdrEnabled = videoInfo.isHDR;
      state.hwEnabled = currentHw != 'no' && currentHw.isNotEmpty;
      state.notifyListeners();

      bool colorApplied = false;
      _playerSubscriptions.add(player.stream.duration.listen((dur) {
        state.duration = dur;
        state.notifyListeners();

        if (!colorApplied && dur.inMilliseconds > 0) {
          colorApplied = true;
          applyInitialDecoderAndColor();
        }

        if (dur.inMilliseconds > 0) {
          extractChapters();
        }

        if (positionToResume != null && dur.inMilliseconds > 0) {
          player.seek(positionToResume!);
          player.play();
          positionToResume = null;
          state.isPlaying = true;

          if (settingsProvider.silentResume) {
            state.showResumeDialog = false;
          } else {
            state.showResumeDialog = true;
            state.showControls = true;
            Future.delayed(const Duration(seconds: 4), () {
              state.showResumeDialog = false;
              state.notifyListeners();
            });
          }
          state.notifyListeners();
          scheduleHide();
        }
      }));

      if (positionToResume == null && settingsProvider.autoPlay) {
        player.play();
      }

      _playerSubscriptions.add(player.stream.position.listen((pos) {
        state.position = pos;
        state.notifyListeners();

        if (settingsProvider.rememberPosition && !state.showResumeDialog) {
          _saveTimer?.cancel();
          _saveTimer = Timer(const Duration(seconds: 3), () {
            if (state.position.inSeconds > 5 &&
                (state.duration.inSeconds - state.position.inSeconds) > 5) {
              libraryProvider.savePosition(video.path, state.position);
            }
          });
        }
      }));

      _playerSubscriptions.add(player.stream.playing.listen((p) {
        state.isPlaying = p;
        state.notifyListeners();
      }));

      _playerSubscriptions.add(player.stream.tracks.listen((tracks) {
        state.subtitleTracks = tracks.subtitle;
        state.audioTracks = _cleanAudioTracks(tracks.audio);
        state.notifyListeners();
        applyPreferredSubtitleLanguage();
        applyPreferredAudioLanguage();
      }));

      _playerSubscriptions.add(player.stream.subtitle.listen((lines) {
        // لازم نمسح النص عند عدم وجود سطر نشط (lines فارغة)، وإلا يبقى آخر
        // نص معروضاً على الشاشة حتى بعد انتهاء الحوار الفعلي في الترجمة.
        state.updateSubtitleText(lines.isNotEmpty ? lines.join('\n') : null);
      }));

      state.initialized = true;
      state.notifyListeners();
      if (!state.showResumeDialog) scheduleHide();
      await loadColorSettings();
      buildPlaylistFromFolder();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تعذر تشغيل الملف: $e')));
        Navigator.pop(context);
      }
    }
  }

  void buildPlaylistFromFolder() {
    final folder = video.folder;
    final allVideos = libraryProvider.allVideos
        .where((v) => v.folder == folder)
        .toList();
    allVideos.sort((a, b) => a.name.compareTo(b.name));
    state.playlistVideos = allVideos;
    state.currentPlaylistIndex = allVideos.indexWhere((v) => v.path == video.path);
    if (state.currentPlaylistIndex == -1) state.currentPlaylistIndex = 0;
    state.notifyListeners();
  }

  Future<void> playNext() async {
    if (state.playlistVideos.isEmpty) return;
    int nextIndex = state.currentPlaylistIndex + 1;
    if (nextIndex >= state.playlistVideos.length) nextIndex = 0;
    await _playVideoAtIndex(nextIndex);
  }

  Future<void> playPrevious() async {
    if (state.playlistVideos.isEmpty) return;
    int prevIndex = state.currentPlaylistIndex - 1;
    if (prevIndex < 0) prevIndex = state.playlistVideos.length - 1;
    await _playVideoAtIndex(prevIndex);
  }

  Future<void> _playVideoAtIndex(int index) async {
    final nextVideo = state.playlistVideos[index];
    if (settingsProvider.rememberPosition && state.position.inSeconds > 5) {
      libraryProvider.savePosition(video.path, state.position);
    }
    await player.open(Media(nextVideo.path), play: true);
    state.currentPlaylistIndex = index;
    state.savedPosition = null;
    state.showResumeDialog = false;
    state.duration = Duration.zero;
    state.position = Duration.zero;
    player.setRate(state.speed);
    applyInitialDecoderAndColor();
    state.notifyListeners();
  }

  List<AudioTrack> _cleanAudioTracks(List<AudioTrack> tracks) {
    final seenIds = <String>{};
    final cleaned = <AudioTrack>[];
    for (final track in tracks) {
      final id = (track.id).toString().toLowerCase();
      if (id == 'auto' || id == 'no') continue;
      if (seenIds.contains(id)) continue;
      seenIds.add(id);
      cleaned.add(track);
    }
    return cleaned;
  }

  Future<void> applyInitialDecoderAndColor() async {
    final native = player.platform as NativePlayer;
    for (int i = 0; i < 20; i++) {
      try {
        final vo = (await native.getProperty('current-vo')).trim();
        if (vo.isNotEmpty) break;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 150));
    }

    switch (settingsProvider.hwDecoderMode) {
      case 'hw':
        await native.setProperty('hwdec', 'mediacodec-copy');
        break;
      case 'sw':
        await native.setProperty('hwdec', 'no');
        break;
      default:
        await native.setProperty('hwdec', 'auto-safe');
    }

    switch (settingsProvider.colorFormat) {
      case 'rgb_full':
        await native.setProperty('video-output-levels', 'full');
        await native.setProperty('target-prim', 'bt.709');
        await native.setProperty('target-trc', 'srgb');
        break;
      case 'rgb_limited':
        await native.setProperty('video-output-levels', 'limited');
        await native.setProperty('target-prim', 'bt.709');
        await native.setProperty('target-trc', 'srgb');
        break;
      default:
        await native.setProperty('video-output-levels', 'auto');
        await native.setProperty('target-prim', 'auto');
        await native.setProperty('target-trc', 'auto');
    }
  }

  void scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: settingsProvider.controlsHideSeconds), () {
      if (state.isPlaying && !state.isLocked &&
          state.currentMenu == ActiveMenu.none && !state.showQuickActions) {
        state.showControls = false;
        state.notifyListeners();
      }
    });
  }

  void applyPreferredSubtitleLanguage() {
    if (state.autoSubtitleSelected || state.subtitleTracks.isEmpty) return;
    for (final track in state.subtitleTracks) {
      if (track.language == settingsProvider.subtitleSettings.autoLanguage) {
        player.setSubtitleTrack(track);
        state.showSubtitles = true;
        state.autoSubtitleSelected = true;
        state.notifyListeners();
        return;
      }
    }
    state.autoSubtitleSelected = true;
  }

  void applyPreferredAudioLanguage() {
    if (state.autoAudioSelected || state.audioTracks.isEmpty) return;
    for (final track in state.audioTracks) {
      if (track.language == settingsProvider.preferredAudioLanguage) {
        player.setAudioTrack(track);
        state.autoAudioSelected = true;
        return;
      }
    }
    state.autoAudioSelected = true;
  }

  void onVolumeChanged(double newLevel) {
    state.volumeLevel = newLevel.clamp(0.0, 2.0);
    player.setVolume(state.volumeLevel * 100.0);
    state.notifyListeners();
    savePersistedVolume();
  }

  void toggleMute() {
    if (state.volumeLevel > 0) {
      state.preMuteVolume = state.volumeLevel;
      onVolumeChanged(0.0);
    } else {
      onVolumeChanged(state.preMuteVolume > 0 ? state.preMuteVolume : 1.0);
    }
  }

  void toggleRepeat() {
    if (state.playlistMode == PlaylistMode.none) {
      state.playlistMode = PlaylistMode.loop;
    } else if (state.playlistMode == PlaylistMode.loop) {
      state.playlistMode = PlaylistMode.single;
    } else {
      state.playlistMode = PlaylistMode.none;
    }
    player.setPlaylistMode(state.playlistMode);
    state.notifyListeners();
  }

  void toggleShuffle() {
    state.isShuffle = !state.isShuffle;
    player.setShuffle(state.isShuffle);
    state.notifyListeners();
  }

  Future<void> toggleSmartEnhance() async {
    if (state.smartEnhance) {
      await SmartEnhanceService.disable(
        player,
        userContrast:   state.contrast,
        userSaturation: state.saturation,
        userBrightness: state.brightness,
        userGamma:      state.gamma,
        userHue:        state.hue,
      );
      state.smartEnhance = false;
      state.notifyListeners();
    } else {
      state.smartEnhance = true;
      state.notifyListeners();
      await SmartEnhanceService.enable(
        player,
        userContrast:   state.contrast,
        userSaturation: state.saturation,
        userBrightness: state.brightness,
        userGamma:      state.gamma,
      );
      if (!SmartEnhanceService.isEnabled) {
        state.smartEnhance = false;
        state.notifyListeners();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Smart Enhance: انتظر بدء التشغيل أولاً')),
          );
        }
      }
    }
  }

  Future<void> toggleHardwareDecoding() async {
    final native = player.platform as NativePlayer;
    final currentHw = await native.getProperty('hwdec-current') ?? 'no';

    if (currentHw == 'no' || currentHw.isEmpty) {
      await native.setProperty('hwdec', 'mediacodec-copy');
    } else {
      await native.setProperty('hwdec', 'no');
    }

    final currentPos = state.position;
    await native.command(['video-reload']);
    await player.seek(currentPos);

    if (state.smartEnhance) {
      SmartEnhanceService.reset();
      await Future.delayed(const Duration(milliseconds: 600));
      await SmartEnhanceService.enable(
        player,
        userContrast:   state.contrast,
        userSaturation: state.saturation,
        userBrightness: state.brightness,
        userGamma:      state.gamma,
      );
    }

    Future.delayed(const Duration(milliseconds: 500), () async {
      final updatedHw = await native.getProperty('hwdec-current') ?? 'no';
      state.hwEnabled = updatedHw != 'no' && updatedHw.isNotEmpty;
      state.notifyListeners();
      if (context.mounted && currentHw == 'no' && updatedHw == 'no') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('عتاد الهاتف لا يدعم فك تشفير هذا التنسيق تلقائياً، تم التحويل للسوفتوير.')),
        );
      }
    });
  }

  Future<void> toggleHDREnhancement() async {
    final native = player.platform as NativePlayer;
    if (state.hdrEnabled) {
      await native.setProperty('contrast', '0');
      await native.setProperty('brightness', '0');
      await native.setProperty('saturation', '0');
      await native.setProperty('gamma', '0');
      try { await native.command(['vf', 'del', '@hdr_vivid']); } catch (_) {}
      state.hdrEnabled = false;
    } else {
      final trc = await native.getProperty('video-params/gamma') ?? '';
      final isTrueHDR = trc.contains('pq') || trc.contains('hlg');
      if (isTrueHDR) {
        await native.setProperty('tone-mapping', 'bt.2446a');
        await native.setProperty('target-prim', 'bt.709');
      } else {
        await native.setProperty('contrast', '18');
        await native.setProperty('saturation', '25');
        await native.setProperty('gamma', '5');
        await native.command(['vf', 'add', '@hdr_vivid:format=gamma=ext-srgb']);
      }
      state.hdrEnabled = true;
    }
    state.notifyListeners();
  }

  void extractChapters() {
    try {
      final native = player.platform as NativePlayer;
      native.getProperty('chapter-list/count').then((countStr) {
        final count = int.tryParse(countStr ?? '0') ?? 0;
        if (count == 0) return;
        final futures = List.generate(count, (i) async {
          final title = await native.getProperty('chapter-list/$i/title') ?? 'Chapter ${i + 1}';
          final timeStr = await native.getProperty('chapter-list/$i/time') ?? '0';
          final seconds = double.tryParse(timeStr) ?? 0.0;
          return (
            title: title,
            start: Duration(milliseconds: (seconds * 1000).round()),
          );
        });
        Future.wait(futures).then((chapters) {
          chapters.sort((a, b) => a.start.compareTo(b.start));
          state.chapters = chapters;
          state.notifyListeners();
        });
      });
    } catch (_) {}
  }

  Future<void> loadColorSettings() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    state.brightness = p.getDouble('color_brightness') ?? 0;
    state.contrast   = p.getDouble('color_contrast')   ?? 0;
    state.saturation = p.getDouble('color_saturation') ?? 0;
    state.hue        = p.getDouble('color_hue')        ?? 0;
    state.gamma      = p.getDouble('color_gamma')      ?? 0;
    applyAllColorSettings();
    state.notifyListeners();
  }

  void applyAllColorSettings() {
    final native = player.platform as NativePlayer;
    native.setProperty('brightness', state.brightness.toString());
    native.setProperty('contrast', state.contrast.toString());
    native.setProperty('saturation', state.saturation.toString());
    native.setProperty('hue', state.hue.toString());
    native.setProperty('gamma', state.gamma.toString());
  }

  Future<void> saveColorSetting(String key, double value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    await p.setDouble(key, value);
  }

  void applyColorSetting(String property, double value) {
    final native = player.platform as NativePlayer;
    native.setProperty(property, value.toString());
    saveColorSetting('color_$property', value);
  }

  Future<void> resetColorSettings() async {
    state.brightness = 0;
    state.contrast = 0;
    state.saturation = 0;
    state.hue = 0;
    state.gamma = 0;
    applyAllColorSettings();
    final p = _prefs ?? await SharedPreferences.getInstance();
    p.setDouble('color_brightness', 0);
    p.setDouble('color_contrast', 0);
    p.setDouble('color_saturation', 0);
    p.setDouble('color_hue', 0);
    p.setDouble('color_gamma', 0);
    state.notifyListeners();
  }

  Future<void> captureScreenshot() async {
    state.showScreenshotFlash = true;
    state.notifyListeners();
    Future.delayed(const Duration(milliseconds: 150), () {
      state.showScreenshotFlash = false;
      state.notifyListeners();
    });

    final Uint8List? bytes = await player.screenshot(format: 'image/jpeg');
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final tmpFile = File('${dir.path}/sr_screenshot_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tmpFile.writeAsBytes(bytes);

    final result = await PhotoManager.editor.saveImageWithPath(
      tmpFile.path,
      title: 'SR_${video.name}_${DateTime.now().millisecondsSinceEpoch}',
    );
    try { await tmpFile.delete(); } catch (_) {}

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result != null ? '✅ تم حفظ اللقطة في معرض الصور' : 'فشل الحفظ في المعرض'),
      ));
    }
  }

  void toggleFavorite() {
    libraryProvider.toggleFavorite(video.path);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(libraryProvider.isFavorite(video.path)
            ? 'تمت إضافة للمفضلة'
            : 'تمت إزالة من المفضلة')));
    }
  }

  Future<void> addToPlaylist() async {
    final added = await libraryProvider.addToPlaylist(video.path);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(added ? 'تمت الإضافة إلى قائمة التشغيل' : 'الملف موجود مسبقاً في القائمة')));
    }
  }

  void shareVideo() =>
      Share.shareXFiles([XFile(video.path)], subject: video.name);

  void setSpeed(double sp) {
    state.speed = sp;
    player.setRate(sp);
    settingsProvider.setDefaultSpeed(sp);
    state.notifyListeners();
  }

  void dispose() {
    _saveTimer?.cancel();
    _hideTimer?.cancel();
    for (final sub in _playerSubscriptions) {
      sub.cancel();
    }
    _playerSubscriptions.clear();
  }
}