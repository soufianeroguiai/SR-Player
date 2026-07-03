import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';

class SubtitleLayoutResult {
  final Alignment alignment;
  final EdgeInsets padding;
  final double maxWidth;
  final double fontSize;
  final TextAlign textAlign;

  SubtitleLayoutResult({
    required this.alignment,
    required this.padding,
    required this.maxWidth,
    required this.fontSize,
    required this.textAlign,
  });
}

class SubtitleLayoutEngine {
  static SubtitleLayoutResult calculate({
    required SubtitleSettings settings,
    required Size videoSize,
    required Rect videoRect,
    required Size screenSize,
    required EdgeInsets safeArea,
  }) {
    // 1. مقياس التكبير بناءً على دقة الفيديو الأصلية
    double scaleFactor = 1.0;
    switch (settings.scaleMode) {
      case SubtitleScaleMode.fixed:
        scaleFactor = 1.0;
        break;
      case SubtitleScaleMode.byResolution:
        scaleFactor = (videoSize.height > 0 ? videoSize.height : 720.0) / 720.0;
        break;
      case SubtitleScaleMode.byWindow:
        scaleFactor = screenSize.height / 1280.0;
        break;
      case SubtitleScaleMode.smart:
        final videoRatio = (videoSize.height > 0 ? videoSize.height : 720.0) / 720.0;
        final screenRatio = screenSize.height / 1280.0;
        scaleFactor = (videoRatio + screenRatio) / 2.0;
        break;
    }
    scaleFactor = scaleFactor.clamp(0.5, 3.0);

    // 2. أقصى عرض
    double maxWidth;
    if (settings.keepInsideVideo) {
      maxWidth = videoRect.width;
    } else {
      maxWidth = screenSize.width;
    }
    if (maxWidth < 100) maxWidth = screenSize.width;

    // 3. حجم الخط
    final effectiveFontSize = settings.fontSize * settings.subtitleScale * scaleFactor;

    // 4. الهوامش الأفقية
    final horizontalPadding = settings.horizontalMargin;

    // 5. الحشوات العمودية واختيار المحاذاة
    final Alignment alignment;
    EdgeInsets padding;

    final topNotch = settings.respectNotch ? safeArea.top : 0.0;
    final bottomNotch = settings.respectNotch ? safeArea.bottom : 0.0;

    switch (settings.position) {
      case SubtitlePosition.top:
        alignment = Alignment.topCenter;
        padding = EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          top: settings.verticalMargin + settings.safeAreaPadding + topNotch,
        );
        break;

      case SubtitlePosition.center:
        alignment = Alignment.center;
        padding = EdgeInsets.symmetric(horizontal: horizontalPadding);
        break;

      case SubtitlePosition.bottom:
        alignment = Alignment.bottomCenter;
        padding = EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: settings.bottomMargin + settings.safeAreaPadding + bottomNotch,
        );
        break;
    }

    return SubtitleLayoutResult(
      alignment: alignment,
      padding: padding,
      maxWidth: maxWidth,
      fontSize: effectiveFontSize,
      textAlign: _getTextAlign(settings.alignment),
    );
  }

  static TextAlign _getTextAlign(SubtitleAlignment alignment) {
    switch (alignment) {
      case SubtitleAlignment.right:
        return TextAlign.right;
      case SubtitleAlignment.left:
        return TextAlign.left;
      case SubtitleAlignment.center:
      default:
        return TextAlign.center;
    }
  }
}