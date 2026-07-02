import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subtitle_settings.dart';

class SettingsProvider extends ChangeNotifier {
  SubtitleSettings _subtitleSettings = SubtitleSettings();
  SubtitleSettings get subtitleSettings => _subtitleSettings;

  void updateSubtitleSettings(SubtitleSettings newSettings) {
    _subtitleSettings = newSettings;
    notifyListeners();
    _save();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _rememberPosition = true;
  bool get rememberPosition => _rememberPosition;
  bool _autoPlay = true;
  bool get autoPlay => _autoPlay;
  double _defaultSpeed = 1.0;
  double get defaultSpeed => _defaultSpeed;

  String _hwDecoderMode = 'auto';
  String get hwDecoderMode => _hwDecoderMode;

  String _colorFormat = 'rgb_full';
  String get colorFormat => _colorFormat;

  double _defaultAudioBoost = 100.0;
  double get defaultAudioBoost => _defaultAudioBoost;
  String _preferredAudioLanguage = 'ara';
  String get preferredAudioLanguage => _preferredAudioLanguage;

  bool _showSubtitlesByDefault = true;
  bool get showSubtitlesByDefault => _showSubtitlesByDefault;
  void setShowSubtitlesByDefault(bool v) { _showSubtitlesByDefault = v; notifyListeners(); _save(); }

  String _subtitleFolder = '';
  String get subtitleFolder => _subtitleFolder;
  void setSubtitleFolder(String v) { _subtitleFolder = v; notifyListeners(); _save(); }

  String _subtitleEncoding = 'UTF-8';
  String get subtitleEncoding => _subtitleEncoding;
  void setSubtitleEncoding(String v) { _subtitleEncoding = v; notifyListeners(); _save(); }

  String _preferredSubtitleLanguage = 'ara';
  String get preferredSubtitleLanguage => _preferredSubtitleLanguage;
  void setPreferredSubtitleLanguage(String v) { _preferredSubtitleLanguage = v; notifyListeners(); _save(); }

  double _defaultSubtitleSync = 0.0;
  double get defaultSubtitleSync => _defaultSubtitleSync;
  void setDefaultSubtitleSync(double v) { _defaultSubtitleSync = v; notifyListeners(); _save(); }

  bool _subtitleItalic = false;
  bool get subtitleItalic => _subtitleItalic;
  void setSubtitleItalic(bool v) { _subtitleItalic = v; notifyListeners(); _save(); }

  bool _subtitleRTL = false;
  bool get subtitleRTL => _subtitleRTL;
  void setSubtitleRTL(bool v) { _subtitleRTL = v; notifyListeners(); _save(); }

  String _sortBy = 'date';
  String get sortBy => _sortBy;
  bool _sortDesc = true;
  bool get sortDesc => _sortDesc;
  bool _libraryGridView = false;
  bool get libraryGridView => _libraryGridView;
  bool _foldersGridView = false;
  bool get foldersGridView => _foldersGridView;
  bool _recentGridView = false;
  bool get recentGridView => _recentGridView;

  int _doubleTapSeekSeconds = 10;
  int get doubleTapSeekSeconds => _doubleTapSeekSeconds;

  int _themeSeedColorValue = 0xFF1B6CA8;
  Color get themeSeedColor => Color(_themeSeedColorValue);

  int _controlsHideSeconds = 4;
  int get controlsHideSeconds => _controlsHideSeconds;

  bool _longPressSpeedEnabled = true;
  bool get longPressSpeedEnabled => _longPressSpeedEnabled;
  double _longPressSpeedValue = 2.0;
  double get longPressSpeedValue => _longPressSpeedValue;

  double _gestureSensitivity = 1.0;
  double get gestureSensitivity => _gestureSensitivity;

  bool _silentResume = false;
  bool get silentResume => _silentResume;
  void setSilentResume(bool v) { _silentResume = v; notifyListeners(); _save(); }

  bool _autoPipOnBackground = false;
  bool get autoPipOnBackground => _autoPipOnBackground;
  void setAutoPipOnBackground(bool v) { _autoPipOnBackground = v; notifyListeners(); _save(); }

  bool _smartRotationEnabled = true;
  bool get smartRotationEnabled => _smartRotationEnabled;
  void setSmartRotationEnabled(bool v) { _smartRotationEnabled = v; notifyListeners(); _save(); }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final subtitleJsonString = p.getString('subtitleSettingsData');
    if (subtitleJsonString != null) {
      try {
        _subtitleSettings = SubtitleSettings.fromMap(json.decode(subtitleJsonString));
      } catch (e) {
        _subtitleSettings = SubtitleSettings();
      }
    }

    _themeMode = ThemeMode.values[p.getInt('themeMode') ?? 0];
    _rememberPosition = p.getBool('rememberPosition') ?? true;
    _autoPlay = p.getBool('autoPlay') ?? true;
    _defaultSpeed = p.getDouble('defaultSpeed') ?? 1.0;
    _defaultAudioBoost = p.getDouble('defaultAudioBoost') ?? 100.0;
    _preferredAudioLanguage = p.getString('preferredAudioLanguage') ?? 'ara';
    _showSubtitlesByDefault = p.getBool('showSubtitles') ?? true;
    _subtitleFolder = p.getString('subtitleFolder') ?? '';
    _subtitleEncoding = p.getString('subtitleEncoding') ?? 'UTF-8';
    _preferredSubtitleLanguage = p.getString('preferredSubtitleLanguage') ?? 'ara';
    _defaultSubtitleSync = p.getDouble('defaultSubtitleSync') ?? 0.0;
    _subtitleItalic = p.getBool('subtitleItalic') ?? false;
    _subtitleRTL = p.getBool('subtitleRTL') ?? false;
    _sortBy = p.getString('sortBy') ?? 'date';
    _sortDesc = p.getBool('sortDesc') ?? true;
    _libraryGridView = p.getBool('libraryGridView') ?? false;
    _foldersGridView = p.getBool('foldersGridView') ?? false;
    _recentGridView = p.getBool('recentGridView') ?? false;
    _hwDecoderMode = p.getString('hwDecoderMode') ?? 'auto';
    _colorFormat = p.getString('colorFormat') ?? 'rgb_full';
    _doubleTapSeekSeconds = p.getInt('doubleTapSeekSeconds') ?? 10;
    _themeSeedColorValue = p.getInt('themeSeedColorValue') ?? 0xFF1B6CA8;
    _controlsHideSeconds = p.getInt('controlsHideSeconds') ?? 4;
    _longPressSpeedEnabled = p.getBool('longPressSpeedEnabled') ?? true;
    _longPressSpeedValue = p.getDouble('longPressSpeedValue') ?? 2.0;
    _gestureSensitivity = p.getDouble('gestureSensitivity') ?? 1.0;
    _silentResume = p.getBool('silentResume') ?? false;
    _autoPipOnBackground = p.getBool('autoPipOnBackground') ?? false;
    _smartRotationEnabled = p.getBool('smartRotationEnabled') ?? true;

    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('subtitleSettingsData', json.encode(_subtitleSettings.toMap()));
    await p.setInt('themeMode', _themeMode.index);
    await p.setBool('rememberPosition', _rememberPosition);
    await p.setBool('autoPlay', _autoPlay);
    await p.setDouble('defaultSpeed', _defaultSpeed);
    await p.setDouble('defaultAudioBoost', _defaultAudioBoost);
    await p.setString('preferredAudioLanguage', _preferredAudioLanguage);
    await p.setBool('showSubtitles', _showSubtitlesByDefault);
    await p.setString('subtitleFolder', _subtitleFolder);
    await p.setString('subtitleEncoding', _subtitleEncoding);
    await p.setString('preferredSubtitleLanguage', _preferredSubtitleLanguage);
    await p.setDouble('defaultSubtitleSync', _defaultSubtitleSync);
    await p.setBool('subtitleItalic', _subtitleItalic);
    await p.setBool('subtitleRTL', _subtitleRTL);
    await p.setString('sortBy', _sortBy);
    await p.setBool('sortDesc', _sortDesc);
    await p.setBool('libraryGridView', _libraryGridView);
    await p.setBool('foldersGridView', _foldersGridView);
    await p.setBool('recentGridView', _recentGridView);
    await p.setString('hwDecoderMode', _hwDecoderMode);
    await p.setString('colorFormat', _colorFormat);
    await p.setInt('doubleTapSeekSeconds', _doubleTapSeekSeconds);
    await p.setInt('themeSeedColorValue', _themeSeedColorValue);
    await p.setInt('controlsHideSeconds', _controlsHideSeconds);
    await p.setBool('longPressSpeedEnabled', _longPressSpeedEnabled);
    await p.setDouble('longPressSpeedValue', _longPressSpeedValue);
    await p.setDouble('gestureSensitivity', _gestureSensitivity);
    await p.setBool('silentResume', _silentResume);
    await p.setBool('autoPipOnBackground', _autoPipOnBackground);
    await p.setBool('smartRotationEnabled', _smartRotationEnabled);
  }

  void resetAll() {
    _subtitleSettings = SubtitleSettings();
    _themeMode = ThemeMode.system;
    _rememberPosition = true;
    _autoPlay = true;
    _defaultSpeed = 1.0;
    _defaultAudioBoost = 100.0;
    _preferredAudioLanguage = 'ara';
    _showSubtitlesByDefault = true;
    _subtitleFolder = '';
    _subtitleEncoding = 'UTF-8';
    _preferredSubtitleLanguage = 'ara';
    _defaultSubtitleSync = 0.0;
    _subtitleItalic = false;
    _subtitleRTL = false;
    _sortBy = 'date';
    _sortDesc = true;
    _libraryGridView = false;
    _foldersGridView = false;
    _recentGridView = false;
    _hwDecoderMode = 'auto';
    _colorFormat = 'rgb_full';
    _doubleTapSeekSeconds = 10;
    _themeSeedColorValue = 0xFF1B6CA8;
    _controlsHideSeconds = 4;
    _longPressSpeedEnabled = true;
    _longPressSpeedValue = 2.0;
    _gestureSensitivity = 1.0;
    _silentResume = false;
    _autoPipOnBackground = false;
    _smartRotationEnabled = true;
    _save();
    notifyListeners();
  }

  void setThemeMode(ThemeMode v) { _themeMode = v; notifyListeners(); _save(); }
  void setRememberPosition(bool v) { _rememberPosition = v; notifyListeners(); _save(); }
  void setAutoPlay(bool v) { _autoPlay = v; notifyListeners(); _save(); }
  void setDefaultSpeed(double v) { _defaultSpeed = v; notifyListeners(); _save(); }
  void setDefaultAudioBoost(double v) { _defaultAudioBoost = v; notifyListeners(); _save(); }
  void setPreferredAudioLanguage(String v) { _preferredAudioLanguage = v; notifyListeners(); _save(); }
  void setSortBy(String v) { _sortBy = v; notifyListeners(); _save(); }
  void setSortDesc(bool v) { _sortDesc = v; notifyListeners(); _save(); }
  void setLibraryGridView(bool v) { _libraryGridView = v; notifyListeners(); _save(); }
  void setFoldersGridView(bool v) { _foldersGridView = v; notifyListeners(); _save(); }
  void setRecentGridView(bool v) { _recentGridView = v; notifyListeners(); _save(); }
  void setHwDecoderMode(String v) { _hwDecoderMode = v; notifyListeners(); _save(); }
  void setColorFormat(String v) { _colorFormat = v; notifyListeners(); _save(); }
  void setDoubleTapSeekSeconds(int v) { _doubleTapSeekSeconds = v; notifyListeners(); _save(); }
  void setThemeSeedColor(Color c) { _themeSeedColorValue = c.toARGB32(); notifyListeners(); _save(); }
  void setControlsHideSeconds(int v) { _controlsHideSeconds = v; notifyListeners(); _save(); }
  void setLongPressSpeedEnabled(bool v) { _longPressSpeedEnabled = v; notifyListeners(); _save(); }
  void setLongPressSpeedValue(double v) { _longPressSpeedValue = v; notifyListeners(); _save(); }
  void setGestureSensitivity(double v) { _gestureSensitivity = v; notifyListeners(); _save(); }

  Map<String, dynamic> exportToJson() {
    return {
      'subtitleSettings': _subtitleSettings.toMap(),
      'themeMode': _themeMode.index,
      'rememberPosition': _rememberPosition,
      'autoPlay': _autoPlay,
      'defaultSpeed': _defaultSpeed,
      'hwDecoderMode': _hwDecoderMode,
      'colorFormat': _colorFormat,
      'defaultAudioBoost': _defaultAudioBoost,
      'preferredAudioLanguage': _preferredAudioLanguage,
      'showSubtitlesByDefault': _showSubtitlesByDefault,
      'subtitleFolder': _subtitleFolder,
      'subtitleEncoding': _subtitleEncoding,
      'preferredSubtitleLanguage': _preferredSubtitleLanguage,
      'defaultSubtitleSync': _defaultSubtitleSync,
      'subtitleItalic': _subtitleItalic,
      'subtitleRTL': _subtitleRTL,
      'sortBy': _sortBy,
      'sortDesc': _sortDesc,
      'libraryGridView': _libraryGridView,
      'foldersGridView': _foldersGridView,
      'recentGridView': _recentGridView,
      'doubleTapSeekSeconds': _doubleTapSeekSeconds,
      'themeSeedColorValue': _themeSeedColorValue,
      'controlsHideSeconds': _controlsHideSeconds,
      'longPressSpeedEnabled': _longPressSpeedEnabled,
      'longPressSpeedValue': _longPressSpeedValue,
      'gestureSensitivity': _gestureSensitivity,
      'silentResume': _silentResume,
      'autoPipOnBackground': _autoPipOnBackground,
      'smartRotationEnabled': _smartRotationEnabled,
    };
  }

  Future<void> importFromJson(Map<String, dynamic> jsonSettings) async {
    T read<T>(String key, T fallback) {
      final v = jsonSettings[key];
      if (v is T) return v;
      if (v != null && fallback is double && v is num) return v.toDouble() as T;
      return fallback;
    }

    if (jsonSettings.containsKey('subtitleSettings')) {
      _subtitleSettings = SubtitleSettings.fromMap(jsonSettings['subtitleSettings']);
    }

    _themeMode = ThemeMode.values[read('themeMode', _themeMode.index)];
    _rememberPosition = read('rememberPosition', _rememberPosition);
    _autoPlay = read('autoPlay', _autoPlay);
    _defaultSpeed = read('defaultSpeed', _defaultSpeed);
    _hwDecoderMode = read('hwDecoderMode', _hwDecoderMode);
    _colorFormat = read('colorFormat', _colorFormat);
    _defaultAudioBoost = read('defaultAudioBoost', _defaultAudioBoost);
    _preferredAudioLanguage = read('preferredAudioLanguage', _preferredAudioLanguage);
    _showSubtitlesByDefault = read('showSubtitlesByDefault', _showSubtitlesByDefault);
    _subtitleFolder = read('subtitleFolder', _subtitleFolder);
    _subtitleEncoding = read('subtitleEncoding', _subtitleEncoding);
    _preferredSubtitleLanguage = read('preferredSubtitleLanguage', _preferredSubtitleLanguage);
    _defaultSubtitleSync = read('defaultSubtitleSync', _defaultSubtitleSync);
    _subtitleItalic = read('subtitleItalic', _subtitleItalic);
    _subtitleRTL = read('subtitleRTL', _subtitleRTL);
    _sortBy = read('sortBy', _sortBy);
    _sortDesc = read('sortDesc', _sortDesc);
    _libraryGridView = read('libraryGridView', _libraryGridView);
    _foldersGridView = read('foldersGridView', _foldersGridView);
    _recentGridView = read('recentGridView', _recentGridView);
    _doubleTapSeekSeconds = read('doubleTapSeekSeconds', _doubleTapSeekSeconds);
    _themeSeedColorValue = read('themeSeedColorValue', _themeSeedColorValue);
    _controlsHideSeconds = read('controlsHideSeconds', _controlsHideSeconds);
    _longPressSpeedEnabled = read('longPressSpeedEnabled', _longPressSpeedEnabled);
    _longPressSpeedValue = read('longPressSpeedValue', _longPressSpeedValue);
    _gestureSensitivity = read('gestureSensitivity', _gestureSensitivity);
    _silentResume = read('silentResume', _silentResume);
    _autoPipOnBackground = read('autoPipOnBackground', _autoPipOnBackground);
    _smartRotationEnabled = read('smartRotationEnabled', _smartRotationEnabled);

    notifyListeners();
    await _save();
  }
}