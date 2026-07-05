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
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import 'subtitle_service.dart';
import 'subtitle_parser.dart';
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
  Timer? _sleepTimer;
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
    _sleepTimer?.cancel();
  }

  // ---------- تطبيق إعدادات المشغل ----------
  Future<void> applyPlayerSettings() async {
    final s = settingsProvider;
    final native = player.platform as NativePlayer;

    await applyAudioSettings();

    switch (s.loopMode) {
      case 'video':
        player.setPlaylistMode(PlaylistMode.single);
        break;
      case 'playlist':
        player.setPlaylistMode(PlaylistMode.loop);
        break;
      default:
        player.setPlaylistMode(PlaylistMode.none);
    }

    if (s.rememberSpeed) {
      player.setRate(s.defaultSpeed);
    }

    if (s.pitchCorrection) {
      await native.setProperty('audio-pitch-correction', 'yes');
    } else {
      await native.setProperty('audio-pitch-correction', 'no');
    }

    if (s.preventScreenLock) {
      WakelockPlus.enable();
    }

    if (s.frameDropping) {
      await native.setProperty('framedrop', 'yes');
    } else {
      await native.setProperty('framedrop', 'no');
    }

    if (s.vsync) {
      await native.setProperty('video-sync', 'audio');
    } else {
      await native.setProperty('video-sync', 'display-desync');
    }

    if (s.loggingEnabled) {
      await native.setProperty('msg-level', 'all=v');
    } else {
      await native.setProperty('msg-level', 'all=no');
    }

    _sleepTimer?.cancel();
    if (s.sleepTimerMinutes > 0) {
      _sleepTimer = Timer(Duration(minutes: s.sleepTimerMinutes), () {
        player.pause();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إيقاف التشغيل بواسطة مؤقت النوم')),
          );
        }
      });
    }
  }

  // ---------- تطبيق إعدادات الصوت ----------
  Future<void> applyAudioSettings() async {
    final s = settingsProvider;
    final native = player.platform as NativePlayer;

    // حماية: ألا يقل التضخيم عن 50% (لتجنب كتم الصوت غير المقصود)
    double boost = s.defaultAudioBoost / 100.0;
    if (boost < 0.5) boost = 0.5;

    // حماية: مستوى الصوت الأساسي لا يقل عن 0.05 (لتجنب الصفر)
    double baseVolume = state.volumeLevel;
    if (baseVolume < 0.05) baseVolume = 0.5;

    player.setVolume((baseVolume * boost).clamp(0.0, 200.0));

    await native.setProperty('audio-delay', (s.audioDelayMs / 1000.0).toStringAsFixed(3));

    final List<String> filters = [];

    if (s.audioBalance.abs() > 0.01) {
      final left = (1.0 - s.audioBalance).clamp(0.0, 1.0);
      final right = (1.0 + s.audioBalance).clamp(0.0, 1.0);
      filters.add('pan=stereo|c0=$left*c0|c1=$right*c1');
    }

    if (s.audioOutputMode == 'mono') {
      filters.add('stereotools=mode=mono');
    } else if (s.audioOutputMode == 'surround') {
      filters.add('surround');
    }

    if (s.bassBoost) {
      filters.add('superequalizer=1.2:1.1:1.05:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0:1.0');
    }

    final eq = s.equalizerBands;
    if (eq.any((v) => v.abs() > 0.01)) {
      final gains = eq.map((v) => v.toStringAsFixed(1)).join(':');
      filters.add('firequalizer=gain=$gains');
    }

    if (s.surroundSound) {
      filters.add('surround');
    }

    if (filters.isNotEmpty) {
      final filterString = filters.join(',');
      await native.setProperty('af', filterString);
    } else {
      await native.setProperty('af', '');
    }
  }

  void setRepeatPointA() {
    state.repeatPointA = state.position;
    if (state.repeatPointB != null && state.repeatPointB! <= state.repeatPointA!) {
      state.repeatPointB = null;
    }
    state.notifyListeners();
  }

  void setRepeatPointB() {
    if (state.repeatPointA == null) return;
    if (state.position <= state.repeatPointA!) return;
    state.repeatPointB = state.position;
    state.notifyListeners();
  }

  void clearRepeatPoints() {
    state.clearRepeatPoints();
  }

  void updateZoomPan({double? scale, Offset? offset}) {
    if (scale != null) state.zoomScale = scale.clamp(1.0, 6.0);
    if (offset != null) state.panOffset = offset;
    state.notifyListeners();
  }

  void resetZoomPan() {
    state.resetZoomPan();
  }

  void toggleStatsOverlay() {
    state.showStatsOverlay = !state.showStatsOverlay;
    state.notifyListeners();
  }

  void startLongPressSpeedBoost() {
    if (!settingsProvider.longPressSpeedEnabled || !settingsProvider.longPressSpeed) return;
    if (_preLongPressSpeed != null) return;