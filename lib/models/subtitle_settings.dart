import 'package:flutter/material.dart';

enum SubtitlePosition { top, center, bottom }
enum SubtitleAlignment { right, center, left }
enum SubtitleScaleMode { fixed, byResolution, byWindow, smart }
enum SubtitleBgShape { rectangle, rounded, capsule }

class SubtitleSettings {
  final double fontSize;
  final double subtitleScale;
  final String fontFamily;
  final Color textColor;
  final double textOpacity;
  final int fontWeightIndex;
  final Color outlineColor;
  final double outlineWidth;
  final double outlineScale;
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowOpacity;
  final double shadowOffsetX;
  final double shadowOffsetY;
  final double shadowBlurRadius;
  final Color bgColor;
  final double bgOpacity;
  final double bgBorderRadius;
  final Color bgBorderColor;
  final double bgBorderWidth;
  final double bgPadding;
  final SubtitleBgShape bgShape;
  final double letterSpacing;
  final double wordSpacing;
  final double lineHeight;
  final double lineSpacing;
  final bool autoWrap;
  final int maxLines;
  final SubtitlePosition position;
  final double bottomMargin;
  final SubtitleAlignment alignment;
  final double horizontalMargin;
  final double verticalMargin;
  final double safeAreaPadding;
  final bool respectNotch;
  final bool keepInsideVideo;
  final SubtitleScaleMode scaleMode;
  final bool autoShow;
  final String autoLanguage;
  final bool loadLastUsed;
  final bool hideWhenNoDialog;
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
    this.subtitleScale = 1.0,
    this.fontFamily = 'Roboto',
    this.textColor = const Color(0xFFFFFFFF),
    this.textOpacity = 1.0,
    this.fontWeightIndex = 2,
    this.outlineColor = const Color(0xFF000000),
    this.outlineWidth = 2.0,
    this.outlineScale = 1.0,
    this.shadowEnabled = false,
    this.shadowColor = const Color(0xFF000000),
    this.shadowOpacity = 0.5,
    this.shadowOffsetX = 2.0,
    this.shadowOffsetY = 2.0,
    this.shadowBlurRadius = 4.0,
    this.bgColor = const Color(0xFF000000),
    this.bgOpacity = 0.0,
    this.bgBorderRadius = 4.0,
    this.bgBorderColor = const Color(0xFFFFFFFF),
    this.bgBorderWidth = 0.0,
    this.bgPadding = 8.0,
    this.bgShape = SubtitleBgShape.rounded,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,
    this.lineHeight = 1.2,
    this.lineSpacing = 1.0,
    this.autoWrap = true,
    this.maxLines = 2,
    this.position = SubtitlePosition.bottom,
    this.bottomMargin = 48.0,
    this.alignment = SubtitleAlignment.center,
    this.horizontalMargin = 24.0,
    this.verticalMargin = 24.0,
    this.safeAreaPadding = 20.0,
    this.respectNotch = true,
    this.keepInsideVideo = true,
    this.scaleMode = SubtitleScaleMode.smart,
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
    double? subtitleScale,
    String? fontFamily,
    Color? textColor,
    double? textOpacity,
    int? fontWeightIndex,
    Color? outlineColor,
    double? outlineWidth,
    double? outlineScale,
    bool? shadowEnabled,
    Color? shadowColor,
    double? shadowOpacity,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlurRadius,
    Color? bgColor,
    double? bgOpacity,
    double? bgBorderRadius,
    Color? bgBorderColor,
    double? bgBorderWidth,
    double? bgPadding,
    SubtitleBgShape? bgShape,
    double? letterSpacing,
    double? wordSpacing,
    double? lineHeight,
    double? lineSpacing,
    bool? autoWrap,
    int? maxLines,
    SubtitlePosition? position,
    double? bottomMargin,
    SubtitleAlignment? alignment,
    double? horizontalMargin,
    double? verticalMargin,
    double? safeAreaPadding,
    bool? respectNotch,
    bool? keepInsideVideo,
    SubtitleScaleMode? scaleMode,
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
      subtitleScale: subtitleScale ?? this.subtitleScale,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      textOpacity: textOpacity ?? this.textOpacity,
      fontWeightIndex: fontWeightIndex ?? this.fontWeightIndex,
      outlineColor: outlineColor ?? this.outlineColor,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      outlineScale: outlineScale ?? this.outlineScale,
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOpacity: shadowOpacity ?? this.shadowOpacity,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      bgColor: bgColor ?? this.bgColor,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      bgBorderRadius: bgBorderRadius ?? this.bgBorderRadius,
      bgBorderColor: bgBorderColor ?? this.bgBorderColor,
      bgBorderWidth: bgBorderWidth ?? this.bgBorderWidth,
      bgPadding: bgPadding ?? this.bgPadding,
      bgShape: bgShape ?? this.bgShape,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      autoWrap: autoWrap ?? this.autoWrap,
      maxLines: maxLines ?? this.maxLines,
      position: position ?? this.position,
      bottomMargin: bottomMargin ?? this.bottomMargin,
      alignment: alignment ?? this.alignment,
      horizontalMargin: horizontalMargin ?? this.horizontalMargin,
      verticalMargin: verticalMargin ?? this.verticalMargin,
      safeAreaPadding: safeAreaPadding ?? this.safeAreaPadding,
      respectNotch: respectNotch ?? this.respectNotch,
      keepInsideVideo: keepInsideVideo ?? this.keepInsideVideo,
      scaleMode: scaleMode ?? this.scaleMode,
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
      'subtitleScale': subtitleScale,
      'fontFamily': fontFamily,
      'textColor': textColor.value,
      'textOpacity': textOpacity,
      'fontWeightIndex': fontWeightIndex,
      'outlineColor': outlineColor.value,
      'outlineWidth': outlineWidth,
      'outlineScale': outlineScale,
      'shadowEnabled': shadowEnabled,
      'shadowColor': shadowColor.value,
      'shadowOpacity': shadowOpacity,
      'shadowOffsetX': shadowOffsetX,
      'shadowOffsetY': shadowOffsetY,
      'shadowBlurRadius': shadowBlurRadius,
      'bgColor': bgColor.value,
      'bgOpacity': bgOpacity,
      'bgBorderRadius': bgBorderRadius,
      'bgBorderColor': bgBorderColor.value,
      'bgBorderWidth': bgBorderWidth,
      'bgPadding': bgPadding,
      'bgShape': bgShape.index,
      'letterSpacing': letterSpacing,
      'wordSpacing': wordSpacing,
      'lineHeight': lineHeight,
      'lineSpacing': lineSpacing,
      'autoWrap': autoWrap,
      'maxLines': maxLines,
      'position': position.index,
      'bottomMargin': bottomMargin,
      'alignment': alignment.index,
      'horizontalMargin': horizontalMargin,
      'verticalMargin': verticalMargin,
      'safeAreaPadding': safeAreaPadding,
      'respectNotch': respectNotch,
      'keepInsideVideo': keepInsideVideo,
      'scaleMode': scaleMode.index,
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
      subtitleScale: map['subtitleScale'] ?? 1.0,
      fontFamily: map['fontFamily'] ?? 'Roboto',
      textColor: Color(map['textColor'] ?? 0xFFFFFFFF),
      textOpacity: map['textOpacity'] ?? 1.0,
      fontWeightIndex: map['fontWeightIndex'] ?? 2,
      outlineColor: Color(map['outlineColor'] ?? 0xFF000000),
      outlineWidth: map['outlineWidth'] ?? 2.0,
      outlineScale: map['outlineScale'] ?? 1.0,
      shadowEnabled: map['shadowEnabled'] ?? false,
      shadowColor: Color(map['shadowColor'] ?? 0xFF000000),
      shadowOpacity: map['shadowOpacity'] ?? 0.5,
      shadowOffsetX: map['shadowOffsetX'] ?? 2.0,
      shadowOffsetY: map['shadowOffsetY'] ?? 2.0,
      shadowBlurRadius: map['shadowBlurRadius'] ?? 4.0,
      bgColor: Color(map['bgColor'] ?? 0xFF000000),
      bgOpacity: map['bgOpacity'] ?? 0.0,
      bgBorderRadius: map['bgBorderRadius'] ?? 4.0,
      bgBorderColor: Color(map['bgBorderColor'] ?? 0xFFFFFFFF),
      bgBorderWidth: map['bgBorderWidth'] ?? 0.0,
      bgPadding: map['bgPadding'] ?? 8.0,
      bgShape: SubtitleBgShape.values[map['bgShape'] ?? 1],
      letterSpacing: map['letterSpacing'] ?? 0.0,
      wordSpacing: map['wordSpacing'] ?? 0.0,
      lineHeight: map['lineHeight'] ?? 1.2,
      lineSpacing: map['lineSpacing'] ?? 1.0,
      autoWrap: map['autoWrap'] ?? true,
      maxLines: map['maxLines'] ?? 2,
      position: SubtitlePosition.values[map['position'] ?? 2],
      bottomMargin: map['bottomMargin'] ?? 48.0,
      alignment: SubtitleAlignment.values[map['alignment'] ?? 1],
      horizontalMargin: map['horizontalMargin'] ?? 24.0,
      verticalMargin: map['verticalMargin'] ?? 24.0,
      safeAreaPadding: map['safeAreaPadding'] ?? 20.0,
      respectNotch: map['respectNotch'] ?? true,
      keepInsideVideo: map['keepInsideVideo'] ?? true,
      scaleMode: SubtitleScaleMode.values[map['scaleMode'] ?? 3],
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