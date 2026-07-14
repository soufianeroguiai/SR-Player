import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/video_item.dart';
import '../services/pip_service.dart';
import '../services/background_playback_service.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _player;
  VideoController? _controller;
  bool _isMini = false;
  bool _isHidden = true;
  VideoItem? _currentVideo;
  bool _isPlaying = false;
  _AppLifecycleListener? _lifecycleListener;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<List<String>>? _subtitleSubscription;

  /// نص الترجمة الخام (غير منظَّف) القادم مباشرة من mpv. هذا هو **المصدر
  /// المشترك الوحيد** للترجمة بين الشاشة الكاملة والشاشة المصغّرة، لأنه
  /// يعيش داخل PlayerProvider الذي لا يُدمَّر أبداً عند التصغير (بعكس
  /// PlayerControlService الخاص بـ PlayerScreen الذي يُدمَّر مع الشاشة).
  /// كل عارض (شاشة كاملة أو مصغّرة) يُطبِّق SubtitleParser.clean() بنفس
  /// الإعدادات الحية من SettingsProvider، فتكون النتيجة مطابقة تماماً
  /// ومحدَّثة لحظياً فالحالتين.
  final ValueNotifier<String?> rawSubtitleText = ValueNotifier<String?>(null);

  /// true إذا كان يجب استخدام عارض mpv الأصلي للترجمة (ASS/SSA مع تأثيرات)
  /// بدل عارض فلاتر المخصَّص. تُحدَّثها PlayerScreen كل مرة تتغيّر فيها،
  /// وتقرؤها الشاشة المصغّرة أيضاً حتى يتطابق السلوك تماماً.
  final ValueNotifier<bool> useNativeSubtitleRendering = ValueNotifier<bool>(false);

  PlayerProvider() {
    // مهم: منذ ما صرنا نُفعّل PiP الحقيقي مباشرة من onUserLeaveHint() على
    // الجانب الأصلي (أندرويد)، صار بالإمكان دخول PiP وقت مشاهدة الفيديو
    // بملء الشاشة (isMini لازال false) بمجرد الضغط على زر الرئيسية، بدون
    // المرور أبداً بـ minimize()/minimizeAndStartPipIfNeeded(). لو بقينا
    // معتمدين فقط على isMini لتحديد ما يُعرض، فـ RootScreen غايبقى يعرض
    // PlayerScreen الكامل (بكل عناصر التحكم الكبيرة) مضغوطاً داخل نافذة
    // PiP الصغيرة، وهذا خطأ بصري. لهذا نستمع هنا لحالة PiP الحقيقية
    // القادمة من أندرويد ونُزامن isMini معها فوراً بمجرد دخول PiP فعلياً،
    // بغض النظر عن كيف تم تفعيله.
    PipService.isInPipMode.addListener(_onSystemPipModeChanged);
  }

  void _onSystemPipModeChanged() {
    if (PipService.isInPipMode.value) {
      // دخول PiP فعلياً (بغض النظر عن السبب) - نُزامن isMini معه.
      if (!_isMini) {
        _isMini = true;
        notifyListeners();
      }
    } else {
      // المستخدم رجع للتطبيق من نافذة PiP الحقيقية (بالضغط على زر
      // التكبير مثلاً). كانت هذه الحالة ناقصة سابقاً: isMini كان يبقى
      // true للأبد، فيبان المشغّل المصغّر داخل التطبيق بدل الشاشة الكاملة
      // رغم أن نية المستخدم بالضغط على "تكبير" كانت الرجوع للشاشة الكاملة.
      if (_isMini) {
        _isMini = false;
        notifyListeners();
      }
    }
  }

  Player? get player => _player;
  VideoController? get controller => _controller;
  bool get isMini => _isMini;
  bool get isHidden => _isHidden;
  VideoItem? get currentVideo => _currentVideo;
  bool get isPlaying => _isPlaying;

  void initPlayer() {
    if (_player == null) {
      _player = Player();
      _controller = VideoController(_player!);
      // نستمع لتيار حالة التشغيل الحقيقي من media_kit ونُبلِغ الجانب
      // الأصلي (Android) بأهلية PiP باستمرار، حتى يكون جاهزاً وقت
      // onUserLeaveHint() بدل انتظار رد من Dart فتلك اللحظة بالذات.
      _playingSubscription = _player!.stream.playing.listen((playing) {
        _isPlaying = playing;
        PipService.setEligible(playing);
        // خدمة أمامية تُبقي الصوت شغّالاً بعد قفل الشاشة - نُشغّلها فقط
        // أثناء التشغيل الفعلي (وليس طيلة مدة فتح المشغّل) لتفادي استهلاك
        // بطارية غير ضروري وقت الإيقاف المؤقت.
        if (playing) {
          BackgroundPlaybackService.start(_currentVideo?.name ?? 'SR Player');
        } else {
          BackgroundPlaybackService.stop();
        }
        notifyListeners();
      });
      // مصدر الترجمة الوحيد المشترك بين الشاشة الكاملة والمصغّرة - يبقى
      // حياً طالما الفيديو مفتوح، بغض النظر عن حالة isMini.
      _subtitleSubscription = _player!.stream.subtitle.listen((lines) {
        rawSubtitleText.value = lines.isNotEmpty ? lines.join('\n') : null;
      });
    }
    notifyListeners();
  }

  void openVideo(VideoItem video) {
    _currentVideo = video;
    _isMini = false;
    _isHidden = false;
    initPlayer();
    notifyListeners();
  }

  void setCurrentVideo(VideoItem video) {
    _currentVideo = video;
    notifyListeners();
  }

  void updatePlayingState(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  /// تستدعيها PlayerScreen كل مرة تُعيد فيها حساب قرار "عارض فلاتر مقابل
  /// عارض mpv الأصلي" حتى تقرأ الشاشة المصغّرة نفس القرار بالضبط.
  void updateUseNativeSubtitleRendering(bool value) {
    if (useNativeSubtitleRendering.value != value) {
      useNativeSubtitleRendering.value = value;
    }
  }

  void minimize() {
    _isMini = true;
    notifyListeners();
  }

  void maximize() {
    _isMini = false;
    notifyListeners();
  }

  void restore() {
    _isMini = false;
    notifyListeners();
  }

  void minimizeAndStartPipIfNeeded() {
    minimize();

    _lifecycleListener?.dispose();
    _lifecycleListener = _AppLifecycleListener(
      onPause: () {
        if (!PipService.isInPipMode.value && _player?.state.playing == true) {
          PipService.enter();
        }
      },
      onDetach: () {
        if (!PipService.isInPipMode.value && _player?.state.playing == true) {
          PipService.enter();
        }
      },
    );
  }

  void closePlayer() {
    _isHidden = true;
    _isMini = false;
    _isPlaying = false;
    _player?.stop();

    _playingSubscription?.cancel();
    _playingSubscription = null;
    _subtitleSubscription?.cancel();
    _subtitleSubscription = null;
    rawSubtitleText.value = null;
    PipService.setEligible(false);
    BackgroundPlaybackService.stop();

    try {
      _player?.dispose();
    } catch (_) {}

    _lifecycleListener?.dispose();
    _lifecycleListener = null;

    _player = null;
    _controller = null;
    _currentVideo = null;
    notifyListeners();
  }

  void closeMiniPlayer() {
    closePlayer();
  }

  @override
  void dispose() {
    _player?.stop();
    _playingSubscription?.cancel();
    _subtitleSubscription?.cancel();
    BackgroundPlaybackService.stop();
    rawSubtitleText.dispose();
    useNativeSubtitleRendering.dispose();
    PipService.isInPipMode.removeListener(_onSystemPipModeChanged);
    try {
      _player?.dispose();
    } catch (_) {}
    _lifecycleListener?.dispose();
    super.dispose();
  }
}

class _AppLifecycleListener with WidgetsBindingObserver {
  final VoidCallback onPause;
  final VoidCallback onDetach;

  _AppLifecycleListener({required this.onPause, required this.onDetach}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) onPause();
    if (state == AppLifecycleState.detached) onDetach();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
