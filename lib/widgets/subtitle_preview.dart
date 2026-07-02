import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';
import '../screens/player/subtitle_style_builder.dart';

class SubtitlePreview extends StatelessWidget {
  final SubtitleSettings settings;
  final String text;

  const SubtitlePreview({
    super.key,
    required this.settings,
    this.text = 'مرحباً بك في SR Player',
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = buildSubtitleTextStyle(settings);
    final textAlign = buildSubtitleTextAlign(settings);

    Widget textWidget = Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: settings.autoWrap ? settings.maxLines : 1,
      overflow: TextOverflow.ellipsis,
    );

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
      ),
      child: Center(child: textWidget),
    );
  }
}