import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart'; 
import '../services/subtitle_service.dart'; 
import '../screens/player/subtitle_style_builder.dart'; 
import '../services/subtitle_layout_engine.dart'; 

class SubtitleRenderer extends StatelessWidget {
  final SubtitleEntry? currentEntry;
  final SubtitleSettings settings;
  final Size videoSize;
  final Size screenSize;
  final EdgeInsets safeArea;
  final bool visible;

  const SubtitleRenderer({
    super.key,
    required this.currentEntry,
    required this.settings,
    required this.videoSize,
    required this.screenSize,
    required this.safeArea,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    // إخفاء الترجمة عند عدم وجود حوار
    if (currentEntry == null || !visible || !settings.autoShow || currentEntry!.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. استدعاء المحرك للحصول على الأبعاد والتموضع الجديد
    final layout = SubtitleLayoutEngine.calculate(
      settings: settings,
      videoSize: videoSize,
      screenSize: screenSize,
      safeArea: safeArea,
    );

    // 2. تنظيف النص وتهيئته
    String displayText = currentEntry!.text;
    
    // تجاهل تأثيرات ASS إذا تم التفعيل
    if (settings.ignoreAssEffects) {
      displayText = displayText.replaceAll(RegExp(r'\{.*?\}'), '');
    }
    
    // مسح رموز التوجيه المخفية (Bidi Controls) التي تسبب المربعات البيضاء في الخطوط
    displayText = displayText.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u061C]'), '');
    
    // الكشف عن اللغة العربية لضبط اتجاه النص (لحل مشكلة علامات الترقيم)
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(displayText);

    // 3. بناء الخط
    final textStyle = buildSubtitleTextStyle(settings).copyWith(
      fontSize: layout.fontSize,
    );

    // 4. بناء عنصر النص
    Widget textWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: textStyle,
      textAlign: layout.textAlign,
      maxLines: settings.autoWrap ? settings.maxLines : 1,
      overflow: TextOverflow.ellipsis,
      child: Text(
        displayText,
        textAlign: layout.textAlign,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr, // السحر هنا لعلامات الترقيم
        maxLines: settings.autoWrap ? settings.maxLines : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    // 5. بناء الخلفية
    if (settings.bgOpacity > 0) {
      double radius;
      switch (settings.bgShape) {
        case SubtitleBgShape.rectangle:
          radius = 0;
          break;
        case SubtitleBgShape.capsule:
          radius = 100;
          break;
        case SubtitleBgShape.rounded:
        default:
          radius = settings.bgBorderRadius;
      }

      textWidget = Container(
        padding: EdgeInsets.all(settings.bgPadding),
        decoration: BoxDecoration(
          color: settings.bgColor.withOpacity(settings.bgOpacity),
          borderRadius: BorderRadius.circular(radius),
          border: settings.bgBorderWidth > 0
              ? Border.all(color: settings.bgBorderColor, width: settings.bgBorderWidth)
              : null,
        ),
        child: textWidget,
      );
    }

    // 6. التموضع النهائي باستخدام Positioned
    // استخدام top و bottom معاً يسمح للنص بالانطلاق من أسفل الشاشة والنمو للأعلى 
    // دون أن يُقطع السطر الثاني أبداً، حتى لو كان الهامش 0!
    return Positioned(
      left: 0,
      right: 0,
      top: layout.top,       
      bottom: layout.bottom, 
      child: IgnorePointer(
        child: Padding(
          padding: layout.padding,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.maxWidth),
              child: textWidget,
            ),
          ),
        ),
      ),
    );
  }
}
