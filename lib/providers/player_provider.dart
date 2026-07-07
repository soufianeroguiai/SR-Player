import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/video_item.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _player;
  VideoController? _controller;
  bool _isMini = false;
  VideoItem? _currentVideo;
  bool _isPlaying = false;

  Player? get player => _player;
  VideoController? get controller => _controller;
  bool get isMini => _isMini;
  VideoItem? get currentVideo => _currentVideo;
  bool get isPlaying => _isPlaying;

  void initPlayer() {
    if (_player == null) {
      _player = Player();
      _controller = VideoController(_player!);
    }
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

  void restore() {
    _isMini = false;
    notifyListeners();
  }

  void closeMiniPlayer() {
    _isPlaying = false;
    _player?.stop();

    try {
      _player?.dispose();
    } catch (_) {
      // تجاهل الخطأ في حال تم تدمير المشغل مسبقاً في شاشة العرض
    }

    _player = null;
    _controller = null;
    _isMini = false;
    _currentVideo = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _player?.stop();
    try {
      _player?.dispose();
    } catch (_) {}
    super.dispose();
  }
}