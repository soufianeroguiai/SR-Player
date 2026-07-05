import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';
import '../services/subtitle_service.dart';
import '../screens/player/subtitle_style_builder.dart';
import '../services/subtitle_layout_engine.dart';

class SubtitleRenderer extends StatefulWidget {
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
  State<SubtitleRenderer> createState() => _SubtitleRendererState();
}

class _SubtitleRendererState extends State<SubtitleRenderer> {
  late SubtitleSettings _cachedSettings;
  late TextStyle _cachedTextStyle;

  @override
  void initState() {
    super.initState();
    _cachedSettings = widget.settings;
    _cachedTextStyle = buildSubtitleTextStyle(_cachedSettings);
  }

  @override
  void didUpdateWidget(covariant SubtitleRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings != widget.settings) {
      _cachedSettings = widget.settings;
      _cachedTextStyle = buildSubtitleTextStyle(_cachedSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.currentEntry?.text ?? '';

    if (!widget.visible || !widget.settings.autoShow || displayText.isEmpty) {
      return const SizedBox.shrink();
    }

    final layout = SubtitleLayoutEngine.calculate(
      settings: widget.settings,
      videoSize: widget.videoSize,
      videoRect: widget.videoRect,
      screenSize: widget.screenSize,
      safeArea: widget.safeArea,
    );

    final textStyle = _cachedTextStyle.copyWith(fontSize: layout.fontSize);

    final textSpan = TextSpan(
      text: displayText,
      style: textStyle,
    );

    Widget textWidget = Directionality(
      textDirection: Directionality.of(context),
      child: RichText(
        text: textSpan,
        textAlign: layout.textAlign,
        maxLines: widget.settings.autoWrap ? widget.settings.maxLines : 1,
        overflow: TextOverflow.ellipsis,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
    );

    if (widget.settings.bgOpacity > 0) {
      double radius;
      switch (widget.settings.bgShape) {
        case SubtitleBgShape.rectangle:
          radius = 0;
          break;
        case SubtitleBgShape.capsule:
          radius = 100;
          break;
        case SubtitleBgShape.rounded:
        default:
          radius = widget.settings.bgBorderRadius;
      }
      textWidget = Container(
        padding: EdgeInsets.all(widget.settings.bgPadding),
        decoration: BoxDecoration(
          color: widget.settings.bgColor.withValues(alpha: widget.settings.bgOpacity),
          borderRadius: BorderRadius.circular(radius),
          border: widget.settings.bgBorderWidth > 0
              ? Border.all(color: widget.settings.bgBorderColor, width: widget.settings.bgBorderWidth)
              : null,
        ),
        child: textWidget,
      );
    }

    return Positioned(
      left: widget.videoRect.left,
      top: widget.videoRect.top,
      width: widget.videoRect.width,
      height: widget.videoRect.height,
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