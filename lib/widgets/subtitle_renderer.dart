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
    if (currentEntry == null || !visible || currentEntry!.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // حساب الموضع
    final layout = SubtitleLayoutEngine.calculate(
      settings: settings,
      videoSize: videoSize,
      screenSize: screenSize,
      safeArea: safeArea,
    );

    final double bottomPosition = layout.position.dy.clamp(0.0, screenSize.height);

    // بناء النمط الأساسي
    TextStyle textStyle = buildSubtitleTextStyle(settings);

    // إجراء الأمان: إذا كانت bgOpacity == 0، نضمن عدم وجود لون خلفية في النص نفسه
    if (settings.bgOpacity == 0) {
      textStyle = textStyle.copyWith(backgroundColor: Colors.transparent);
    }

    // تأكيد حجم ولون ظاهرين احتياطياً
    if (textStyle.fontSize == null || textStyle.fontSize! < 12) {
      textStyle = textStyle.copyWith(fontSize: 22);
    }
    if (textStyle.color?.alpha == 0) {
      textStyle = textStyle.copyWith(color: Colors.white);
    }

    final textAlign = buildSubtitleTextAlign(settings);

    String displayText = currentEntry!.text;
    if (settings.ignoreAssEffects) {
      displayText = displayText.replaceAll(RegExp(r'\{.*?\}'), '');
    }

    Widget textWidget = Text(
      displayText,
      style: textStyle,
      textAlign: textAlign,
      maxLines: settings.autoWrap ? settings.maxLines : 1,
      overflow: TextOverflow.ellipsis,
    );

    // الخلفية المخصصة (الحاوية) لا تظهر إلا إذا bgOpacity > 0
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

    final horizontalPadding = buildSubtitlePadding(settings);
    final effectivePadding = EdgeInsets.only(
      left: horizontalPadding.left,
      right: horizontalPadding.right,
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPosition,
      child: IgnorePointer(
        child: Padding(
          padding: effectivePadding,
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