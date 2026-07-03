import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';
import '../services/subtitle_service.dart';
import '../services/subtitle_parser.dart';
import '../screens/player/subtitle_style_builder.dart';
import '../services/subtitle_layout_engine.dart';

class SubtitleRenderer extends StatelessWidget {
  final SubtitleEntry? currentEntry;
  final SubtitleSettings settings;
  final Rect videoRect;
  final Size videoSize;
  final Size screenSize;
  final EdgeInsets safeArea;
  final bool visible;

  const SubtitleRenderer({
    super.key,
    required this.currentEntry,
    required this.settings,
    required this.videoRect,
    required this.videoSize,
    required this.screenSize,
    required this.safeArea,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    // التنظيف عبر الـ Parser المنفصل
    final displayText = SubtitleParser.clean(
      currentEntry?.text,
      ignoreAssEffects: settings.ignoreAssEffects,
    );

    if (!visible || !settings.autoShow || displayText.isEmpty) {
      return const SizedBox.shrink();
    }

    final layout = SubtitleLayoutEngine.calculate(
      settings: settings,
      videoSize: videoSize,
      videoRect: videoRect,
      screenSize: screenSize,
      safeArea: safeArea,
    );

    final textStyle = buildSubtitleTextStyle(settings).copyWith(fontSize: layout.fontSize);

    // بناء Span النص (جاهز للتوسعة لاحقاً)
    final textSpan = TextSpan(
      text: displayText,
      style: textStyle,
    );

    Widget textWidget = Directionality(
      textDirection: Directionality.of(context), // يحترم اتجاه التطبيق (RTL) ولا يكسر الإنجليزية
      child: RichText(
        text: textSpan,
        textAlign: layout.textAlign,
        maxLines: settings.autoWrap ? settings.maxLines : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    // خلفية
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

    // الهيكل النهائي: الترجمة داخل مستطيل الفيديو، مع قص للحدود لتجنب تسرب الظلال
    return Positioned(
      left: videoRect.left,
      top: videoRect.top,
      width: videoRect.width,
      height: videoRect.height,
      child: ClipRect(
        child: Align(
          alignment: layout.alignment,
          child: Padding(
            padding: layout.padding,
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