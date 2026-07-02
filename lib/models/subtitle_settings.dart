import 'package:flutter/material.dart';

enum SubtitlePosition { top, center, bottom }
enum SubtitleAlignment { right, center, left }

class SubtitleSettings {
  // 1. المظهر (Appearance)
  final double fontSize;
  final String fontFamily;
  final Color textColor;
  final int fontWeightIndex;
  final Color outlineColor;
  final double outlineWidth;
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowOpacity;
  final Color bgColor;
  final double bgOpacity;
  final double bgBorderRadius;
  final double letterSpacing;
  final double lineHeight;

  // 2. الموضع (Position)
  final SubtitlePosition position;
  final double bottomMargin; // رفع الترجمة
  final SubtitleAlignment alignment;
  final double horizontalMargin;
  final double verticalMargin;
  final bool respectNotch;

  // 3. السلوك (Behavior)
  final bool scaleWithVideo;
  final bool autoShow;
  final String autoLanguage;
  final bool loadLastUsed;
  final bool hideWhenNoDialog; // لترجمات SSA

  // 4. التوافق (Rendering)
  final bool improveAnimation;
  final bool complexTextRendering;
  final bool improveSsaAss;
  final bool ignoreAssFonts;
  final bool ignoreAssEffects;
  final bool fullUnicodeRtlSupport;
  final bool improveAntiAliasing;
  final bool hdrSupport;

  SubtitleSettings({
    this.fontSize = 30.0,
    this.fontFamily = 'Roboto',
    this.textColor = const Color(0xFFFFFFFF),
    this.fontWeightIndex = 2,
    this.outlineColor = const Color(0xFF000000),
    this.outlineWidth = 2.0,
    this.shadowEnabled = false,
    this.shadowColor = const Color(0xFF000000),
    this.shadowOpacity = 0.5,
    this.bgColor = const Color(0xFF000000),
    this.bgOpacity = 0.0,
    this.bgBorderRadius = 4.0,
    this.letterSpacing = 0.0,
    this.lineHeight = 1.2,
    this.position = SubtitlePosition.bottom,
    this.bottomMargin = 48.0,
    this.alignment = SubtitleAlignment.center,
    this.horizontalMargin = 24.0,
    this.verticalMargin = 24.0,
    this.respectNotch = true,
    this.scaleWithVideo = true,
    this.autoShow = true,
    this.autoLanguage = 'ara',
    this.loadLastUsed = true,
    this.hideWhenNoDialog = false,
    this.improveAnimation = true,
    this.complexTextRendering = true,
    this.improveSsaAss = true,
    this.ignoreAssFonts = false,
    this.ignoreAssEffects = false,
    this.fullUnicodeRtlSupport = true,
    this.improveAntiAliasing = true,
    this.hdrSupport = false,
  });

  SubtitleSettings copyWith({
    double? fontSize,
    String? fontFamily,
    Color? textColor,
    int? fontWeightIndex,
    Color? outlineColor,
    double? outlineWidth,
    bool? shadowEnabled,
    Color? shadowColor,
    double? shadowOpacity,
    Color? bgColor,
    double? bgOpacity,
    double? bgBorderRadius,
    double? letterSpacing,
    double? lineHeight,
    SubtitlePosition? position,
    double? bottomMargin,
    SubtitleAlignment? alignment,
    double? horizontalMargin,
    double? verticalMargin,
    bool? respectNotch,
    bool? scaleWithVideo,
    bool? autoShow,
    String? autoLanguage,
    bool? loadLastUsed,
    bool? hideWhenNoDialog,
    bool? improveAnimation,
    bool? complexTextRendering,
    bool? improveSsaAss,
    bool? ignoreAssFonts,
    bool? ignoreAssEffects,
    bool? fullUnicodeRtlSupport,
    bool? improveAntiAliasing,
    bool? hdrSupport,
  }) {
    return SubtitleSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      fontWeightIndex: fontWeightIndex ?? this.fontWeightIndex,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      bgColor: bgColor ?? this.bgColor,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      bgBorderRadius: bgBorderRadius ?? this.bgBorderRadius,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      position: position ?? this.position,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      alignment: alignment ?? this.alignment,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      verticalMargin: verticalMargin ?? this.verticalMargin,
      respectNotch: respectNotch ?? this.respectNotch,
      scaleWithVideo: scaleWithVideo ?? this.scaleWithVideo,
      autoShow: autoShow ?? this.autoShow,
      autoLanguage: autoLanguage ?? this.autoLanguage,
      loadLastUsed: loadLastUsed ?? this.loadLastUsed,
      hideWhenNoDialog: hideWhenNoDialog ?? this.hideWhenNoDialog,
      improveAnimation: improveAnimation ?? this.improveAnimation,
      complexTextRendering: complexTextRendering ?? this.complexTextRendering,
      improveSsaAss: improveSsaAss ?? this.improveSsaAss,
      ignoreAssFonts: ignoreAssFonts ?? this.ignoreAssFonts,
      ignoreAssEffects: ignoreAssEffects ?? this.ignoreAssEffects,
      fullUnicodeRtlSupport: fullUnicodeRtlSupport ?? this.fullUnicodeRtlSupport,
      improveAntiAliasing: improveAntiAliasing ?? this.improveAntiAliasing,
      hdrSupport: hdrSupport ?? this.hdrSupport,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'textColor': textColor.value,
      'fontWeightIndex': fontWeightIndex,
      'outlineColor': outlineColor.value,
      'outlineWidth': outlineWidth,
      'shadowEnabled': shadowEnabled,
      'shadowColor': shadowColor.value,
      'shadowOpacity': shadowOpacity,
      'bgColor': bgColor.value,
      'bgOpacity': bgOpacity,
      'bgBorderRadius': bgBorderRadius,
      'letterSpacing': letterSpacing,
      'lineHeight': lineHeight,
      'position': position.index,
      'bottomMargin': bottomMargin,
      'alignment': alignment.index,
      'horizontalMargin': horizontalMargin,
      'verticalMargin': verticalMargin,
      'respectNotch': respectNotch,
      'scaleWithVideo': scaleWithVideo,
      'autoShow': autoShow,
      'autoLanguage': autoLanguage,
      'loadLastUsed': loadLastUsed,
      'hideWhenNoDialog': hideWhenNoDialog,
      'improveAnimation': improveAnimation,
      'complexTextRendering': complexTextRendering,
      'improveSsaAss': improveSsaAss,
      'ignoreAssFonts': ignoreAssFonts,
      'ignoreAssEffects': ignoreAssEffects,
      'fullUnicodeRtlSupport': fullUnicodeRtlSupport,
      'improveAntiAliasing': improveAntiAliasing,
      'hdrSupport': hdrSupport,
    };
  }

  factory SubtitleSettings.fromMap(Map<String, dynamic> map) {
    return SubtitleSettings(
      fontSize: map['fontSize'] ?? 30.0,
      fontFamily: map['fontFamily'] ?? 'Roboto',
      textColor: Color(map['textColor'] ?? 0xFFFFFFFF),
      fontWeightIndex: map['fontWeightIndex'] ?? 2,
      outlineColor: Color(map['outlineColor'] ?? 0xFF000000),
      outlineWidth: map['outlineWidth'] ?? 2.0,
      shadowEnabled: map['shadowEnabled'] ?? false,
      shadowColor: Color(map['shadowColor'] ?? 0xFF000000),
      shadowOpacity: map['shadowOpacity'] ?? 0.5,
      bgColor: Color(map['bgColor'] ?? 0xFF000000),
      bgOpacity: map['bgOpacity'] ?? 0.0,
      bgBorderRadius: map['bgBorderRadius'] ?? 4.0,
      letterSpacing: map['letterSpacing'] ?? 0.0,
      lineHeight: map['lineHeight'] ?? 1.2,
      position: SubtitlePosition.values[map['position'] ?? 2],
      bottomMargin: map['bottomMargin'] ?? 48.0,
      alignment: SubtitleAlignment.values[map['alignment'] ?? 1],
      horizontalMargin: map['horizontalMargin'] ?? 24.0,
      verticalMargin: map['verticalMargin'] ?? 24.0,
      respectNotch: map['respectNotch'] ?? true,
      scaleWithVideo: map['scaleWithVideo'] ?? true,
      autoShow: map['autoShow'] ?? true,
      autoLanguage: map['autoLanguage'] ?? 'ara',
      loadLastUsed: map['loadLastUsed'] ?? true,
      hideWhenNoDialog: map['hideWhenNoDialog'] ?? false,
      improveAnimation: map['improveAnimation'] ?? true,
      complexTextRendering: map['complexTextRendering'] ?? true,
      improveSsaAss: map['improveSsaAss'] ?? true,
      ignoreAssFonts: map['ignoreAssFonts'] ?? false,
      ignoreAssEffects: map['ignoreAssEffects'] ?? false,
      fullUnicodeRtlSupport: map['fullUnicodeRtlSupport'] ?? true,
      improveAntiAliasing: map['improveAntiAliasing'] ?? true,
      hdrSupport: map['hdrSupport'] ?? false,
    );
  }
}
