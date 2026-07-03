import 'dart:ui';
import '../screens/player/player_fit_mode.dart';

class VideoLayoutCalculator {
  static Rect calculate({
    required Size videoSize,
    required Size screenSize,
    required VideoFitMode fitMode,
    double zoomScale = 1.0,
    Offset panOffset = Offset.zero,
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
      case VideoFitMode.free:
        // نبدأ من مستطيل "احتواء" العادي، ثم نطبق نفس الزوم/السحب
        // اللي مطبق على الفيديو، باش الترجمة تبقى فوق الصورة بالضبط.
        final base = _calculateContain(videoSize, screenSize);
        final scaledWidth = base.width * zoomScale;
        final scaledHeight = base.height * zoomScale;
        final centerX = base.left + base.width / 2 + panOffset.dx;
        final centerY = base.top + base.height / 2 + panOffset.dy;
        return Rect.fromLTWH(
          centerX - scaledWidth / 2,
          centerY - scaledHeight / 2,
          scaledWidth,
          scaledHeight,
        );
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