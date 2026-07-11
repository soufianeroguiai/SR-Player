import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/video_item.dart';
import '../services/pip_service.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _player;
  VideoController? _controller;
  bool _isMini = false;
  bool _isHidden = true;
  VideoItem? _currentVideo;
  bool _isPlaying = false;
  _AppLifecycleListener? _lifecycleListener;
  StreamSubscription<bool>? _playingSubscription;

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
    if (PipService.isInPipMode.value && !_isMini) {
      _isMini = true;
      notifyListeners();
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
        notifyListeners();
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
    PipService.setEligible(false);

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
