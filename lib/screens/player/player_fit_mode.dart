import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

enum VideoFitMode { contain, cover, fill, stretch, free }

BoxFit getBoxFit(VideoFitMode mode) {
  switch (mode) {
    case VideoFitMode.contain:
    case VideoFitMode.free:
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
    case VideoFitMode.free:
      return t.free;
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