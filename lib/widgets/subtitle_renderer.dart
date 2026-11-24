import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';
import '../services/subtitle_service.dart';
import '../screens/player/subtitle_style_builder.dart';
import '../services/subtitle_layout_engine.dart';

// ─────────────────────────────────────────────────────────────────────
// ✅ إصلاح اتجاه الترجمة العربية (RTL):
// واجهة المشغّل كلها LTR، فكان Flutter يعتبر اتجاه الفقرة LTR، وعندها تنتقل
// علامات الترقيم في آخر الجملة (! . ؟) إلى بدايتها. الحل: تحديد الاتجاه من
// أول حرف قوي في النص، وإضافة علامة RLM في طرفي كل سطر عربي.
// ─────────────────────────────────────────────────────────────────────
final RegExp _rtlRegExp = RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]');
final RegExp _ltrRegExp =
    RegExp(r'[A-Za-z\u00C0-\u024F\u0370-\u03FF\u0400-\u04FF]');

/// true = RTL، false = LTR، null = لا توجد أحرف قوية (أرقام/رموز فقط)
bool? _firstStrongIsRtl(String text) {
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    if (_rtlRegExp.hasMatch(ch)) return true;
    if (_ltrRegExp.hasMatch(ch)) return false;
  }
  return null;
}

String _fixBidiLines(String text) {
  const rlm = '\u200F';
  return text.split('\n').map((line) {
    if (line.trim().isEmpty) return line;
    return _firstStrongIsRtl(line) == true ? '$rlm$line$rlm' : line;
  }).join('\n');
}

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

    final isRtl = _firstStrongIsRtl(displayText);
    final TextDirection textDir = isRtl == null
        ? Directionality.of(context)
        : (isRtl ? TextDirection.rtl : TextDirection.ltr);

    final textSpan = TextSpan(
      text: _fixBidiLines(displayText),
      style: textStyle,
    );

    Widget textWidget = Directionality(
      textDirection: textDir,
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
              // ✅ RepaintBoundary هنا فقط، حول الصندوق الصغير الذي يحتوي فعليًا
              // على النص — وليس حول الـ Positioned الكبير بحجم الفيديو كامل،
              // لتجنّب تخصيص طبقة تركيب بحجم الشاشة تظهر رمادية جزئيًا.
              child: RepaintBoundary(
                child: textWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}