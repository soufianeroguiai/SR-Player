import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';
import '../screens/player/subtitle_style_builder.dart';
import '../services/subtitle_layout_engine.dart';
import '../services/subtitle_service.dart';

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
    if (currentEntry == null || !visible || !settings.autoShow) {
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

    Widget textWidget = AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: textStyle,
      textAlign: textAlign,
      maxLines: settings.autoWrap ? settings.maxLines : 1,
      overflow: TextOverflow.ellipsis,
      child: Text(
        currentEntry!.text,
        textAlign: textAlign,
        maxLines: settings.autoWrap ? settings.maxLines : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (settings.bgOpacity > 0) {
      textWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: settings.bgColor.withOpacity(settings.bgOpacity),
          borderRadius: BorderRadius.circular(settings.bgBorderRadius),
        ),
        child: textWidget,
      );
    }

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