import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/video_item.dart';
import '../services/pip_service.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _player;
  VideoController? _controller;
  bool _isMini = false;
  bool _isHidden = true; // 👈 حالة إخفاء المشغل تماماً
  VideoItem? _currentVideo;
  bool _isPlaying = false;
  _AppLifecycleListener? _lifecycleListener;

  Player? get player => _player;
  VideoController? get controller => _controller;
  bool get isMini => _isMini;
  bool get isHidden => _isHidden; // 👈 getter للحالة
  VideoItem? get currentVideo => _currentVideo;
  bool get isPlaying => _isPlaying;

  void initPlayer() {
    if (_player == null) {
      _player = Player();
      _controller = VideoController(_player!);
    }
    notifyListeners();
  }

  // 👈 الدالة الجديدة: استدعِها عند الضغط على فيديو بدلاً من Navigator.push
  void openVideo(VideoItem video) {
    _currentVideo = video;
    _isMini = false;
    _isHidden = false;
    initPlayer();
    // هنا يمكنك أيضاً بدء تشغيل الفيديو تلقائياً عن طريق استدعاء player.open(...) الخ
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

  // 👈 دالة جديدة لجعل المشغل بالحجم الكامل مرة أخرى
  void maximize() {
    _isMini = false;
    notifyListeners();
  }

  void restore() {
    _isMini = false;
    notifyListeners();
  }

  /// زر واحد: يدخل Mini Player ثم يفعّل PiP تلقائياً عند الخروج للتطبيقات الأخرى
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

  // 👈 الدالة الجديدة: إغلاق المشغل تماماً وإخفاؤه
  void closePlayer() {
    _isHidden = true;
    _isMini = false;
    _isPlaying = false;
    _player?.stop();

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

  // الدالة القديمة (ما زالت موجودة للتوافق) – يمكنك الاستغناء عنها أو إبقائها
  void closeMiniPlayer() {
    closePlayer(); // توجيهها إلى closePlayer الجديدة
  }

  @override
  void dispose() {
    _player?.stop();
    try {
      _player?.dispose();
    } catch (_) {}
    _lifecycleListener?.dispose();
    super.dispose();
  }
}

// مراقب دورة حياة التطبيق لتفعيل PiP عند الخروج
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