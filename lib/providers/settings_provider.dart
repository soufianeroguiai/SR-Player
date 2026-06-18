import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // --- إعدادات سابقة ---
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool _rememberPosition = true;
  bool get rememberPosition => _rememberPosition;
  bool _autoPlay = true;
  bool get autoPlay => _autoPlay;
  double _defaultSpeed = 1.0;
  double get defaultSpeed => _defaultSpeed;
  bool _showSubtitlesByDefault = true;
  bool get showSubtitlesByDefault => _showSubtitlesByDefault;
  bool _gridView = false;
  bool get gridView => _gridView;
  String _sortBy = 'date';
  String get sortBy => _sortBy;
  bool _sortDesc = true;
  bool get sortDesc => _sortDesc;

  // --- 📝 تخصيص الترجمة (جديد) ---
  double _subtitleFontSize = 19.0;
  String _fontFamily = 'Roboto';
  int _fontWeightIndex = 1; // 0:Light, 1:Regular, 2:Medium, 3:Bold
  
  int _subtitleColorValue = 0xFFFFFFFF;
  int _subtitleBgColorValue = 0xFF000000;
  double _subtitleBgOpacity = 0.6;
  int _outlineColorValue = 0xFF000000;
  double _outlineWidth = 1.0;

  bool _shadowEnabled = false;
  int _shadowColorValue = 0xFF000000;
  double _shadowBlurRadius = 2.0;
  double _shadowOffsetX = 1.0;
  double _shadowOffsetY = 1.0;

  int _alignmentIndex = 2; // 0:Top, 1:Center, 2:Bottom
  double _bottomPadding = 50.0;
  double _horizontalMargin = 20.0;
  double _verticalMargin = 20.0;

  int _subtitleDelay = 0;
  bool _autoTranslate = false;
  String _translationLanguage = 'en';
  bool _showOriginalText = false;
  bool _dualSubtitles = false;
  String _subtitleEncoding = 'UTF-8';
  String _stylePreset = 'Default';

  // --- Getters ---
  double get subtitleFontSize => _subtitleFontSize;
  String get fontFamily => _fontFamily;
  int get fontWeightIndex => _fontWeightIndex;
  Color get subtitleColor => Color(_subtitleColorValue);
  Color get subtitleBgColor => Color(_subtitleBgColorValue);
  double get subtitleBgOpacity => _subtitleBgOpacity;
  Color get outlineColor => Color(_outlineColorValue);
  double get outlineWidth => _outlineWidth;
  bool get shadowEnabled => _shadowEnabled;
  Color get shadowColor => Color(_shadowColorValue);
  double get shadowBlurRadius => _shadowBlurRadius;
  double get shadowOffsetX => _shadowOffsetX;
  double get shadowOffsetY => _shadowOffsetY;
  int get alignmentIndex => _alignmentIndex;
  double get bottomPadding => _bottomPadding;
  double get horizontalMargin => _horizontalMargin;
  double get verticalMargin => _verticalMargin;
  int get subtitleDelay => _subtitleDelay;
  bool get autoTranslate => _autoTranslate;
  String get translationLanguage => _translationLanguage;
  bool get showOriginalText => _showOriginalText;
  bool get dualSubtitles => _dualSubtitles;
  String get subtitleEncoding => _subtitleEncoding;
  String get stylePreset => _stylePreset;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[p.getInt('themeMode') ?? 1];
    _rememberPosition = p.getBool('rememberPosition') ?? true;
    _autoPlay = p.getBool('autoPlay') ?? true;
    _defaultSpeed = p.getDouble('defaultSpeed') ?? 1.0;
    _showSubtitlesByDefault = p.getBool('showSubtitles') ?? true;
    
    // تحميل الترجمة
    _subtitleFontSize = p.getDouble('subtitleFontSize') ?? 19.0;
    _fontFamily = p.getString('fontFamily') ?? 'Roboto';
    _fontWeightIndex = p.getInt('fontWeightIndex') ?? 1;
    _subtitleColorValue = p.getInt('subtitleColorValue') ?? 0xFFFFFFFF;
    _subtitleBgColorValue = p.getInt('subtitleBgColorValue') ?? 0xFF000000;
    _subtitleBgOpacity = p.getDouble('subtitleBgOpacity') ?? 0.6;
    _outlineColorValue = p.getInt('outlineColorValue') ?? 0xFF000000;
    _outlineWidth = p.getDouble('outlineWidth') ?? 1.0;
    _shadowEnabled = p.getBool('shadowEnabled') ?? false;
    _shadowColorValue = p.getInt('shadowColorValue') ?? 0xFF000000;
    _shadowBlurRadius = p.getDouble('shadowBlurRadius') ?? 2.0;
    _shadowOffsetX = p.getDouble('shadowOffsetX') ?? 1.0;
    _shadowOffsetY = p.getDouble('shadowOffsetY') ?? 1.0;
    _alignmentIndex = p.getInt('alignmentIndex') ?? 2;
    _bottomPadding = p.getDouble('bottomPadding') ?? 50.0;
    _horizontalMargin = p.getDouble('horizontalMargin') ?? 20.0;
    _verticalMargin = p.getDouble('verticalMargin') ?? 20.0;
    _subtitleDelay = p.getInt('subtitleDelay') ?? 0;
    _autoTranslate = p.getBool('autoTranslate') ?? false;
    _translationLanguage = p.getString('translationLanguage') ?? 'en';
    _showOriginalText = p.getBool('showOriginalText') ?? false;
    _dualSubtitles = p.getBool('dualSubtitles') ?? false;
    _subtitleEncoding = p.getString('subtitleEncoding') ?? 'UTF-8';
    _stylePreset = p.getString('stylePreset') ?? 'Default';

    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('subtitleFontSize', _subtitleFontSize);
    await p.setString('fontFamily', _fontFamily);
    await p.setInt('fontWeightIndex', _fontWeightIndex);
    await p.setInt('subtitleColorValue', _subtitleColorValue);
    await p.setInt('subtitleBgColorValue', _subtitleBgColorValue);
    await p.setDouble('subtitleBgOpacity', _subtitleBgOpacity);
    await p.setInt('outlineColorValue', _outlineColorValue);
    await p.setDouble('outlineWidth', _outlineWidth);
    await p.setBool('shadowEnabled', _shadowEnabled);
    await p.setInt('shadowColorValue', _shadowColorValue);
    await p.setDouble('shadowBlurRadius', _shadowBlurRadius);
    await p.setDouble('shadowOffsetX', _shadowOffsetX);
    await p.setDouble('shadowOffsetY', _shadowOffsetY);
    await p.setInt('alignmentIndex', _alignmentIndex);
    await p.setDouble('bottomPadding', _bottomPadding);
    await p.setDouble('horizontalMargin', _horizontalMargin);
    await p.setDouble('verticalMargin', _verticalMargin);
    await p.setInt('subtitleDelay', _subtitleDelay);
    await p.setBool('autoTranslate', _autoTranslate);
    await p.setString('translationLanguage', _translationLanguage);
    await p.setBool('showOriginalText', _showOriginalText);
    await p.setBool('dualSubtitles', _dualSubtitles);
    await p.setString('subtitleEncoding', _subtitleEncoding);
    await p.setString('stylePreset', _stylePreset);
  }

  // Setters مع الحفظ التلقائي
  void setSubtitleFontSize(double v) { _subtitleFontSize = v; notifyListeners(); _save(); }
  void setFontFamily(String v) { _fontFamily = v; notifyListeners(); _save(); }
  void setFontWeightIndex(int v) { _fontWeightIndex = v; notifyListeners(); _save(); }
  void setSubtitleColor(Color c) { _subtitleColorValue = c.value; notifyListeners(); _save(); }
  void setSubtitleBgColor(Color c) { _subtitleBgColorValue = c.value; notifyListeners(); _save(); }
  void setSubtitleBgOpacity(double v) { _subtitleBgOpacity = v; notifyListeners(); _save(); }
  void setOutlineColor(Color c) { _outlineColorValue = c.value; notifyListeners(); _save(); }
  void setOutlineWidth(double v) { _outlineWidth = v; notifyListeners(); _save(); }
  void setShadowEnabled(bool v) { _shadowEnabled = v; notifyListeners(); _save(); }
  void setShadowColor(Color c) { _shadowColorValue = c.value; notifyListeners(); _save(); }
  void setShadowBlurRadius(double v) { _shadowBlurRadius = v; notifyListeners(); _save(); }
  void setShadowOffsetX(double v) { _shadowOffsetX = v; notifyListeners(); _save(); }
  void setShadowOffsetY(double v) { _shadowOffsetY = v; notifyListeners(); _save(); }
  void setAlignmentIndex(int v) { _alignmentIndex = v; notifyListeners(); _save(); }
  void setBottomPadding(double v) { _bottomPadding = v; notifyListeners(); _save(); }
  void setHorizontalMargin(double v) { _horizontalMargin = v; notifyListeners(); _save(); }
  void setVerticalMargin(double v) { _verticalMargin = v; notifyListeners(); _save(); }
  void setSubtitleDelay(int v) { _subtitleDelay = v; notifyListeners(); _save(); }
  void setAutoTranslate(bool v) { _autoTranslate = v; notifyListeners(); _save(); }
  void setTranslationLanguage(String v) { _translationLanguage = v; notifyListeners(); _save(); }
  void setShowOriginalText(bool v) { _showOriginalText = v; notifyListeners(); _save(); }
  void setDualSubtitles(bool v) { _dualSubtitles = v; notifyListeners(); _save(); }
  void setSubtitleEncoding(String v) { _subtitleEncoding = v; notifyListeners(); _save(); }
  void setStylePreset(String v) { _stylePreset = v; notifyListeners(); _save(); }
}
