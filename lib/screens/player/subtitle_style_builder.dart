import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/subtitle_settings.dart';

/// يبني [TextStyle] الترجمة النهائية من إعدادات [SubtitleSettings].
TextStyle buildSubtitleTextStyle(SubtitleSettings s) {
  final shadows = <Shadow>[];

  // 1. إضافة الحدود (Outline) عبر الظلال المتعددة
  if (s.outlineWidth > 0) {
    const steps = 8;
    for (var i = 0; i < steps; i++) {
      final angle = (2 * math.pi / steps) * i;
      shadows.add(Shadow(
        color: s.outlineColor,
        offset: Offset(
          math.cos(angle) * s.outlineWidth,
          math.sin(angle) * s.outlineWidth,
        ),
        blurRadius: s.improveAntiAliasing ? 0.5 : 0.0, // تنعيم أطراف الحدود
      ));
    }
  }

  // 2. إضافة ظل النص (Drop Shadow)
  if (s.shadowEnabled) {
    shadows.add(Shadow(
      color: s.shadowColor.withOpacity(s.shadowOpacity),
      offset: const Offset(2.0, 2.0),
      blurRadius: 4.0,
    ));
  }

  final baseStyle = TextStyle(
    fontSize: s.fontSize,
    color: s.textColor,
    fontWeight: _fontWeight(s.fontWeightIndex),
    letterSpacing: s.letterSpacing,
    height: s.lineHeight,
    backgroundColor: s.bgOpacity > 0 ? s.bgColor.withOpacity(s.bgOpacity) : null,
    shadows: shadows.isEmpty ? null : shadows,
  );

  // إذا كان الخط من خطوط النظام الافتراضية
  if (_isBuiltInFont(s.fontFamily)) {
    return baseStyle.copyWith(fontFamily: s.fontFamily == 'Roboto' ? null : s.fontFamily);
  }

  // جلب الخطوط المخصصة (عبر مكتبة Google Fonts)
  try {
    return GoogleFonts.getFont(s.fontFamily, textStyle: baseStyle);
  } catch (_) {
    return baseStyle; // الرجوع للخط الافتراضي عند الفشل
  }
}

/// يحدد محاذاة النص بناءً على الإعدادات (يمين، يسار، وسط)
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

/// يبني الهوامش بناءً على موقع الترجمة والإعدادات الخاصة بالمستخدم
EdgeInsets buildSubtitlePadding(SubtitleSettings s) {
  double top = s.verticalMargin;
  double bottom = s.bottomMargin; // استخدام bottomMargin كرفع أساسي من الأسفل
  
  // تعديل الهوامش العمودية بناءً على الموضع
  if (s.position == SubtitlePosition.top) {
    bottom = 0;
  } else if (s.position == SubtitlePosition.center) {
    top = 0;
    bottom = 0; // يتم توسيطه عبر واجهة المشغل الخارجية
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

// ─────────── دوال مساعدة ───────────

bool _isBuiltInFont(String font) {
  const builtIn = {'Roboto', 'monospace', 'sans-serif'};
  return builtIn.contains(font);
}

FontWeight _fontWeight(int index) {
  switch (index) {
    case 0: return FontWeight.w300; // خفيف
    case 1: return FontWeight.normal; // عادي
    case 2: return FontWeight.w600; // شبه عريض
    case 3: return FontWeight.w800; // عريض جداً
    default: return FontWeight.normal;
  }
}
