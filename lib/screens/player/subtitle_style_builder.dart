import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/subtitle_settings.dart';

TextStyle buildSubtitleTextStyle(SubtitleSettings s) {
  final shadows = <Shadow>[];

  if (s.outlineWidth > 0) {
    final effectiveOutline = s.outlineWidth * s.outlineScale;
    const steps = 16;
    for (var i = 0; i < steps; i++) {
      final angle = (2 * math.pi / steps) * i;
      shadows.add(Shadow(
        color: s.outlineColor,
        offset: Offset(
          math.cos(angle) * effectiveOutline,
          math.sin(angle) * effectiveOutline,
        ),
        blurRadius: s.improveAntiAliasing ? 0.5 : 0.0,
      ));
    }
  }

  if (s.shadowEnabled) {
    shadows.add(Shadow(
      color: s.shadowColor.withOpacity(s.shadowOpacity),
      offset: Offset(s.shadowOffsetX, s.shadowOffsetY),
      blurRadius: s.shadowBlurRadius,
    ));
  }

  final effectiveFontSize = s.fontSize * s.subtitleScale;
  final effectiveHeight = s.lineHeight + (s.lineSpacing - 1.0);

  final baseStyle = TextStyle(
    fontSize: effectiveFontSize,
    color: s.textColor.withOpacity(s.textOpacity),
    fontWeight: _fontWeight(s.fontWeightIndex),
    letterSpacing: s.letterSpacing,
    wordSpacing: s.wordSpacing,
    height: effectiveHeight > 0 ? effectiveHeight : null,
    backgroundColor: s.bgOpacity > 0 ? s.bgColor.withOpacity(s.bgOpacity) : null,
    shadows: shadows.isEmpty ? null : shadows,
  );

  if (_isBuiltInFont(s.fontFamily)) {
    return baseStyle.copyWith(fontFamily: s.fontFamily == 'Roboto' ? null : s.fontFamily);
  }

  try {
    return GoogleFonts.getFont(s.fontFamily, textStyle: baseStyle);
  } catch (_) {
    return baseStyle;
  }
}

TextAlign buildSubtitleTextAlign(SubtitleSettings s) {
  switch (s.alignment) {
    case SubtitleAlignment.right:
      return TextAlign.right;
    case SubtitleAlignment.left:
      return TextAlign.left;
    case SubtitleAlignment.center:
    default:
      return TextAlign.center;
  }
}

EdgeInsets buildSubtitlePadding(SubtitleSettings s) {
  double top = s.verticalMargin;
  double bottom = s.bottomMargin;

  bottom += s.safeAreaPadding;
  top += s.safeAreaPadding;

  if (s.position == SubtitlePosition.top) {
    bottom = 0;
  } else if (s.position == SubtitlePosition.center) {
    top = 0;
    bottom = 0;
  } else {
    top = 0;
  }

  return EdgeInsets.only(
    left: s.horizontalMargin,
    right: s.horizontalMargin,
    top: top,
    bottom: bottom,
  );
}

int? getMaxLines(SubtitleSettings s) {
  if (!s.autoWrap) return 1;
  return s.maxLines;
}

bool _isBuiltInFont(String font) {
  const builtIn = {'Roboto', 'monospace', 'sans-serif'};
  return builtIn.contains(font);
}

FontWeight _fontWeight(int index) {
  switch (index) {
    case 0: return FontWeight.w300;
    case 1: return FontWeight.normal;
    case 2: return FontWeight.w600;
    case 3: return FontWeight.w800;
    default: return FontWeight.normal;
  }
}