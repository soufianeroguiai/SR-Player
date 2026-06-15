import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/subtitle_loader.dart';
import 'info_screen.dart';
import '../models/video_file.dart';

class PlayerScreen extends StatefulWidget {
  final String filePath;

  const PlayerScreen({super.key, required this.filePath});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _vpc;
  bool _initialized = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  Timer? _hideTimer;

  // Subtitles
  List<SubtitleEntry> _subtitles = [];
  SubtitleEntry? _currentSub;
  bool _showSubtitles = true;

  // Gesture overlay
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _showBrightOverlay = false;
  bool _showVolOverlay = false;
  bool _showSeekOverlay = false;
  String _seekLabel = '';

  // Drag state
  double _dragStartX = 0;
  double _dragStartY = 0;
  bool _isDragging = false;
  bool _dragIsSeek = false;
  bool _dragIsVol = false;
  bool _dragIsBri = false;
  Duration _dragStartPos = Duration.zero;

  // Playback speed
  double _speed = 1.0;
  final _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _enterFullscreen();
    _initPlayer();
    _initVolume();
    _initBrightness();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initPlayer() async {
    _vpc = VideoPlayerController.file(File(widget.filePath));
    await _vpc.initialize();
    _vpc.addListener(_onTick);
    _vpc.play();
    setState(() => _initialized = true);
    _scheduleHide();

    // Auto-load subtitle
    final srtPath = SubtitleLoader.findSrtFor(widget.filePath);
    if (srtPath != null) {
      final subs = await SubtitleLoader.loadSrt(srtPath);
      setState(() => _subtitles = subs);
    }
  }

  Future<void> _initVolume() async {
    VolumeController().showSystemUI = false;
    _volume = await VolumeController().getVolume();
  }

  Future<void> _initBrightness() async {
    try {
      _brightness = await ScreenBrightness().current;
    } catch (_) {
      _brightness = 0.5;
    }
  }

  void _onTick() {
    if (!mounted) return;
    final pos = _vpc.value.position;
    SubtitleEntry? sub;
    for (final s in _subtitles) {
      if (pos >= s.start && pos <= s.end) {
        sub = s;
        break;
      }
    }
    if (sub != _currentSub) setState(() => _currentSub = sub);
    if (_vpc.value.isCompleted) setState(() {});
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _vpc.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  void _togglePlay() {
    setState(() {
      _vpc.value.isPlaying ? _vpc.pause() : _vpc.play();
    });
    _scheduleHide();
  }

  void _seek(Duration delta) {
    final pos = _vpc.value.position + delta;
    final clamped = pos.isNegative
        ? Duration.zero
        : pos > _vpc.value.duration
            ? _vpc.value.duration
            : pos;
    _vpc.seekTo(clamped);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Future<void> _loadSubtitle() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'vtt', 'ass'],
    );
    if (result?.files.single.path != null) {
      final subs = await SubtitleLoader.loadSrt(result!.files.single.path!);
      setState(() => _subtitles = subs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحميل ${subs.length} سطر ترجمة'),
            backgroundColor: AppTheme.surface,
          ),
        );
      }
    }
  }

  void _showSpeedMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('سرعة التشغيل',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          ..._speeds.map(
            (s) => ListTile(
              title: Text('${s}x',
                  style: const TextStyle(color: Colors.white)),
              trailing: _speed == s
                  ? const Icon(Icons.check, color: AppTheme.orange)
                  : null,
              onTap: () {
                setState(() => _speed = s);
                _vpc.setPlaybackSpeed(s);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Gesture handlers ─────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    final size = MediaQuery.of(context).size;
    _dragStartX = d.localPosition.dx;
    _dragStartY = d.localPosition.dy;
    _isDragging = false;
    _dragIsSeek = false;
    _dragIsVol = false;
    _dragIsBri = false;
    _dragStartPos = _vpc.value.position;

    // Determine gesture zone:
    // Left third → brightness, right third → volume, center → seek
    final zone = _dragStartX / size.width;
    if (zone < 0.3) {
      _dragIsBri = true;
    } else if (zone > 0.7) {
      _dragIsVol = true;
    } else {
      _dragIsSeek = true;
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _isDragging = true;
    final dx = d.localPosition.dx - _dragStartX;
    final dy = _dragStartY - d.localPosition.dy; // inverted: up = positive

    if (_dragIsSeek) {
      // Horizontal seek: 1px = 0.5s
      final delta = Duration(milliseconds: (dx * 500).toInt());
      final target = _dragStartPos + delta;
      final clamped = target.isNegative
          ? Duration.zero
          : target > _vpc.value.duration
              ? _vpc.value.duration
              : target;
      final sign = dx >= 0 ? '+' : '';
      final secs = (delta.inSeconds).abs();
      setState(() {
        _showSeekOverlay = true;
        _seekLabel =
            '$sign${secs}s → ${_formatDuration(clamped)}';
      });
      _vpc.seekTo(clamped);
    } else if (_dragIsVol) {
      final newVol = (_volume + dy / 200).clamp(0.0, 1.0);
      _volume = newVol;
      VolumeController().setVolume(newVol);
      setState(() => _showVolOverlay = true);
    } else if (_dragIsBri) {
      final newBri = (_brightness + dy / 200).clamp(0.0, 1.0);
      _brightness = newBri;
      try {
        ScreenBrightness().setScreenBrightness(newBri);
      } catch (_) {}
      setState(() => _showBrightOverlay = true);
    }
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      _showSeekOverlay = false;
      _showVolOverlay = false;
      _showBrightOverlay = false;
    });
    _isDragging = false;
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_initialized
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.orange))
          : Stack(
              fit: StackFit.expand,
              children: [
                // Video
                GestureDetector(
                  onTap: _toggleControls,
                  onDoubleTapDown: (d) {
                    final half = MediaQuery.of(context).size.width / 2;
                    _seek(d.localPosition.dx < half
                        ? const Duration(seconds: -10)
                        : const Duration(seconds: 10));
                  },
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _vpc.value.aspectRatio,
                      child: VideoPlayer(_vpc),
                    ),
                  ),
                ),

                // Subtitle
                if (_showSubtitles && _currentSub != null)
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _currentSub!.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Gesture Overlays
                if (_showBrightOverlay) _buildOverlayPanel(
                  icon: Icons.brightness_6,
                  value: _brightness,
                  label: '${(_brightness * 100).toInt()}%',
                  color: Colors.yellow,
                ),
                if (_showVolOverlay) _buildOverlayPanel(
                  icon: _volume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  value: _volume,
                  label: '${(_volume * 100).toInt()}%',
                  color: Colors.lightBlue,
                ),
                if (_showSeekOverlay)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _seekLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // Controls overlay
                if (_showControls) _buildControls(),
              ],
            ),
    );
  }

  Widget _buildOverlayPanel({
    required IconData icon,
    required double value,
    required String label,
    required Color color,
  }) {
    return Center(
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: RotatedBox(
                quarterTurns: 3,
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0, 0.25, 0.65, 1],
        ),
      ),
      child: Column(
        children: [
          _buildTopBar(),
          const Spacer(),
          _buildCenterButtons(),
          const Spacer(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final name = widget.filePath.split('/').last;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
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
            // Speed
            TextButton(
              onPressed: _showSpeedMenu,
              child: Text(
                '${_speed}x',
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ),
            // Subtitles toggle
            IconButton(
              icon: Icon(
                Icons.subtitles,
                color: _showSubtitles ? AppTheme.orange : Colors.white38,
              ),
              onPressed: () => setState(() => _showSubtitles = !_showSubtitles),
              tooltip: 'ترجمة',
            ),
            // Load subtitle
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.white54),
              onPressed: _loadSubtitle,
              tooltip: 'تحميل ترجمة',
            ),
            // Info
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white54),
              onPressed: () {
                final parts = widget.filePath.split('/');
                final stat = File(widget.filePath).statSync();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InfoScreen(
                      video: VideoFile(
                        path: widget.filePath,
                        name: parts.last,
                        size: stat.size,
                        modified: stat.modified,
                        folder: parts.length > 1
                            ? parts[parts.length - 2]
                            : '',
                        duration: _vpc.value.duration,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButtons() {
    final isPlaying = _vpc.value.isPlaying;
    final isCompleted = _vpc.value.isCompleted;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ctrlBtn(
          icon: Icons.replay_10,
          size: 36,
          onTap: () => _seek(const Duration(seconds: -10)),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: isCompleted
              ? () {
                  _vpc.seekTo(Duration.zero);
                  _vpc.play();
                }
              : _togglePlay,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30),
            ),
            child: Icon(
              isCompleted
                  ? Icons.replay
                  : isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(width: 24),
        _ctrlBtn(
          icon: Icons.forward_10,
          size: 36,
          onTap: () => _seek(const Duration(seconds: 10)),
        ),
      ],
    );
  }

  Widget _ctrlBtn({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  Widget _buildBottomBar() {
    final pos = _vpc.value.position;
    final dur = _vpc.value.duration;
    final progress =
        dur.inMilliseconds > 0 ? pos.inMilliseconds / dur.inMilliseconds : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text(_formatDuration(pos),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 14),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (v) {
                          _vpc.seekTo(Duration(
                              milliseconds:
                                  (v * dur.inMilliseconds).toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(_formatDuration(dur),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            // Bottom action row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    _isFullscreen
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white70,
                  ),
                  onPressed: _toggleFullscreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _vpc.removeListener(_onTick);
    _vpc.dispose();
    super.dispose();
  }
}
