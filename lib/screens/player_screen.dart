import 'dart:async';
import 'dart:io';
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
import 'info_screen.dart';

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
  Timer? _hideTimer;

  // الترجمة (تعتمد كليا على مشغل media_kit/mpv الآن — تدعم المدمجة والخارجية بنفس الطريقة)
  bool _showSubtitles = true;
  List<SubtitleTrack> _subtitleTracks = [];
  List<AudioTrack> _audioTracks = [];
  double _audioBoost = 100.0;

  // Speed
  double _speed = 1.0;
  final _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  // Progress
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  // Volume & brightness
  double _volume = 1.0;
  double _brightness = 1.0;
  bool _showBrightnessIndicator = false;
  bool _showVolumeIndicator = false;
  Timer? _indicatorTimer;
  StreamSubscription? _brightnessSubscription;

  // جاستر السحب (يمين/يسار = تقديم/تأخير، فوق/تحت = صوت/سطوع)
  String? _dragAxis; // 'h' أو 'v'
  bool _dragIsLeftSide = false;
  Offset _dragStartGlobal = Offset.zero;
  Duration _dragStartPosition = Duration.zero;
  Duration _seekPreview = Duration.zero;
  bool _showSeekIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _enterFullscreen();

    final settings = context.read<SettingsProvider>();
    _showSubtitles = settings.showSubtitlesByDefault;
    _speed = settings.defaultSpeed;

    _player = Player();
    _controller = VideoController(_player);

    _initPlayer();
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
    final settings = context.read<SettingsProvider>();

    try {
      await _player.open(Media(widget.video.path), play: settings.autoPlay);
      _player.setRate(_speed);

      if (settings.rememberPosition) {
        try {
          final saved = await context.read<LibraryProvider>().getPosition(widget.video.path);
          if (saved != null && saved.inSeconds > 0) await _player.seek(saved);
        } catch (_) {}
      }

      _player.stream.position.listen((pos) {
        if (!mounted) return;
        setState(() => _position = pos);
        if (pos.inSeconds % 5 == 0 && settings.rememberPosition) {
          context.read<LibraryProvider>().savePosition(widget.video.path, pos);
        }
      });

      _player.stream.duration.listen((dur) {
        if (mounted) setState(() => _duration = dur);
      });

      _player.stream.playing.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });

      // 🎞️ مسارات الترجمة والصوت — استماع تفاعلي بدل قراءة لحظة واحدة
      // (هادشي كيحل مشكلة "ما كيتعرفش على الترجمة المدمجة" لي كانت بسبب
      // قراءة القائمة قبل ما libmpv يخلص يحلل الملف، خاصة فملفات hevc الكبيرة)
      _player.stream.tracks.listen((tracks) {
        if (!mounted) return;
        setState(() {
          _subtitleTracks = tracks.subtitle;
          _audioTracks = tracks.audio;
        });
      });

      // 🔊 الصوت (Singleton)
      try {
        _volume = await VolumeController.instance.getVolume();
      } catch (_) {
        _volume = 1.0;
      }
      VolumeController.instance.addListener((vol) {
        if (mounted) setState(() => _volume = vol);
      });

      // ☀️ السطوع (API 2.1.11)
      try {
        _brightness = await ScreenBrightness.instance.system;
      } catch (_) {
        _brightness = 1.0;
      }
      _brightnessSubscription = ScreenBrightness
          .instance.onSystemScreenBrightnessChanged
          .listen((newBrightness) {
        if (mounted) setState(() => _brightness = newBrightness);
      });

      setState(() => _initialized = true);
      _scheduleHide();

      final srtPath = SubtitleService.findSrt(widget.video.path);
      if (srtPath != null) await _loadSrtFile(srtPath);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تشغيل الملف: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _loadSrtFile(String path) async {
    try {
      // نستعمل نفس محرك mpv (SubtitleTrack.data) بدل المحلل اليدوي القديم
      // — هادشي كيضمن نفس الجودة، التزامن، والتخصيص (خط/حجم/لون) لي كاين فالترجمة المدمجة
      final content = await File(path).readAsString();
      await _player.setSubtitleTrack(SubtitleTrack.data(content, title: 'ترجمة خارجية'));
      if (mounted) {
        setState(() => _showSubtitles = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ تم تحميل الترجمة الخارجية')),
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

  Future<void> _pickSubtitle() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt', 'SRT'],
    );
    if (result?.files.single.path != null) {
      await _loadSrtFile(result!.files.single.path!);
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  Future<void> _enterPip() async {
    try {
      await PipService.enter();
    } catch (_) {}
  }

  // ── الإيماءات ────────────────────────────────
  // فلاتر ما كيسمحش بدمج onVerticalDragUpdate و onHorizontalDragUpdate فنفس
  // GestureDetector (كيعطي خطأ)، فاستعملنا onPan* وحددنا المحور (أفقي/عمودي)
  // عند أول حركة، حسب الاتجاه الغالب.
  void _onPanStart(DragStartDetails details) {
    _dragAxis = null;
    _dragStartGlobal = details.globalPosition;
    _dragStartPosition = _position;
    _dragIsLeftSide = details.localPosition.dx < MediaQuery.of(context).size.width / 2;
  }

  void _onPanUpdate(DragUpdateDetails details, double screenWidth) {
    final totalDx = details.globalPosition.dx - _dragStartGlobal.dx;
    final totalDy = details.globalPosition.dy - _dragStartGlobal.dy;

    // عتبة صغيرة (12px) قبل ما نقرر المحور، باش نتجنبو الحساسية الزايدة
    _dragAxis ??= (totalDx.abs() > 12 || totalDy.abs() > 12)
        ? (totalDx.abs() > totalDy.abs() ? 'h' : 'v')
        : null;
    if (_dragAxis == null) return;

    if (_dragAxis == 'h') {
      // سحب يمين/يسار = تقديم/تأخير، عرض الشاشة الكامل ≈ 90 ثانية
      final seekSeconds = (totalDx / screenWidth) * 90;
      var target = _dragStartPosition + Duration(seconds: seekSeconds.round());
      if (target < Duration.zero) target = Duration.zero;
      if (_duration > Duration.zero && target > _duration) target = _duration;
      setState(() {
        _seekPreview = target;
        _showSeekIndicator = true;
      });
    } else {
      _handleVerticalGesture(details.delta.dy);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragAxis == 'h') {
      _player.seek(_seekPreview);
      setState(() => _showSeekIndicator = false);
    }
    _dragAxis = null;
  }

  void _handleVerticalGesture(double dy) {
    final delta = -dy / 200;

    if (_dragIsLeftSide) {
      // ☀️ سطوع
      final newBrightness = (_brightness + delta).clamp(0.0, 1.0);
      try {
        ScreenBrightness.instance.setSystemScreenBrightness(newBrightness);
        setState(() {
          _brightness = newBrightness;
          _showBrightnessIndicator = true;
          _showVolumeIndicator = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('يجب منح صلاحية "تعديل إعدادات النظام" لتغيير السطوع'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      // 🔊 صوت
      final newVolume = (_volume + delta).clamp(0.0, 1.0);
      VolumeController.instance.setVolume(newVolume);
      setState(() {
        _volume = newVolume;
        _showVolumeIndicator = true;
        _showBrightnessIndicator = false;
      });
    }
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) setState(() {
        _showBrightnessIndicator = false;
        _showVolumeIndicator = false;
      });
    });
  }

  void _showSpeedSheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text('سرعة التشغيل', style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16))),
        const Divider(height: 1),
        ..._speeds.map((sp) => ListTile(
          title: Text('${sp}x'),
          trailing: _speed == sp ? Icon(Symbols.check_rounded, color: cs.primary) : null,
          selected: _speed == sp,
          onTap: () {
            setState(() => _speed = sp);
            _player.setRate(sp);
            Navigator.pop(context);
          },
        )),
      ]),
    ));
  }

  // ── قائمة الترجمة الموحدة ─────────────────────
  Future<void> _showSubtitleMenu() async {
    final cs = Theme.of(context).colorScheme;
    final hasEmbedded = _subtitleTracks.isNotEmpty;

    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text('الترجمة', style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16))),
        const Divider(height: 1),

        // تشغيل / إيقاف
        SwitchListTile(
          secondary: Icon(
            _showSubtitles ? Symbols.subtitles_rounded : Symbols.subtitles_off_rounded,
            color: _showSubtitles ? Colors.lightBlue : cs.onSurfaceVariant,
          ),
          title: Text(_showSubtitles ? 'إيقاف الترجمة' : 'تشغيل الترجمة'),
          value: _showSubtitles,
          onChanged: (v) {
            setState(() => _showSubtitles = v);
            if (!v) {
              _player.setSubtitleTrack(SubtitleTrack.no());
            }
            Navigator.pop(context);
          },
        ),

        // اختيار ترجمة مدمجة (إن وجدت)
        if (hasEmbedded) ...[
          const Divider(height: 1),
          ..._subtitleTracks.map((track) => ListTile(
            title: Text(track.title ?? track.language ?? 'غير معروف'),
            subtitle: Text(track.language ?? ''),
            trailing: _player.state.track.subtitle == track
                ? Icon(Symbols.check_rounded, color: cs.primary) : null,
            onTap: () {
              _player.setSubtitleTrack(track);
              setState(() => _showSubtitles = true);
              Navigator.pop(context);
            },
          )),
        ] else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Text(
              'ماكاينة أي ترجمة مدمجة فهاد الفيديو. إلى كنتي متأكد بلي كاينة، تسنى ثانية وحاول من جديد (كيتأخر شوية فالملفات الكبيرة).',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
            ),
          ),

        // تحميل ترجمة خارجية
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Symbols.upload_file_rounded),
          title: const Text('تحميل ترجمة من ملف...'),
          onTap: () {
            Navigator.pop(context);
            _pickSubtitle();
          },
        ),

        // تخصيص المظهر (خط، حجم، لون، خلفية)
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Symbols.format_size_rounded),
          title: const Text('تخصيص مظهر الترجمة'),
          subtitle: const Text('الحجم، اللون، الخلفية'),
          onTap: () {
            Navigator.pop(context);
            _showSubtitleStyleSheet();
          },
        ),

        // إيقاف الترجمة المدمجة
        if (hasEmbedded)
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('إيقاف الترجمة المدمجة'),
            onTap: () {
              _player.setSubtitleTrack(SubtitleTrack.no());
              setState(() => _showSubtitles = false);
              Navigator.pop(context);
            },
          ),
      ]),
    ));
  }

  // ── تخصيص مظهر الترجمة ─────────────────────
  void _showSubtitleStyleSheet() {
    final cs = Theme.of(context).colorScheme;
    final presetColors = <Color>[
      Colors.white, Colors.yellowAccent, Colors.cyanAccent,
      Colors.lightGreenAccent, Colors.redAccent,
    ];

    showModalBottomSheet(context: context, builder: (_) => Consumer<SettingsProvider>(
      builder: (ctx, s, __) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('تخصيص مظهر الترجمة', style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 18),

          Text('حجم الخط — ${s.subtitleFontSize.round()}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          Slider(
            value: s.subtitleFontSize, min: 12, max: 34, divisions: 22,
            onChanged: s.setSubtitleFontSize,
          ),

          const SizedBox(height: 6),
          Text('شفافية الخلفية — ${(s.subtitleBgOpacity * 100).round()}%',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          Slider(
            value: s.subtitleBgOpacity, min: 0, max: 1,
            onChanged: s.setSubtitleBgOpacity,
          ),

          const SizedBox(height: 10),
          Text('لون الخط', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 10),
          Row(children: presetColors.map((c) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => s.setSubtitleColor(c),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: c, shape: BoxShape.circle,
                  border: Border.all(
                    color: s.subtitleColor.value == c.value ? cs.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            ),
          )).toList()),

          const SizedBox(height: 16),
          // معاينة مباشرة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(s.subtitleBgOpacity),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('معاينة الترجمة', style: TextStyle(
                  color: s.subtitleColor, fontSize: s.subtitleFontSize, fontWeight: FontWeight.w600,
                )),
              ),
            ),
          ),
        ]),
      ),
    ));
  }

  // ── قائمة الصوت المدمج ─────────────────────
  Future<void> _showAudioMenu() async {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text('الصوت', style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16))),
        const Divider(height: 1),

        if (_audioTracks.length > 1) ...[
          ..._audioTracks.map((track) => ListTile(
            title: Text(track.title ?? track.language ?? 'مسار غير معروف'),
            subtitle: track.language != null ? Text(track.language!) : null,
            trailing: _player.state.track.audio == track
                ? Icon(Symbols.check_rounded, color: cs.primary) : null,
            onTap: () {
              _player.setAudioTrack(track);
              Navigator.pop(context);
            },
          )),
          const Divider(height: 1),
        ] else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Text('هاد الفيديو فيه مسار صوت واحد فقط.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
          ),

        ListTile(
          leading: const Icon(Symbols.graphic_eq_rounded),
          title: const Text('تكبير الصوت (Boost)'),
          subtitle: Text('${_audioBoost.round()}%'),
          onTap: () {
            Navigator.pop(context);
            _showAudioBoostSheet();
          },
        ),
      ]),
    ));
  }

  void _showAudioBoostSheet() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('تكبير الصوت', style: TextStyle(
              color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text('${_audioBoost.round()}%', style: TextStyle(
              color: cs.primary, fontWeight: FontWeight.w700, fontSize: 24)),
          Slider(
            value: _audioBoost, min: 50, max: 200, divisions: 30,
            label: '${_audioBoost.round()}%',
            onChanged: (v) {
              setSheetState(() {});
              setState(() => _audioBoost = v);
              _player.setVolume(v);
            },
          ),
          Text('تجاوز 100% كيكبر الصوت داخليا، وقد يسبب تشويش فبعض الفيديوهات.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11.5), textAlign: TextAlign.center),
        ]),
      ),
    ));
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final settings = context.watch<SettingsProvider>();

    if (_isPip) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Video(controller: _controller),
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _enterPip();
        }
      },
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: !_initialized
            ? Center(child: CircularProgressIndicator(color: cs.primary))
            : GestureDetector(
                onTap: _toggleControls,
                onPanStart: _onPanStart,
                onPanUpdate: (details) => _onPanUpdate(details, screenWidth),
                onPanEnd: _onPanEnd,
                child: Stack(children: [
                  Video(
                    controller: _controller,
                    controls: NoVideoControls,
                    subtitleViewConfiguration: SubtitleViewConfiguration(
                      style: TextStyle(
                        height: 1.3,
                        fontSize: settings.subtitleFontSize,
                        color: settings.subtitleColor,
                        fontWeight: FontWeight.w600,
                        backgroundColor: Colors.black.withOpacity(settings.subtitleBgOpacity),
                      ),
                      textAlign: TextAlign.center,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 56),
                    ),
                  ),

                  // مؤشر السطوع
                  if (_showBrightnessIndicator)
                    Positioned(
                      left: 20,
                      bottom: 120,
                      child: _buildIndicator(Icons.brightness_6, '${(_brightness * 100).round()}%', cs.primary),
                    ),

                  // مؤشر الصوت
                  if (_showVolumeIndicator)
                    Positioned(
                      right: 20,
                      bottom: 120,
                      child: _buildIndicator(Icons.volume_up, '${(_volume * 100).round()}%', cs.primary),
                    ),

                  // مؤشر التقديم/التأخير بالسحب يمين/يسار
                  if (_showSeekIndicator)
                    Center(
                      child: _buildIndicator(
                        _seekPreview >= _dragStartPosition
                            ? Symbols.fast_forward_rounded
                            : Symbols.fast_rewind_rounded,
                        '${_fmt(_seekPreview)}  '
                        '(${_seekPreview >= _dragStartPosition ? '+' : ''}'
                        '${(_seekPreview - _dragStartPosition).inSeconds}s)',
                        cs.primary,
                      ),
                    ),

                  if (_showControls) ...[
                    _TopBar(
                      name: widget.video.name,
                      speed: _speed,
                      subtitlesOn: _showSubtitles,
                      onBack: () => Navigator.pop(context),
                      onPip: _enterPip,
                      onSpeed: _showSpeedSheet,
                      onSubtitles: _showSubtitleMenu,
                      onAudio: _showAudioMenu,
                      onInfo: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => InfoScreen(video: widget.video))),
                    ),

                    Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CtrlBtn(Symbols.replay_10_rounded, () => _player.seek(_position - const Duration(seconds: 10))),
                        const SizedBox(width: 28),
                        GestureDetector(
                          onTap: () => _isPlaying ? _player.pause() : _player.play(),
                          child: Container(
                            width: 68, height: 68,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlaying ? Symbols.pause_rounded : Symbols.play_arrow_rounded,
                              color: cs.onPrimaryContainer, size: 38,
                            ),
                          ),
                        ),
                        const SizedBox(width: 28),
                        _CtrlBtn(Symbols.forward_10_rounded, () => _player.seek(_position + const Duration(seconds: 10))),
                      ],
                    )),

                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: Row(children: [
                              Text(_fmt(_position),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    activeTrackColor: cs.primary,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: cs.primary,
                                    overlayColor: cs.primary.withOpacity(0.2),
                                  ),
                                  child: Slider(
                                    value: _duration.inMilliseconds > 0
                                        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                                        : 0.0,
                                    onChanged: (v) => _player.seek(
                                      Duration(milliseconds: (v * _duration.inMilliseconds).toInt()),
                                    ),
                                  ),
                                ),
                              ),
                              Text(_fmt(_duration),
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
      ),
    );
  }

  Widget _buildIndicator(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _indicatorTimer?.cancel();
    VolumeController.instance.removeListener();
    _brightnessSubscription?.cancel();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _player.dispose();
    super.dispose();
  }
}

// ── TopBar ────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String name;
  final double speed;
  final bool subtitlesOn;
  final VoidCallback onBack, onPip, onSpeed, onSubtitles, onAudio, onInfo;

  const _TopBar({
    required this.name,
    required this.speed,
    required this.subtitlesOn,
    required this.onBack,
    required this.onPip,
    required this.onSpeed,
    required this.onSubtitles,
    required this.onAudio,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Row(children: [
            IconButton(
              icon: const Icon(Symbols.arrow_back_rounded, color: Colors.white),
              onPressed: onBack,
            ),
            Expanded(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            IconButton(
              icon: const Icon(Symbols.picture_in_picture_rounded, color: Colors.white70),
              onPressed: onPip,
              tooltip: 'نافذة عائمة',
            ),
            IconButton(
              icon: const Icon(Symbols.graphic_eq_rounded, color: Colors.white70),
              onPressed: onAudio,
              tooltip: 'الصوت',
            ),
            GestureDetector(
              onTap: onSpeed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${speed}x', style: TextStyle(
                    color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                subtitlesOn ? Symbols.subtitles_rounded : Symbols.subtitles_off_rounded,
                color: subtitlesOn ? Colors.lightBlue : Colors.white54,
              ),
              onPressed: onSubtitles,
              tooltip: 'الترجمة',
            ),
            IconButton(
              icon: const Icon(Symbols.info_rounded, color: Colors.white54),
              onPressed: onInfo,
            ),
          ]),
        ),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}