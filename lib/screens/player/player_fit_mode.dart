import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

enum VideoFitMode { contain, cover, fill, stretch }

BoxFit getBoxFit(VideoFitMode mode) {
  switch (mode) {
    case VideoFitMode.contain:
      return BoxFit.contain;
    case VideoFitMode.cover:
      return BoxFit.cover;
    case VideoFitMode.fill:
      return BoxFit.fill;
    case VideoFitMode.stretch:
      return BoxFit.fill;
  }
}

String modeName(VideoFitMode mode, AppLocalizations t) {
  switch (mode) {
    case VideoFitMode.contain:
      return t.contain;
    case VideoFitMode.cover:
      return t.cover;
    case VideoFitMode.fill:
      return t.fill;
    case VideoFitMode.stretch:
      return t.stretch;
  }
}

/// نفس التعيين المستعمل فقائمة اختيار وضع الملء فـ player_settings_panel.dart
/// - مركزي هنا حتى يبقى زر شريط التحكم السفلي (PlayerBottomBar) متطابقاً
/// دائماً مع نفس الأيقونة، بدل تكرار المنطق فمكانين قد ينفصلا لاحقاً.
IconData modeIcon(VideoFitMode mode) {
  switch (mode) {
    case VideoFitMode.contain:
      return Symbols.fit_screen_rounded;
    case VideoFitMode.cover:
      return Symbols.fullscreen_rounded;
    case VideoFitMode.fill:
      return Symbols.aspect_ratio_rounded;
    case VideoFitMode.stretch:
      return Symbols.zoom_out_map_rounded;
  }
}

class VideoFitSettings {
  static const _key = 'video_fit_mode';

  static Future<void> save(VideoFitMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }

  static Future<VideoFitMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    if (index < 0 || index >= VideoFitMode.values.length) {
      return VideoFitMode.contain;
    }
    return VideoFitMode.values[index];
  }
}