import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import '../../models/video_item.dart';
import '../../services/video_info_service.dart';
import 'player_fit_mode.dart';

class PlayerUIState extends ChangeNotifier {
  bool initialized = false;
  bool showControls = true;
  bool isLocked = false;
  bool showQuickActions = false;
  ActiveMenu currentMenu = ActiveMenu.none;

  double volumeLevel = 1.0;
  double audioDelay = 0.0;
  double speed = 1.0;
  double subtitleSync = 0.0;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;

  bool showSubtitles = true;
  List<SubtitleTrack> subtitleTracks = [];
  List<AudioTrack> audioTracks = [];
  List<({String title, Duration start})> chapters = [];

  VideoFitMode fitMode = VideoFitMode.contain;
  String? fitOverlayText;

  bool showLockHint = false;
  double lockIconOffset = 0.0;

  bool showScreenshotFlash = false;
  bool isNightMode = false;
  PlaylistMode playlistMode = PlaylistMode.none;
  bool isShuffle = false;

  bool smartEnhance = false;
  bool hdrEnabled = false;
  bool hwEnabled = true;

  bool showResumeDialog = false;
  Duration? savedPosition;

  bool isSpeedBoosted = false;

  double brightness = 0;
  double contrast = 0;
  double saturation = 0;
  double hue = 0;
  double gamma = 0;

  bool autoSubtitleSelected = false;
  bool autoAudioSelected = false;
  List<dynamic>? lastSubtitleEntries;
  bool hasExternalSubtitle = false;

  double preNightBrightness = 0.7;
  double preMuteVolume = 1.0;

  List<VideoItem> playlistVideos = [];
  int currentPlaylistIndex = -1;

  String? currentSubtitleText;

  // 🔍 تكبير/سحب حر (Pan & Zoom)
  double zoomScale = 1.0;
  Offset panOffset = Offset.zero;

  // 🔁 تكرار مقطع A-B
  Duration? repeatPointA;
  Duration? repeatPointB;

  // 📊 معلومات تقنية (Stats for Nerds)
  bool showStatsOverlay = false;
  VideoInfo? videoInfo;

  void resetZoomPan() {
    zoomScale = 1.0;
    panOffset = Offset.zero;
    notifyListeners();
  }

  void clearRepeatPoints() {
    repeatPointA = null;
    repeatPointB = null;
    notifyListeners();
  }

  void resetMenu() {
    currentMenu = ActiveMenu.none;
    showQuickActions = false;
    notifyListeners();
  }

  void updatePlaylistIndex(int index) {
    currentPlaylistIndex = index;
    notifyListeners();
  }

  void updateSubtitleText(String? text) {
    currentSubtitleText = text;
    notifyListeners();
  }
}

enum ActiveMenu { none, subtitles, audio, settings }