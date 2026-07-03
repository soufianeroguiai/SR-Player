import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';

class SubtitleLayoutResult {
  final double? top;
  final double? bottom;
  final double maxWidth;
  final double fontSize;
  final EdgeInsets padding;
  final TextAlign textAlign;

  SubtitleLayoutResult({
    this.top,
    this.bottom,
    required this.maxWidth,
    required this.fontSize,
    required this.padding,
    required this.textAlign,
  });
}

class SubtitleLayoutEngine {
  static SubtitleLayoutResult calculate({
    required SubtitleSettings settings,
    required Size videoSize,
    required Size screenSize,
    required EdgeInsets safeArea,
  }) {
    // 1. حساب مقياس الحجم (Scale Factor)
    double scaleFactor = 1.0;
    switch (settings.scaleMode) {
      case SubtitleScaleMode.fixed:
        scaleFactor = 1.0;
        break;
      case SubtitleScaleMode.byResolution:
        // الاعتماد على دقة الفيديو (720p كأساس)
        scaleFactor = (videoSize.height > 0 ? videoSize.height : 720.0) / 720.0;
        break;
      case SubtitleScaleMode.byWindow:
        // الاعتماد على حجم نافذة العرض
        scaleFactor = screenSize.height / 1280.0; 
        break;
      case SubtitleScaleMode.smart:
        final videoRatio = (videoSize.height > 0 ? videoSize.height : 720.0) / 720.0;
        final screenRatio = screenSize.height / 1280.0;
        scaleFactor = (videoRatio + screenRatio) / 2.0;
        break;
    }
    
    // وضع حدود آمنة لمقياس التكبير
    scaleFactor = scaleFactor.clamp(0.5, 3.0);

    // 2. حساب أقصى عرض للترجمة (Max Width)
    double maxWidth = screenSize.width - (settings.horizontalMargin * 2);
    if (settings.keepInsideVideo && videoSize.width > 0) {
      final videoDisplayWidth = videoSize.width * scaleFactor;
      maxWidth = videoDisplayWidth - (settings.horizontalMargin * 2);
      if (maxWidth < 100) {
        maxWidth = screenSize.width - (settings.horizontalMargin * 2);
      }
    }

    // 3. حساب الحجم النهائي للخط
    final effectiveFontSize = settings.fontSize * settings.subtitleScale * scaleFactor;

    // 4. حساب التموضع الديناميكي (Top vs Bottom)
    double? topPos;
    double? bottomPos;

    if (settings.position == SubtitlePosition.top) {
      // إذا كانت الترجمة علوية، نثبتها من الأعلى لتنمو للأسفل
      topPos = settings.verticalMargin + settings.safeAreaPadding + safeArea.top;
    } else if (settings.position == SubtitlePosition.center) {
      // إذا كانت في المنتصف
      topPos = (screenSize.height / 2) - effectiveFontSize;
    } else { 
      // الافتراضي (سفلية): نثبتها من الأسفل لتنمو للأعلى 
      // وهذا ما يحل مشكلة اختفاء السطر الثاني تماماً
      bottomPos = settings.bottomMargin + settings.safeAreaPadding + safeArea.bottom;
    }

    return SubtitleLayoutResult(
      top: topPos,
      bottom: bottomPos,
      maxWidth: maxWidth,
      fontSize: effectiveFontSize,
      padding: EdgeInsets.only(
        left: settings.horizontalMargin,
        right: settings.horizontalMargin,
      ),
      textAlign: _getTextAlign(settings.alignment),
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
