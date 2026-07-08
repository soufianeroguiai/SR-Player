import 'dart:ui';
import '../screens/player/player_fit_mode.dart';

class VideoLayoutCalculator {
  static Rect calculate({
    required Size videoSize,
    required Size screenSize,
    required VideoFitMode fitMode,
  }) {
    if (videoSize.isEmpty || screenSize.isEmpty) {
      return Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    }

    switch (fitMode) {
      case VideoFitMode.stretch:
        // تمديد كامل مع تشويه النسبة (يملأ الشاشة بدون احترام الأبعاد)
        return Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
      case VideoFitMode.fill:
      case VideoFitMode.cover:
        // يحافظ على النسبة ويملأ الشاشة مع قص الأطراف
        return _calculateCover(videoSize, screenSize);
      case VideoFitMode.contain:
      default:
        // يحافظ على النسبة ويحتوي الفيديو بالكامل داخل الشاشة
        return _calculateContain(videoSize, screenSize);
    }
  }

  static Rect _calculateContain(Size video, Size screen) {
    final double videoAspect = video.width / video.height;
    final double screenAspect = screen.width / screen.height;
    double width, height;
    if (videoAspect > screenAspect) {
      width = screen.width;
      height = width / videoAspect;
    } else {
      height = screen.height;
      width = height * videoAspect;
    }
    final left = (screen.width - width) / 2;
    final top = (screen.height - height) / 2;
    return Rect.fromLTWH(left, top, width, height);
  }

  static Rect _calculateCover(Size video, Size screen) {
    final double videoAspect = video.width / video.height;
    final double screenAspect = screen.width / screen.height;
    double width, height;
    if (videoAspect > screenAspect) {
      height = screen.height;
      width = height * videoAspect;
    } else {
      width = screen.width;
      height = width / videoAspect;
    }
    final left = (screen.width - width) / 2;
    final top = (screen.height - height) / 2;
    return Rect.fromLTWH(left, top, width, height);
  }
}