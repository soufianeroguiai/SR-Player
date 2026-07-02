import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';

class SubtitleLayoutResult {
  final Offset position;
  final double maxWidth;
  final double scaleFactor;
  final EdgeInsets padding;
  final TextAlign textAlign;
  final int? maxLines;
  final bool keepInsideVideo;
  final double subtitleScale;
  final double fontSize;

  SubtitleLayoutResult({
    required this.position,
    required this.maxWidth,
    required this.scaleFactor,
    required this.padding,
    required this.textAlign,
    required this.maxLines,
    required this.keepInsideVideo,
    required this.subtitleScale,
    required this.fontSize,
  });
}

class SubtitleLayoutEngine {
  static SubtitleLayoutResult calculate({
    required SubtitleSettings settings,
    required Size videoSize,
    required Size screenSize,
    required EdgeInsets safeArea,
  }) {
    final videoAspect = videoSize.width / videoSize.height;
    final screenAspect = screenSize.width / screenSize.height;

    double scaleFactor = 1.0;

    switch (settings.scaleMode) {
      case SubtitleScaleMode.fixed:
        scaleFactor = 1.0;
        break;
      case SubtitleScaleMode.byResolution:
        // يعتمد على دقة الفيديو فقط
        final baseResolution = 720.0; // 720p هو الأساس
        scaleFactor = videoSize.height / baseResolution;
        break;
      case SubtitleScaleMode.byWindow:
        // يعتمد على حجم نافذة العرض (الشاشة)
        final baseScreenHeight = 1280.0; // شاشة 720p كأساس
        scaleFactor = screenSize.height / baseScreenHeight;
        break;
      case SubtitleScaleMode.smart:
        // ذكي: يجمع بين دقة الفيديو وحجم الشاشة
        final videoRatio = videoSize.height / 720.0;
        final screenRatio = screenSize.height / 1280.0;
        scaleFactor = (videoRatio + screenRatio) / 2.0;
        break;
    }

    // لا نسمح للعامل أن يصبح صغيراً جداً أو كبيراً جداً
    scaleFactor = scaleFactor.clamp(0.5, 3.0);

    double maxWidth = screenSize.width - settings.horizontalMargin * 2;
    if (settings.keepInsideVideo) {
      final videoDisplayWidth = videoSize.width * scaleFactor;
      final videoLeft = (screenSize.width - videoDisplayWidth) / 2;
      maxWidth = videoDisplayWidth - settings.horizontalMargin * 2;
      if (maxWidth < 100) maxWidth = screenSize.width - settings.horizontalMargin * 2;
    }

    final effectiveFontSize = settings.fontSize * settings.subtitleScale * scaleFactor;

    double bottomY = screenSize.height - settings.bottomMargin - settings.safeAreaPadding - safeArea.bottom;
    if (settings.position == SubtitlePosition.top) {
      bottomY = settings.verticalMargin + settings.safeAreaPadding + safeArea.top;
    } else if (settings.position == SubtitlePosition.center) {
      bottomY = screenSize.height / 2;
    }

    return SubtitleLayoutResult(
      position: Offset(0, bottomY),
      maxWidth: maxWidth,
      scaleFactor: scaleFactor,
      padding: EdgeInsets.only(
        left: settings.horizontalMargin,
        right: settings.horizontalMargin,
      ),
      textAlign: _getTextAlign(settings.alignment),
      maxLines: settings.autoWrap ? settings.maxLines : 1,
      keepInsideVideo: settings.keepInsideVideo,
      subtitleScale: settings.subtitleScale,
      fontSize: effectiveFontSize,
    );
  }

  static TextAlign _getTextAlign(SubtitleAlignment alignment) {
    switch (alignment) {
      case SubtitleAlignment.right: return TextAlign.right;
      case SubtitleAlignment.left: return TextAlign.left;
      case SubtitleAlignment.center:
      default: return TextAlign.center;
    }
  }
}