import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
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
  String _subtitleFolder = '';
  String get subtitleFolder => _subtitleFolder;
  String _subtitleEncoding = 'UTF-8';
  String get subtitleEncoding => _subtitleEncoding;
  String _preferredSubtitleLanguage = 'ara';
  String get preferredSubtitleLanguage => _preferredSubtitleLanguage;
  double _defaultSubtitleSync = 0.0;
  double get defaultSubtitleSync => _defaultSubtitleSync;
  bool _subtitleItalic = false;
  bool get subtitleItalic => _subtitleItalic;
  bool _subtitleRTL = false;
  bool get subtitleRTL => _subtitleRTL;

  double _subtitleFontSize = 30.0;
  double get subtitleFontSize => _subtitleFontSize;
  String _fontFamily = 'Roboto';
  String get fontFamily => _fontFamily;
  int _fontWeightIndex = 2;
  int get fontWeightIndex => _fontWeightIndex;

  int _subtitleColorValue = 0xFFFFFFFF;
  Color get subtitleColor => Color(_subtitleColorValue);
  double _subtitleBgOpacity = 0.0;
  double get subtitleBgOpacity => _subtitleBgOpacity;
  Color _subtitleBgColor = const Color(0xFF000000);
  Color get subtitleBgColor => _subtitleBgColor;

  Color _outlineColor = const Color(0xFF000000);
  Color get outlineColor => _outlineColor;
  double _outlineWidth = 2.0;
  double get outlineWidth => _outlineWidth;
  bool _outlineEnabled = true;
  bool get outlineEnabled => _outlineEnabled;

  bool _textShadowEnabled = false;
  bool get textShadowEnabled => _textShadowEnabled;
  Color _textShadowColor = const Color(0xFF000000);
  Color get textShadowColor => _textShadowColor;
  double _textShadowBlurRadius = 4.0;
  double get textShadowBlurRadius => _textShadowBlurRadius;
  double _textShadowOffsetX = 1.0;
  double get textShadowOffsetX => _textShadowOffsetX;
  double _textShadowOffsetY = 1.0;
  double get textShadowOffsetY => _textShadowOffsetY;

  bool _boxShadowEnabled = false;
  bool get boxShadowEnabled => _boxShadowEnabled;
  Color _boxShadowColor = const Color(0xFF000000);
  Color get boxShadowColor => _boxShadowColor;
  double _boxShadowBlurRadius = 4.0;
  double get boxShadowBlurRadius => _boxShadowBlurRadius;
  double _boxShadowOffsetX = 1.0;
  double get boxShadowOffsetX => _boxShadowOffsetX;
  double _boxShadowOffsetY = 1.0;
  double get boxShadowOffsetY => _boxShadowOffsetY;

  double _bottomPadding = 48.0;
  double get bottomPadding => _bottomPadding;
  double _horizontalMargin = 24.0;
  double get horizontalMargin => _horizontalMargin;

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

  // ─────────── إعدادات جديدة ───────────

  // مدة القفز عند النقر المزدوج (بالثواني)
  int _doubleTapSeekSeconds = 10;
  int get doubleTapSeekSeconds => _doubleTapSeekSeconds;

  // لون التطبيق الأساسي (Material You seed color)
  int _themeSeedColorValue = 0xFF1B6CA8;
  Color get themeSeedColor => Color(_themeSeedColorValue);

  // مدة اختفاء أزرار التحكم تلقائياً (بالثواني)
  int _controlsHideSeconds = 4;
  int get controlsHideSeconds => _controlsHideSeconds;

  // الضغط المطول لتسريع التشغيل مؤقتاً
  bool _longPressSpeedEnabled = true;
  bool get longPressSpeedEnabled => _longPressSpeedEnabled;
  double _longPressSpeedValue = 2.0;
  double get longPressSpeedValue => _longPressSpeedValue;

  // حساسية الإيماءات (مضاعِف لسرعة سحب الصوت/السطوع وتكبير الترجمة)
  double _gestureSensitivity = 1.0;
  double get gestureSensitivity => _gestureSensitivity;

  // تخطي حوار/تنبيه استئناف التشغيل (استئناف صامت)
  bool _silentResume = false;
  bool get silentResume => _silentResume;

  // تفعيل تلقائي لوضع الصورة داخل صورة عند الخروج من التطبيق أثناء التشغيل
  bool _autoPipOnBackground = false;
  bool get autoPipOnBackground => _autoPipOnBackground;

  // تدوير الشاشة تلقائياً حسب وضعية الهاتف (حساس الحركة)
  bool _smartRotationEnabled = true;
  bool get smartRotationEnabled => _smartRotationEnabled;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
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
    _subtitleFontSize = p.getDouble('subtitleFontSize') ?? 30.0;
    _fontFamily = p.getString('fontFamily') ?? 'Roboto';
    _fontWeightIndex = p.getInt('fontWeightIndex') ?? 2;
    _subtitleColorValue = p.getInt('subtitleColorValue') ?? 0xFFFFFFFF;
    _subtitleBgOpacity = p.getDouble('subtitleBgOpacity') ?? 0.0;
    _subtitleBgColor = Color(p.getInt('subtitleBgColor') ?? 0xFF000000);
    _outlineColor = Color(p.getInt('outlineColor') ?? 0xFF000000);
    _outlineWidth = p.getDouble('outlineWidth') ?? 2.0;
    _outlineEnabled = p.getBool('outlineEnabled') ?? true;
    _textShadowEnabled = p.getBool('textShadowEnabled') ?? false;
    _textShadowColor = Color(p.getInt('textShadowColor') ?? 0xFF000000);
    _textShadowBlurRadius = p.getDouble('textShadowBlurRadius') ?? 4.0;
    _textShadowOffsetX = p.getDouble('textShadowOffsetX') ?? 1.0;
    _textShadowOffsetY = p.getDouble('textShadowOffsetY') ?? 1.0;
    _boxShadowEnabled = p.getBool('boxShadowEnabled') ?? false;
    _boxShadowColor = Color(p.getInt('boxShadowColor') ?? 0xFF000000);
    _boxShadowBlurRadius = p.getDouble('boxShadowBlurRadius') ?? 4.0;
    _boxShadowOffsetX = p.getDouble('boxShadowOffsetX') ?? 1.0;
    _boxShadowOffsetY = p.getDouble('boxShadowOffsetY') ?? 1.0;
    _bottomPadding = p.getDouble('bottomPadding') ?? 48.0;
    _horizontalMargin = p.getDouble('horizontalMargin') ?? 24.0;
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
    await p.setDouble('subtitleFontSize', _subtitleFontSize);
    await p.setString('fontFamily', _fontFamily);
    await p.setInt('fontWeightIndex', _fontWeightIndex);
    await p.setInt('subtitleColorValue', _subtitleColorValue);
    await p.setDouble('subtitleBgOpacity', _subtitleBgOpacity);
    await p.setInt('subtitleBgColor', _subtitleBgColor.toARGB32());
    await p.setInt('outlineColor', _outlineColor.toARGB32());
    await p.setDouble('outlineWidth', _outlineWidth);
    await p.setBool('outlineEnabled', _outlineEnabled);
    await p.setBool('textShadowEnabled', _textShadowEnabled);
    await p.setInt('textShadowColor', _textShadowColor.toARGB32());
    await p.setDouble('textShadowBlurRadius', _textShadowBlurRadius);
    await p.setDouble('textShadowOffsetX', _textShadowOffsetX);
    await p.setDouble('textShadowOffsetY', _textShadowOffsetY);
    await p.setBool('boxShadowEnabled', _boxShadowEnabled);
    await p.setInt('boxShadowColor', _boxShadowColor.toARGB32());
    await p.setDouble('boxShadowBlurRadius', _boxShadowBlurRadius);
    await p.setDouble('boxShadowOffsetX', _boxShadowOffsetX);
    await p.setDouble('boxShadowOffsetY', _boxShadowOffsetY);
    await p.setDouble('bottomPadding', _bottomPadding);
    await p.setDouble('horizontalMargin', _horizontalMargin);
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
    _subtitleFontSize = 30.0;
    _fontFamily = 'Roboto';
    _fontWeightIndex = 2;
    _subtitleColorValue = 0xFFFFFFFF;
    _subtitleBgOpacity = 0.0;
    _subtitleBgColor = const Color(0xFF000000);
    _outlineColor = const Color(0xFF000000);
    _outlineWidth = 2.0;
    _outlineEnabled = true;
    _textShadowEnabled = false;
    _textShadowColor = const Color(0xFF000000);
    _textShadowBlurRadius = 4.0;
    _textShadowOffsetX = 1.0;
    _textShadowOffsetY = 1.0;
    _boxShadowEnabled = false;
    _boxShadowColor = const Color(0xFF000000);
    _boxShadowBlurRadius = 4.0;
    _boxShadowOffsetX = 1.0;
    _boxShadowOffsetY = 1.0;
    _bottomPadding = 48.0;
    _horizontalMargin = 24.0;
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
  void setShowSubtitlesByDefault(bool v) { _showSubtitlesByDefault = v; notifyListeners(); _save(); }
  void setSubtitleFolder(String v) { _subtitleFolder = v; notifyListeners(); _save(); }
  void setSubtitleEncoding(String v) { _subtitleEncoding = v; notifyListeners(); _save(); }
  void setPreferredSubtitleLanguage(String v) { _preferredSubtitleLanguage = v; notifyListeners(); _save(); }
  void setDefaultSubtitleSync(double v) { _defaultSubtitleSync = v; notifyListeners(); _save(); }
  void setSubtitleItalic(bool v) { _subtitleItalic = v; notifyListeners(); _save(); }
  void setSubtitleRTL(bool v) { _subtitleRTL = v; notifyListeners(); _save(); }
  void setSubtitleFontSize(double v) { _subtitleFontSize = v; notifyListeners(); _save(); }
  void setFontFamily(String v) { _fontFamily = v; notifyListeners(); _save(); }
  void setFontWeightIndex(int v) { _fontWeightIndex = v; notifyListeners(); _save(); }
  void setSubtitleColor(Color c) { _subtitleColorValue = c.toARGB32(); notifyListeners(); _save(); }
  void setSubtitleBgOpacity(double v) { _subtitleBgOpacity = v; notifyListeners(); _save(); }
  void setSubtitleBgColor(Color c) { _subtitleBgColor = c; notifyListeners(); _save(); }
  void setOutlineColor(Color c) { _outlineColor = c; notifyListeners(); _save(); }
  void setOutlineWidth(double v) { _outlineWidth = v; notifyListeners(); _save(); }
  void setOutlineEnabled(bool v) { _outlineEnabled = v; notifyListeners(); _save(); }
  void setTextShadowEnabled(bool v) { _textShadowEnabled = v; notifyListeners(); _save(); }
  void setTextShadowColor(Color c) { _textShadowColor = c; notifyListeners(); _save(); }
  void setTextShadowBlurRadius(double v) { _textShadowBlurRadius = v; notifyListeners(); _save(); }
  void setTextShadowOffsetX(double v) { _textShadowOffsetX = v; notifyListeners(); _save(); }
  void setTextShadowOffsetY(double v) { _textShadowOffsetY = v; notifyListeners(); _save(); }
  void setBoxShadowEnabled(bool v) { _boxShadowEnabled = v; notifyListeners(); _save(); }
  void setBoxShadowColor(Color c) { _boxShadowColor = c; notifyListeners(); _save(); }
  void setBoxShadowBlurRadius(double v) { _boxShadowBlurRadius = v; notifyListeners(); _save(); }
  void setBoxShadowOffsetX(double v) { _boxShadowOffsetX = v; notifyListeners(); _save(); }
  void setBoxShadowOffsetY(double v) { _boxShadowOffsetY = v; notifyListeners(); _save(); }
  void setBottomPadding(double v) { _bottomPadding = v; notifyListeners(); _save(); }
  void setHorizontalMargin(double v) { _horizontalMargin = v; notifyListeners(); _save(); }
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
  void setSilentResume(bool v) { _silentResume = v; notifyListeners(); _save(); }
  void setAutoPipOnBackground(bool v) { _autoPipOnBackground = v; notifyListeners(); _save(); }
  void setSmartRotationEnabled(bool v) { _smartRotationEnabled = v; notifyListeners(); _save(); }

  // ─────────── نسخ احتياطي / استعادة للإعدادات ───────────

  /// يحوّل كل الإعدادات الحالية إلى Map قابلة للتحويل إلى JSON.
  Map<String, dynamic> exportToJson() {
    return {
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
      'subtitleFontSize': _subtitleFontSize,
      'fontFamily': _fontFamily,
      'fontWeightIndex': _fontWeightIndex,
      'subtitleColorValue': _subtitleColorValue,
      'subtitleBgOpacity': _subtitleBgOpacity,
      'subtitleBgColor': _subtitleBgColor.toARGB32(),
      'outlineColor': _outlineColor.toARGB32(),
      'outlineWidth': _outlineWidth,
      'outlineEnabled': _outlineEnabled,
      'textShadowEnabled': _textShadowEnabled,
      'textShadowColor': _textShadowColor.toARGB32(),
      'textShadowBlurRadius': _textShadowBlurRadius,
      'textShadowOffsetX': _textShadowOffsetX,
      'textShadowOffsetY': _textShadowOffsetY,
      'boxShadowEnabled': _boxShadowEnabled,
      'boxShadowColor': _boxShadowColor.toARGB32(),
      'boxShadowBlurRadius': _boxShadowBlurRadius,
      'boxShadowOffsetX': _boxShadowOffsetX,
      'boxShadowOffsetY': _boxShadowOffsetY,
      'bottomPadding': _bottomPadding,
      'horizontalMargin': _horizontalMargin,
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

  /// يستورد إعدادات من Map (مثلاً بعد قراءتها من ملف JSON) ويحفظها.
  /// أي مفتاح مفقود أو بنوع خاطئ يُتجاهل ويُبقي على القيمة الحالية،
  /// حتى لا يفشل الاستيراد بالكامل بسبب ملف قديم أو غير مكتمل.
  Future<void> importFromJson(Map<String, dynamic> json) async {
    T read<T>(String key, T fallback) {
      final v = json[key];
      if (v is T) return v;
      if (v != null && fallback is double && v is num) return v.toDouble() as T;
      return fallback;
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
    _subtitleFontSize = read('subtitleFontSize', _subtitleFontSize);
    _fontFamily = read('fontFamily', _fontFamily);
    _fontWeightIndex = read('fontWeightIndex', _fontWeightIndex);
    _subtitleColorValue = read('subtitleColorValue', _subtitleColorValue);
    _subtitleBgOpacity = read('subtitleBgOpacity', _subtitleBgOpacity);
    _subtitleBgColor = Color(read('subtitleBgColor', _subtitleBgColor.toARGB32()));
    _outlineColor = Color(read('outlineColor', _outlineColor.toARGB32()));
    _outlineWidth = read('outlineWidth', _outlineWidth);
    _outlineEnabled = read('outlineEnabled', _outlineEnabled);
    _textShadowEnabled = read('textShadowEnabled', _textShadowEnabled);
    _textShadowColor = Color(read('textShadowColor', _textShadowColor.toARGB32()));
    _textShadowBlurRadius = read('textShadowBlurRadius', _textShadowBlurRadius);
    _textShadowOffsetX = read('textShadowOffsetX', _textShadowOffsetX);
    _textShadowOffsetY = read('textShadowOffsetY', _textShadowOffsetY);
    _boxShadowEnabled = read('boxShadowEnabled', _boxShadowEnabled);
    _boxShadowColor = Color(read('boxShadowColor', _boxShadowColor.toARGB32()));
    _boxShadowBlurRadius = read('boxShadowBlurRadius', _boxShadowBlurRadius);
    _boxShadowOffsetX = read('boxShadowOffsetX', _boxShadowOffsetX);
    _boxShadowOffsetY = read('boxShadowOffsetY', _boxShadowOffsetY);
    _bottomPadding = read('bottomPadding', _bottomPadding);
    _horizontalMargin = read('horizontalMargin', _horizontalMargin);
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