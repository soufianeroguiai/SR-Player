import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import '../services/subtitle_service.dart';
import '../services/pip_service.dart';

class PlayerScreen extends StatefulWidget {
  final VideoItem video;
  const PlayerScreen({super.key, required this.video});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  late final Player _player;
  late final VideoController _controller;

  bool _initialized = false;
  bool _showControls = true;
  bool _isPip = false;
  bool _isLocked = false;
  Timer? _hideTimer;

  bool _showSubtitles = true;
  List<SubtitleTrack> _subtitleTracks = [];
  List<AudioTrack> _audioTracks = [];
  double _audioBoost = 100.0;

  double _speed = 1.0;
  final _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  double _volume = 0.8;
  double _brightness = 0.7;

  String? _dragAxis;
  bool _dragIsLeftSide = false;
  Offset _dragStartGlobal = Offset.zero;
  Duration _dragStartPosition = Duration.zero;
  Duration _seekPreview = Duration.zero;
  bool _showSeekIndicator = false;

  bool _showBrightnessIndicator = false;
  bool _showVolumeIndicator = false;
  Timer? _indicatorTimer;

  bool _isLandscape = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _enterFullscreen();
    _player = Player();
    _controller = VideoController(_player);
    _initPlayer();
  }

  // --- دوال المساعدة للترجمة ---
  FontWeight _getFontWeight(int index) {
    switch (index) {
      case 0: return FontWeight.w300;
      case 1: return FontWeight.normal;
      case 2: return FontWeight.w500;
      case 3: return FontWeight.bold;
      default: return FontWeight.normal;
    }
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0: return Alignment.topCenter;
      case 1: return Alignment.center;
      default: return Alignment.bottomCenter;
    }
  }

  // --- نافذة إعدادات الترجمة ---
  void _showSubtitleSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final s = context.watch<SettingsProvider>();
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Center(child: Text('إعدادات الترجمة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                const Divider(color: Colors.white24),
                
                ExpansionTile(
                  title: const Text('النص والخط', style: TextStyle(color: Colors.white)),
                  children: [
                    ListTile(title: const Text('حجم الخط', style: TextStyle(color: Colors.white)), subtitle: Slider(value: s.subtitleFontSize, min: 10, max: 50, onChanged: (v) => s.setSubtitleFontSize(v))),
                    ListTile(
                      title: const Text('وزن الخط', style: TextStyle(color: Colors.white)),
                      trailing: DropdownButton(
                        dropdownColor: Colors.black,
                        value: s.fontWeightIndex,
                        items: const [DropdownMenuItem(value: 0, child: Text('Light', style: TextStyle(color: Colors.white))), DropdownMenuItem(value: 1, child: Text('Regular', style: TextStyle(color: Colors.white))), DropdownMenuItem(value: 2, child: Text('Medium', style: TextStyle(color: Colors.white))), DropdownMenuItem(value: 3, child: Text('Bold', style: TextStyle(color: Colors.white)))],
                        onChanged: (v) => s.setFontWeightIndex(v!),
                      ),
                    ),
                  ],
                ),

                ExpansionTile(
                  title: const Text('الألوان', style: TextStyle(color: Colors.white)),
                  children: [
                    ListTile(title: const Text('شفافية الخلفية', style: TextStyle(color: Colors.white)), subtitle: Slider(value: s.subtitleBgOpacity, min: 0, max: 1, onChanged: (v) => s.setSubtitleBgOpacity(v))),
                    ListTile(title: const Text('سماكة الحدود', style: TextStyle(color: Colors.white)), subtitle: Slider(value: s.outlineWidth, min: 0, max: 5, onChanged: (v) => s.setOutlineWidth(v))),
                  ],
                ),

                ExpansionTile(
                  title: const Text('الظلال', style: TextStyle(color: Colors.white)),
                  children: [
                    SwitchListTile(title: const Text('تفعيل الظل', style: TextStyle(color: Colors.white)), value: s.shadowEnabled, onChanged: (v) => s.setShadowEnabled(v)),
                    ListTile(title: const Text('توهج الظل', style: TextStyle(color: Colors.white)), subtitle: Slider(value: s.shadowBlurRadius, min: 0, max: 20, onChanged: (v) => s.setShadowBlurRadius(v))),
                  ],
                ),

                ExpansionTile(
                  title: const Text('التموضع', style: TextStyle(color: Colors.white)),
                  children: [
                    ListTile(title: const Text('الهامش السفلي', style: TextStyle(color: Colors.white)), subtitle: Slider(value: s.bottomPadding, min: 0, max: 200, onChanged: (v) => s.setBottomPadding(v))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- باقي الكود كما هو ---
  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setOrientations();
  }

  void _setOrientations() {
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
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
      if (_isLocked) _showControls = false;
    });
  }

  Future<void> _initPlayer() async {
    final settings = context.read<SettingsProvider>();
    try {
      await _player.open(Media(widget.video.path), play: settings.autoPlay);
      _player.setRate(_speed);
      
      try { _volume = await VolumeController.instance.getVolume(); } catch (_) { _volume = 0.8; }
      VolumeController.instance.addListener((vol) { if (mounted) setState(() => _volume = vol); });
      try { _brightness = await ScreenBrightness.instance.current; } catch (_) {}

      _player.stream.position.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);
      });
      _player.stream.duration.listen((dur) => setState(() => _duration = dur));
      _player.stream.playing.listen((playing) => setState(() => _isPlaying = playing));
      _player.stream.tracks.listen((tracks) => setState(() { _subtitleTracks = tracks.subtitle; _audioTracks = tracks.audio; }));

      setState(() => _initialized = true);
      _scheduleHide();

      final srtPath = SubtitleService.findSrt(widget.video.path);
      if (srtPath != null) await _loadSrtFile(srtPath);
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _loadSrtFile(String path) async {
    try {
      final content = await File(path).readAsString();
      await _player.setSubtitleTrack(SubtitleTrack.data(content, title: 'ترجمة خارجية'));
    } catch (e) {}
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying && !_isLocked) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    if (_isLocked) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  // --- Build UI ---
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = context.watch<SettingsProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: !_initialized
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : Stack(
              children: [
                GestureDetector(
                  onTap: _toggleControls,
                  child: Video(
                    controller: _controller,
                    controls: NoVideoControls,
                    subtitleViewConfiguration: SubtitleViewConfiguration(
                      style: TextStyle(
                        fontSize: s.subtitleFontSize,
                        color: s.subtitleColor,
                        fontWeight: _getFontWeight(s.fontWeightIndex),
                        backgroundColor: s.subtitleBgColor.withOpacity(s.subtitleBgOpacity),
                        shadows: s.shadowEnabled ? [
                          Shadow(
                            color: s.shadowColor,
                            blurRadius: s.shadowBlurRadius,
                            offset: Offset(s.shadowOffsetX, s.shadowOffsetY),
                          )
                        ] : [],
                      ),
                      textAlign: TextAlign.center,
                      padding: EdgeInsets.only(bottom: s.bottomPadding, left: s.horizontalMargin, right: s.horizontalMargin),
                    ),
                  ),
                ),

                // Controls UI
                if (_showControls && !_isLocked) ...[
                   Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      color: Colors.black54,
                      child: SafeArea(
                        child: Row(children: [
                          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                          const Spacer(),
                          IconButton(icon: const Icon(Icons.subtitles, color: Colors.white), onPressed: _showSubtitleSettingsSheet),
                        ]),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
