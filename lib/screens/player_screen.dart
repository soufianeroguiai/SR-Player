import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import 'info_screen.dart';

class PlayerScreen extends StatefulWidget {
  final VideoItem video;
  const PlayerScreen({super.key, required this.video});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  BetterPlayerController? _controller;
  bool _initialized = false;
  bool _showControls = true;
  Timer? _hideTimer;

  // Subtitle
  bool _showSubtitles = true;
  String? _subtitlePath;

  // Speed
  double _speed = 1.0;
  final _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _enterLandscape();

    final settings = context.read<SettingsProvider>();
    _showSubtitles = settings.showSubtitlesByDefault;
    _speed = settings.defaultSpeed;

    _initPlayer();
  }

  void _enterLandscape() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initPlayer() async {
    // Restore position if enabled
    Duration? savedPos;
    final settings = context.read<SettingsProvider>();
    if (settings.rememberPosition) {
      savedPos = await context.read<LibraryProvider>()
          .getPosition(widget.video.path);
    }

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.file,
      widget.video.path,
      subtitles: _subtitlePath != null
          ? [BetterPlayerSubtitlesSource(
              type: BetterPlayerSubtitlesSourceType.file,
              urls: [_subtitlePath!],
            )]
          : null,
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: settings.autoPlay,
        looping: false,
        startAt: savedPos,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoDetectFullscreenAspectRatio: true,
        handleLifecycle: true,
        autoDispose: true,
        allowedScreenSleep: false,
        subtitlesConfiguration: const BetterPlayerSubtitlesConfiguration(
          fontSize: 16,
          fontColor: Colors.white,
          outlineEnabled: true,
          outlineColor: Colors.black,
          outlineSize: 2,
        ),
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enableMute: true,
          enablePlayPause: true,
          enableProgressBar: true,
          enableSkips: true,
          enableSubtitles: true,
          enableQualities: false,
          enableAudioTracks: false,
          enablePlaybackSpeed: true,
          skipForwardTimeInMilliseconds: 10000,
          skipBackTimeInMilliseconds: 10000,
          controlBarColor: Colors.black.withOpacity(0.6),
          iconsColor: Colors.white,
          progressBarPlayedColor: const Color(0xFF90CAF9),
          progressBarHandleColor: const Color(0xFF42A5F5),
          progressBarBufferedColor: Colors.white38,
          progressBarBackgroundColor: Colors.white24,
          loadingWidget: const Center(
            child: CircularProgressIndicator(color: Color(0xFF90CAF9)),
          ),
        ),
        eventListener: (event) {
          if (event.betterPlayerEventType ==
              BetterPlayerEventType.finished) {
            _savePosition(Duration.zero);
          } else if (event.betterPlayerEventType ==
              BetterPlayerEventType.progress) {
            _onProgress();
          }
        },
      ),
      betterPlayerDataSource: dataSource,
    );

    await _controller!.setupDataSource(dataSource);
    _controller!.setSpeed(_speed);

    setState(() => _initialized = true);
    _scheduleHide();
  }

  void _onProgress() {
    final pos = _controller?.videoPlayerController?.value.position;
    if (pos != null) _savePosition(pos);
  }

  Future<void> _savePosition(Duration pos) async {
    final settings = context.read<SettingsProvider>();
    if (!settings.rememberPosition) return;
    await context.read<LibraryProvider>()
        .savePosition(widget.video.path, pos);
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  void _showSpeedSheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Text('سرعة التشغيل',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
            const Divider(height: 1),
            ..._speeds.map((sp) => ListTile(
                  title: Text('${sp}x'),
                  trailing: _speed == sp
                      ? Icon(Symbols.check_rounded, color: cs.primary)
                      : null,
                  selected: _speed == sp,
                  onTap: () {
                    setState(() => _speed = sp);
                    _controller?.setSpeed(sp);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _loadSubtitle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass'],
    );
    if (result?.files.single.path != null) {
      setState(() => _subtitlePath = result!.files.single.path);

      // Reload player with new subtitle
      final pos = _controller?.videoPlayerController?.value.position;
      _controller?.dispose();
      setState(() => _initialized = false);

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.file,
        widget.video.path,
        subtitles: [
          BetterPlayerSubtitlesSource(
            type: BetterPlayerSubtitlesSourceType.file,
            urls: [_subtitlePath!],
          )
        ],
      );

      await _controller!.setupDataSource(dataSource);
      if (pos != null) _controller!.seekTo(pos);
      _controller!.setSpeed(_speed);

      setState(() => _initialized = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحميل الترجمة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: !_initialized || _controller == null
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : Stack(
              children: [
                // BetterPlayer handles all gestures + controls internally
                GestureDetector(
                  onTap: _toggleControls,
                  child: BetterPlayer(controller: _controller!),
                ),

                // Custom top overlay
                if (_showControls)
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: _TopBar(
                      name: widget.video.name,
                      speed: _speed,
                      subtitlesEnabled: _showSubtitles,
                      onBack: () => Navigator.pop(context),
                      onSpeedTap: _showSpeedSheet,
                      onSubtitleToggle: () =>
                          setState(() => _showSubtitles = !_showSubtitles),
                      onSubtitleLoad: _loadSubtitle,
                      onInfo: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InfoScreen(video: widget.video),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller?.dispose();
    super.dispose();
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String name;
  final double speed;
  final bool subtitlesEnabled;
  final VoidCallback onBack;
  final VoidCallback onSpeedTap;
  final VoidCallback onSubtitleToggle;
  final VoidCallback onSubtitleLoad;
  final VoidCallback onInfo;

  const _TopBar({
    required this.name,
    required this.speed,
    required this.subtitlesEnabled,
    required this.onBack,
    required this.onSpeedTap,
    required this.onSubtitleToggle,
    required this.onSubtitleLoad,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              // Speed badge
              GestureDetector(
                onTap: onSpeedTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    '${speed}x',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Subtitle toggle
              IconButton(
                icon: Icon(
                  subtitlesEnabled
                      ? Symbols.subtitles_rounded
                      : Symbols.subtitles_off_rounded,
                  color: subtitlesEnabled ? Colors.lightBlue : Colors.white54,
                ),
                onPressed: onSubtitleToggle,
              ),
              // Load subtitle
              IconButton(
                icon: const Icon(Symbols.upload_file_rounded,
                    color: Colors.white54),
                onPressed: onSubtitleLoad,
              ),
              // Info
              IconButton(
                icon: const Icon(Symbols.info_rounded, color: Colors.white54),
                onPressed: onInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
