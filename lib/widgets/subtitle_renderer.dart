import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart'; // تأكد من مسار الملف
import '../services/subtitle_service.dart'; // تأكد من مسار الملف
import '../screens/player/subtitle_style_builder.dart'; // تأكد من مسار الملف
import '../services/subtitle_layout_engine.dart'; // تأكد من مسار الملف

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
    // ميزة: إخفاء الترجمة عند عدم وجود حوار تعمل هنا تلقائياً
    if (currentEntry == null || !visible || !settings.autoShow || currentEntry!.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final layout = SubtitleLayoutEngine.calculate(
      settings: settings,
      videoSize: videoSize,
      screenSize: screenSize,
      safeArea: safeArea,
    );

    final textStyle = buildSubtitleTextStyle(settings).copyWith(
      fontSize: layout.fontSize,
    );

    final padding = buildSubtitlePadding(settings);
    final textAlign = buildSubtitleTextAlign(settings);

    // 🌟 السحر هنا: تنظيف النص من أكواد ASS إذا فعل المستخدم خيار "تجاهل تأثيرات ASS"
    String displayText = currentEntry!.text;
    if (settings.ignoreAssEffects) {
      // يمسح أي كود بين أقواس معقوفة مثل {\an8} أو {\c&H0000FF&}
      displayText = displayText.replaceAll(RegExp(r'\{.*?\}'), '');
    }

    Widget textWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: textStyle,
      textAlign: textAlign,
      maxLines: settings.autoWrap ? settings.maxLines : 1,
      overflow: TextOverflow.ellipsis,
      child: Text(
        displayText,
        textAlign: textAlign,
        maxLines: settings.autoWrap ? settings.maxLines : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    // بناء خلفية الترجمة (شكل الخلفية، الحدود، Padding)
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
        padding: EdgeInsets.all(settings.bgPadding), // الـ Padding الذي اخترته من الإعدادات
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

    // ✅ الإصلاح الجذري لمشكلة اللمس: Positioned هي الأساس
    return Positioned(
      left: 0,
      right: 0,
      bottom: layout.position.dy,
      child: IgnorePointer(
        child: Padding(
          padding: padding,
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
