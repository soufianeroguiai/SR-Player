import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import '../services/subtitle_service.dart';
import '../services/pip_service.dart';
import 'info_screen.dart';
import 'player_audio_boost.dart';
import 'player_indicators.dart';
import 'player_gestures.dart';
import 'player_controls.dart';
import 'player_subtitle_settings.dart';

enum VideoFitMode { contain, cover, fill }

// تعريف حالة القائمة الجانبية
enum ActiveMenu { none, subtitles, audio }

BoxFit getBoxFit(VideoFitMode mode) {
  switch (mode) {
    case VideoFitMode.contain: return BoxFit.contain;
    case VideoFitMode.cover:   return BoxFit.cover;
    case VideoFitMode.fill:    return BoxFit.fill;
  }
}

String modeName(VideoFitMode mode) {
  switch (mode) {
    case VideoFitMode.contain: return 'Fit';
    case VideoFitMode.cover:   return 'Crop';
    case VideoFitMode.fill:    return 'Stretch';
  }
}

class VideoFitSettings {
  static const _key = 'video_fit_mode';
  static Future<void> save(VideoFitMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }
  static Future<VideoFitMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    return VideoFitMode.values[index];
  }
}

class PlayerScreen extends StatefulWidget {
  final VideoItem video;
  const PlayerScreen({super.key, required this.video});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with WidgetsBindingObserver, PlayerGestures {
  late final Player _player;
  late final VideoController _controller;

  // متغير للتحكم في النافذة الجانبية
  ActiveMenu _currentMenu = ActiveMenu.none;

  // متغيرات التكبير والتصغير (Pinch-to-Zoom)
  double _videoScale = 1.0;
  double _baseVideoScale = 1.0;
  Offset _videoOffset = Offset.zero;
  Offset _baseVideoOffset = Offset.zero;

  bool _initialized = false;
  bool _showControls = true;
  bool _isPip = false;
  bool _isLocked = false;
  Timer? _hideTimer;
  Timer? _saveTimer;

  bool _showSubtitles = true;
  List<SubtitleTrack> _subtitleTracks = [];
  List<AudioTrack> _audioTracks = [];

  double _audioBoost = 100.0;
  double _speed = 1.0;
  final _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  bool _isLandscape = true;
  VideoFitMode _fitMode = VideoFitMode.contain;
  String? _fitOverlayText;
  Timer? _fitOverlayTimer;

  double _subtitleSync = 0.0;
  double _subtitleSpeed = 1.0;
  bool _autoSubtitleSelected = false;

  final ValueNotifier<double> _volumeNotifier = ValueNotifier(0.8);
  final ValueNotifier<double> _brightnessNotifier = ValueNotifier(0.7);
  final ValueNotifier<double> _seekMsNotifier = ValueNotifier(0.0);

  final ValueNotifier<bool> _showVolNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showBrightNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _showSeekNotifier = ValueNotifier(false);

  double get _effectiveVolume =>
      (_volumeNotifier.value * _audioBoost).clamp(0, 200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();

    getPlayer = () => _player;
    volumeNotifier = _volumeNotifier;
    brightnessNotifier = _brightnessNotifier;
    seekMsNotifier = _seekMsNotifier;
    showVolNotifier = _showVolNotifier;
    showBrightNotifier = _showBrightNotifier;
    showSeekNotifier = _showSeekNotifier;
    isLocked = () => _isLocked;
    getAudioBoost = () => _audioBoost;
    getDuration = () => _duration;
    getPosition = () => _position;
    scheduleHide = _scheduleHide;
    cancelHideTimer = () { _hideTimer?.cancel(); };
    getContext = () => context;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orientation = MediaQuery.of(context).orientation;
        setState(() => _isLandscape = orientation == Orientation.landscape);
      }
    });

    _enterFullscreen();

    final settings = context.read<SettingsProvider>();
    _showSubtitles = settings.showSubtitlesByDefault;
    _speed = settings.defaultSpeed;
    _audioBoost = settings.defaultAudioBoost.clamp(50.0, 200.0);
    _subtitleSync = settings.defaultSubtitleSync;

    _loadPersistedVolumeAndBrightness();

    _player = Player();
    _controller = VideoController(_player);

    _initPlayer();
    _loadFitMode();
  }

  Future<void> _loadPersistedVolumeAndBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    final vol = prefs.getDouble('player_volume') ?? 0.8;
    final bright = prefs.getDouble('player_brightness') ?? 0.7;
    _volumeNotifier.value = vol.clamp(0.0, 1.0);
    _brightnessNotifier.value = bright.clamp(0.1, 1.0);
  }

  Future<void> _loadFitMode() async {
    _fitMode = await VideoFitSettings.load();
    if (mounted) setState(() {});
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setOrientations();
  }

  void _setOrientations() {
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    _setOrientations();
  }

  void _toggleLock() {
    setState(() {
      _isLocked = !_isLocked;
      if (_isLocked) {
        _showControls = false;
        _currentMenu = ActiveMenu.none;
      }
    });
  }

  void _toggleFit() {
    setState(() {
      _fitMode = VideoFitMode.values[(_fitMode.index + 1) % VideoFitMode.values.length];
      _showFitOverlay();
    });
    VideoFitSettings.save(_fitMode);
  }

  void _showFitOverlay() {
    _fitOverlayText = modeName(_fitMode);
    _fitOverlayTimer?.cancel();
    _fitOverlayTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _fitOverlayText = null);
    });
  }

  Future<void> _initPlayer() async {
    final settings = context.read<SettingsProvider>();
    try {
      await _player.open(Media(widget.video.path), play: settings.autoPlay);
      _player.setRate(_speed);
      _player.setVolume(_effectiveVolume);

      if (settings.rememberPosition) {
        try {
          final saved = await context.read<LibraryProvider>().getPosition(widget.video.path);
          if (saved != null && saved.inSeconds > 0) await _player.seek(saved);
        } catch (_) {}
      }

      _player.stream.position.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);
        if (settings.rememberPosition) {
          _saveTimer?.cancel();
          _saveTimer = Timer(const Duration(seconds: 5), () {
            if (mounted) context.read<LibraryProvider>().savePosition(widget.video.path, _position);
          });
        }
      });

      _player.stream.duration.listen((dur) {
        if (mounted) setState(() => _duration = dur);
      });

      _player.stream.playing.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });

      _player.stream.tracks.listen((tracks) {
        if (!mounted) return;
        setState(() {
          _subtitleTracks = tracks.subtitle;
          _audioTracks = tracks.audio;
        });
        _applyPreferredSubtitleLanguage(settings);
      });

      try {
        _brightnessNotifier.value = await ScreenBrightness.instance.application;
        if (_brightnessNotifier.value < 0.1) _brightnessNotifier.value = 0.1;
        await ScreenBrightness.instance.setApplicationScreenBrightness(_brightnessNotifier.value);
      } catch (_) {
        _brightnessNotifier.value = 0.7;
      }

      setState(() => _initialized = true);
      _scheduleHide();

      await _loadSubtitleFromPreferredFolder(settings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تشغيل الملف: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadSubtitleFromPreferredFolder(SettingsProvider s) async {
    if (s.subtitleFolder.isEmpty) {
      final srtPath = SubtitleService.findSrt(widget.video.path);
      if (srtPath != null) await _loadSrtFile(srtPath, s.subtitleEncoding);
      return;
    }

    final videoName = widget.video.path.split('/').last.replaceAll(RegExp(r'\.[^.]+$'), '');
    final folder = Directory(s.subtitleFolder);
    if (await folder.exists()) {
      final matchedFiles = <File>[];
      await for (final file in folder.list()) {
        if (file is File) {
          final fileName = file.path.split('/').last;
          if (fileName.startsWith(videoName) &&
              (fileName.endsWith('.srt') || fileName.endsWith('.SRT') ||
               fileName.endsWith('.ssa') || fileName.endsWith('.ass'))) {
            matchedFiles.add(file);
          }
        }
      }

      if (matchedFiles.length == 1) {
        await _loadSrtFile(matchedFiles.first.path, s.subtitleEncoding);
        return;
      } else if (matchedFiles.length > 1) {
        final chosen = await showDialog<File>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('اختر ملف الترجمة'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: matchedFiles.map((f) => ListTile(
                  title: Text(f.path.split('/').last),
                  onTap: () => Navigator.pop(ctx, f),
                )).toList(),
              ),
            ),
          ),
        );
        if (chosen != null) {
          await _loadSrtFile(chosen.path, s.subtitleEncoding);
          return;
        }
      }
    }

    final srtPath = SubtitleService.findSrt(widget.video.path);
    if (srtPath != null) await _loadSrtFile(srtPath, s.subtitleEncoding);
  }

  void _applyPreferredSubtitleLanguage(SettingsProvider s) {
    if (_autoSubtitleSelected || _subtitleTracks.isEmpty) return;
    for (final track in _subtitleTracks) {
      if (track.language == s.preferredSubtitleLanguage) {
        _player.setSubtitleTrack(track);
        setState(() => _showSubtitles = true);
        _autoSubtitleSelected = true;
        return;
      }
    }
    _autoSubtitleSelected = true;
  }

  Future<void> _loadSrtFile(String path, [String encoding = 'UTF-8']) async {
    try {
      await _player.setSubtitleTrack(SubtitleTrack.no());
      final entries = await SubtitleService.load(path);
      if (entries.isEmpty) return;

      final srtContent = StringBuffer();
      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        srtContent.writeln('${i + 1}');
        srtContent.writeln('${_formatSrtTime(e.start)} --> ${_formatSrtTime(e.end)}');
        srtContent.writeln(e.text);
        srtContent.writeln();
      }

      await _player.setSubtitleTrack(
        SubtitleTrack.data(srtContent.toString(), title: 'ترجمة خارجية'),
      );

      if (mounted) {
        setState(() => _showSubtitles = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم تحميل الترجمة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تحميل الترجمة: $e')),
        );
      }
    }
  }

  String _formatSrtTime(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000)).toString().padLeft(3, '0');
    return '$h:$m:$s,$ms';
  }

  Future<void> _pickSubtitle() async {
    final result = await FilePicker.pickFiles(
        type: FileType.custom, allowedExtensions: ['srt', 'SRT', 'ssa', 'ass']);
    if (result?.files.single.path != null) {
      final settings = context.read<SettingsProvider>();
      await _loadSrtFile(result!.files.single.path!, settings.subtitleEncoding);
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !_isLocked && _currentMenu == ActiveMenu.none) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_isLocked) return;
    
    if (_currentMenu != ActiveMenu.none) {
      setState(() => _currentMenu = ActiveMenu.none);
      _scheduleHide();
      return;
    }
    
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  Future<void> _enterPip() async {
    try { await PipService.enter(); } catch (_) {}
  }

  FontWeight _getFontWeight(int index) {
    switch (index) {
      case 0: return FontWeight.w300;
      case 1: return FontWeight.normal;
      case 2: return FontWeight.w500;
      case 3: return FontWeight.bold;
      default: return FontWeight.normal;
    }
  }

  // ─── دوال بناء النافذة الجانبية ───

  Widget _buildAudioPanelContent() {
    final cs = Theme.of(context).colorScheme;
    final seen = <String>{};
    final uniqueAudio = <AudioTrack>[];
    for (final t in _audioTracks) {
      final k = t.title ?? t.language ?? 'unknown';
      if (!seen.contains(k)) { seen.add(k); uniqueAudio.add(t); }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (uniqueAudio.isNotEmpty) ...[
          const Text('المسارات الصوتية', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...uniqueAudio.map((track) {
            final name = track.title ?? track.language ?? 'مسار صوتي';
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(name, style: const TextStyle(color: Colors.white)),
              subtitle: track.language != null ? Text(track.language!, style: const TextStyle(color: Colors.white54)) : null,
              trailing: _player.state.track.audio == track ? Icon(Icons.check, color: cs.primary) : null,
              onTap: () => setState(() => _player.setAudioTrack(track)),
            );
          }),
          const Divider(color: Colors.white24, height: 32),
        ],
        AudioBoostSection(
          boost: _audioBoost,
          onChanged: (v) {
            setState(() => _audioBoost = v);
            _player.setVolume(_effectiveVolume);
          },
        ),
      ],
    );
  }

  Widget _buildSubtitlePanelContent() {
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();
    final seen = <String>{};
    final uniqueTracks = <SubtitleTrack>[];
    for (final t in _subtitleTracks) {
      final k = t.title ?? t.language ?? 'unknown';
      if (!seen.contains(k)) { seen.add(k); uniqueTracks.add(t); }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        SwitchListTile(
          dense: true,
          activeColor: Colors.lightBlue,
          title: Text(_showSubtitles ? 'إيقاف الترجمة' : 'تشغيل الترجمة', style: const TextStyle(color: Colors.white)),
          value: _showSubtitles,
          onChanged: (v) {
            setState(() => _showSubtitles = v);
            if (!v) _player.setSubtitleTrack(SubtitleTrack.no());
          },
        ),
        if (uniqueTracks.isNotEmpty) ...[
          const Divider(color: Colors.white24),
          ...uniqueTracks.map((track) {
            final name = track.title ?? track.language ?? 'ترجمة';
            return ListTile(
              dense: true,
              title: Text(name, style: const TextStyle(color: Colors.white)),
              subtitle: track.language != null ? Text(track.language!, style: const TextStyle(color: Colors.white54)) : null,
              trailing: _player.state.track.subtitle == track ? Icon(Icons.check, color: cs.primary) : null,
              onTap: () {
                _player.setSubtitleTrack(track);
                setState(() => _showSubtitles = true);
              },
            );
          }),
        ],
        const Divider(color: Colors.white24),
        ListTile(
          dense: true,
          leading: const Icon(Icons.upload_file, color: Colors.white70),
          title: const Text('تحميل ترجمة من ملف', style: TextStyle(color: Colors.white)),
          onTap: () {
            _pickSubtitle();
            setState(() => _currentMenu = ActiveMenu.none);
          },
        ),
        const Divider(color: Colors.white24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('المزامنة والسرعة', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        ListTile(
          dense: true,
          title: const Text('مزامنة الترجمة', style: TextStyle(color: Colors.white)),
          subtitle: Slider(
            value: _subtitleSync, min: -5.0, max: 5.0, divisions: 100,
            label: '${_subtitleSync.toStringAsFixed(1)}s',
            onChanged: (v) {
              setState(() => _subtitleSync = v);
              settings.setDefaultSubtitleSync(v);
            },
            activeColor: cs.primary,
          ),
        ),
        ListTile(
          dense: true,
          title: const Text('سرعة الترجمة', style: TextStyle(color: Colors.white)),
          subtitle: Slider(
            value: _subtitleSpeed, min: 0.5, max: 2.0, divisions: 15,
            label: '${_subtitleSpeed}x',
            onChanged: (v) => setState(() => _subtitleSpeed = v),
            activeColor: cs.primary,
          ),
        ),
        const Divider(color: Colors.white24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('المظهر', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
        buildSubtitleSettingsContent(context),
      ],
    );
  }

  Widget _buildSidePanel() {
    final double panelWidth = 320.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      right: _currentMenu != ActiveMenu.none ? 0 : -panelWidth,
      width: panelWidth,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          border: const Border(left: BorderSide(color: Colors.white24, width: 1)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentMenu == ActiveMenu.subtitles ? 'إعدادات الترجمة' : 'إعدادات الصوت',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Symbols.close_rounded, color: Colors.white70),
                      onPressed: () {
                        setState(() => _currentMenu = ActiveMenu.none);
                        _scheduleHide();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: _currentMenu == ActiveMenu.subtitles
                    ? _buildSubtitlePanelContent()
                    : _currentMenu == ActiveMenu.audio
                        ? _buildAudioPanelContent()
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final s = context.watch<SettingsProvider>();

    if (_isPip) {
      return Scaffold(
          backgroundColor: Colors.black, body: Video(controller: _controller));
    }

    return PopScope(
      canPop: !_isLocked,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (_currentMenu != ActiveMenu.none) {
            setState(() => _currentMenu = ActiveMenu.none);
            return;
          }
          if (!_isLocked) await _enterPip();
        }
        if (_isLocked) setState(() => _isLocked = false);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: !_initialized
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : Stack(children: [
                
                // ─── نظام الإيماءات المدمج والمحدث (Gestures) ───
                GestureDetector(
                  onTap: _toggleControls,
                  onDoubleTapDown: _isLocked
                      ? null
                      : (details) {
                          if (_videoScale > 1.0) {
                            setState(() {
                              _videoScale = 1.0;
                              _videoOffset = Offset.zero;
                            });
                            return;
                          }
                          final isRight = details.localPosition.dx > screenWidth / 2;
                          final target = isRight
                              ? (_position + const Duration(seconds: 10))
                              : (_position - const Duration(seconds: 10));
                          _player.seek(target.isNegative
                              ? Duration.zero
                              : (target > _duration ? _duration : target));
                        },
                  onScaleStart: (details) {
                    if (_isLocked) return;
                    if (details.pointerCount == 2) {
                      _baseVideoScale = _videoScale;
                      _baseVideoOffset = _videoOffset;
                    } else {
                      onPanDown(DragDownDetails(
                        globalPosition: details.focalPoint,
                        localPosition: details.localFocalPoint,
                      ));
                    }
                  },
                  onScaleUpdate: (details) {
                    if (_isLocked) return;
                    
                    if (details.pointerCount == 2) {
                      setState(() {
                        _videoScale = (_baseVideoScale * details.scale).clamp(1.0, 5.0);
                        if (_videoScale > 1.0) {
                          _videoOffset = _baseVideoOffset + details.focalPointDelta;
                        } else {
                          _videoOffset = Offset.zero;
                        }
                      });
                    } else if (details.pointerCount == 1) {
                      final screenHeight = MediaQuery.of(context).size.height;
                      
                      final isBottom = details.localFocalPoint.dy > screenHeight * 0.7;
                      final isCenter = details.localFocalPoint.dx > screenWidth * 0.25 && details.localFocalPoint.dx < screenWidth * 0.75;
                      final isVerticalDrag = details.focalPointDelta.dy.abs() > details.focalPointDelta.dx.abs();

                      // التحكم في رفع وتنزيل الترجمة
                      if (isBottom && isCenter && isVerticalDrag) {
                        double newPadding = s.bottomPadding - details.focalPointDelta.dy;
                        s.setBottomPadding(newPadding.clamp(0.0, screenHeight / 1.5)); 
                      } else {
                        // التحكم في الصوت أو الإضاءة
                        onPanUpdate(
                          DragUpdateDetails(
                            globalPosition: details.focalPoint,
                            localPosition: details.localFocalPoint,
                            delta: details.focalPointDelta,
                            primaryDelta: details.focalPointDelta.dy,
                          ),
                          screenWidth,
                        );
                      }
                    }
                  },
                  onScaleEnd: (details) {
                    if (_isLocked) return;
                    if (_videoScale < 1.0) {
                      setState(() {
                        _videoScale = 1.0;
                        _videoOffset = Offset.zero;
                      });
                    }
                    onPanEnd(DragEndDetails(velocity: details.velocity));
                  },
                  child: ClipRect(
                    child: Transform.translate(
                      offset: _videoOffset,
                      child: Transform.scale(
                        scale: _videoScale,
                        child: Video(
                          controller: _controller,
                          fit: getBoxFit(_fitMode),
                          controls: NoVideoControls,
                          subtitleViewConfiguration: SubtitleViewConfiguration(
                            style: TextStyle(
                              fontSize: s.subtitleFontSize,
                              color: s.subtitleColor,
                              fontWeight: _getFontWeight(s.fontWeightIndex),
                              fontFamily: s.fontFamily,
                              fontStyle: s.subtitleItalic ? FontStyle.italic : FontStyle.normal,
                              backgroundColor: s.subtitleBgColor.withOpacity(s.subtitleBgOpacity),
                              shadows: s.textShadowEnabled
                                  ? [Shadow(color: s.textShadowColor, blurRadius: s.textShadowBlurRadius,
                                      offset: Offset(s.textShadowOffsetX, s.textShadowOffsetY))]
                                  : null,
                            ),
                            textAlign: s.subtitleRTL ? TextAlign.right : TextAlign.center,
                            padding: EdgeInsets.fromLTRB(s.horizontalMargin, 0, s.horizontalMargin, s.bottomPadding),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                ValueListenableBuilder<bool>(
                  valueListenable: _showSeekNotifier,
                  builder: (context, show, child) {
                    if (!show) return const SizedBox.shrink();
                    return ValueListenableBuilder<double>(
                      valueListenable: _seekMsNotifier,
                      builder: (context, seekMs, child) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Symbols.fast_forward_rounded, color: Colors.white, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                _fmt(Duration(milliseconds: seekMs.toInt())),
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showVolNotifier,
                  builder: (context, show, child) {
                    if (!show) return const SizedBox.shrink();
                    return ValueListenableBuilder<double>(
                      valueListenable: _volumeNotifier,
                      builder: (context, volume, child) {
                        return Positioned(
                          left: 24,
                          top: MediaQuery.of(context).size.height * 0.25,
                          child: PlayerIndicators.buildFloatingIndicator(
                            icon: volume == 0 ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            displayValue: volume,
                            labelText: '${(volume * _audioBoost).round()}%',
                            color: cs.primary,
                          ),
                        );
                      },
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showBrightNotifier,
                  builder: (context, show, child) {
                    if (!show) return const SizedBox.shrink();
                    return ValueListenableBuilder<double>(
                      valueListenable: _brightnessNotifier,
                      builder: (context, brightness, child) {
                        return Positioned(
                          right: 24,
                          top: MediaQuery.of(context).size.height * 0.25,
                          child: PlayerIndicators.buildFloatingIndicator(
                            icon: brightness < 0.15 ? Icons.brightness_low_rounded : Icons.brightness_6_rounded,
                            displayValue: brightness,
                            labelText: '${(brightness * 100).round()}%',
                            color: cs.secondary,
                          ),
                        );
                      },
                    );
                  },
                ),
                if (_fitOverlayText != null)
                  Positioned(top: 100, left: 0, right: 0,
                    child: Center(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
                      child: Text(_fitOverlayText!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ))),
                if (_isLocked)
                  Positioned(top: 16, right: 16,
                    child: SafeArea(child: GestureDetector(
                      onTap: _toggleLock,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.85), shape: BoxShape.circle),
                        child: const Icon(Symbols.lock_rounded, color: Colors.white, size: 22),
                      ),
                    ))),
                
                // ── شريط التحكم ──
                if (_showControls && !_isLocked) ...[
                  Positioned(top: 0, left: 0, right: 0,
                    child: PlayerTopBar(
                      videoName: widget.video.name,
                      onBack: () => Navigator.pop(context),
                      onToggleFit: _toggleFit,
                      onToggleOrientation: _toggleOrientation,
                      onPip: _enterPip,
                      onAudioMenu: () {
                        setState(() {
                          _currentMenu = _currentMenu == ActiveMenu.audio ? ActiveMenu.none : ActiveMenu.audio;
                          if (_currentMenu != ActiveMenu.none) cancelHideTimer(); else _scheduleHide();
                        });
                      },
                      onSubtitleMenu: () {
                        setState(() {
                          _currentMenu = _currentMenu == ActiveMenu.subtitles ? ActiveMenu.none : ActiveMenu.subtitles;
                          if (_currentMenu != ActiveMenu.none) cancelHideTimer(); else _scheduleHide();
                        });
                      },
                      isLandscape: _isLandscape,
                      showSubtitles: _showSubtitles,
                    )),
                  Positioned(bottom: 0, left: 0, right: 0,
                    child: PlayerBottomBar(
                      position: _position,
                      duration: _duration,
                      onSeek: (v) => _player.seek(Duration(milliseconds: (v * _duration.inMilliseconds).toInt())),
                      primaryColor: cs.primary,
                    )),
                  Center(child: PlayerCenterButtons(
                    isPlaying: _isPlaying,
                    onPlayPause: () => _isPlaying ? _player.pause() : _player.play(),
                    onSkipBack: () {
                      final target = _position - const Duration(seconds: 10);
                      _player.seek(target.isNegative ? Duration.zero : target);
                    },
                    onSkipForward: () {
                      final target = _position + const Duration(seconds: 10);
                      _player.seek(target > _duration ? _duration : target);
                    },
                    primaryColor: cs.primaryContainer,
                    onPrimaryContainer: cs.onPrimaryContainer,
                  )),
                ],

                // ── النافذة الجانبية ──
                _buildSidePanel(),
              ]),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _volumeNotifier.dispose();
    _brightnessNotifier.dispose();
    _seekMsNotifier.dispose();
    _showVolNotifier.dispose();
    _showBrightNotifier.dispose();
    _showSeekNotifier.dispose();
    _hideTimer?.cancel();
    _saveTimer?.cancel();
    _fitOverlayTimer?.cancel();
    disposeGestures();
    try { ScreenBrightness.instance.resetApplicationScreenBrightness(); } catch (_) {}
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _player.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
