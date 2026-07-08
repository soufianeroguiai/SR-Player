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

  // ---------- دوال قديمة يجب أن تبقى ----------
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
  void setSilentResume(bool v) { _silentResume = v; notifyListeners(); _save(); }
  void setAutoPipOnBackground(bool v) { _autoPipOnBackground = v; notifyListeners(); _save(); }
  void setSmartRotationEnabled(bool v) { _smartRotationEnabled = v; notifyListeners(); _save(); }
  void setShowSubtitlesByDefault(bool v) { _showSubtitlesByDefault = v; notifyListeners(); _save(); }
  void setSubtitleFolder(String v) { _subtitleFolder = v; notifyListeners(); _save(); }
  void setSubtitleEncoding(String v) { _subtitleEncoding = v; notifyListeners(); _save(); }
  void setPreferredSubtitleLanguage(String v) { _preferredSubtitleLanguage = v; notifyListeners(); _save(); }
  void setDefaultSubtitleSync(double v) { _defaultSubtitleSync = v; notifyListeners(); _save(); }
  void setSubtitleItalic(bool v) { _subtitleItalic = v; notifyListeners(); _save(); }
  void setSubtitleRTL(bool v) { _subtitleRTL = v; notifyListeners(); _save(); }

  // ---------- المشغل: التشغيل ----------
  bool _autoPlay = true;
  bool get autoPlay => _autoPlay;

  bool _rememberPosition = true;
  bool get rememberPosition => _rememberPosition;

  bool _rememberPlaybackSpeed = false;
  bool get rememberPlaybackSpeed => _rememberPlaybackSpeed;
  void setRememberPlaybackSpeed(bool v) { _rememberPlaybackSpeed = v; notifyListeners(); _save(); }

  String _loopMode = 'none';
  String get loopMode => _loopMode;
  void setLoopMode(String v) { _loopMode = v; notifyListeners(); _save(); }

  bool _autoNextVideo = true;
  bool get autoNextVideo => _autoNextVideo;
  void setAutoNextVideo(bool v) { _autoNextVideo = v; notifyListeners(); _save(); }

  // ---------- المشغل: سرعة التشغيل ----------
  double _defaultSpeed = 1.0;
  double get defaultSpeed => _defaultSpeed;

  bool _rememberSpeed = false;
  bool get rememberSpeed => _rememberSpeed;
  void setRememberSpeed(bool v) { _rememberSpeed = v; notifyListeners(); _save(); }

  bool _allowSpeedUpTo4x = true;
  bool get allowSpeedUpTo4x => _allowSpeedUpTo4x;
  void setAllowSpeedUpTo4x(bool v) { _allowSpeedUpTo4x = v; notifyListeners(); _save(); }

  bool _pitchCorrection = false;
  bool get pitchCorrection => _pitchCorrection;
  void setPitchCorrection(bool v) { _pitchCorrection = v; notifyListeners(); _save(); }

  // ---------- المشغل: عرض الفيديو ----------
  String _defaultVideoMode = 'contain';
  String get defaultVideoMode => _defaultVideoMode;
  void setDefaultVideoMode(String v) { _defaultVideoMode = v; notifyListeners(); _save(); }

  bool _rememberVideoMode = true;
  bool get rememberVideoMode => _rememberVideoMode;
  void setRememberVideoMode(bool v) { _rememberVideoMode = v; notifyListeners(); _save(); }

  bool _autoRotate = true;
  bool get autoRotate => _autoRotate;
  void setAutoRotate(bool v) { _autoRotate = v; notifyListeners(); _save(); }

  bool _autoFullscreen = false;
  bool get autoFullscreen => _autoFullscreen;
  void setAutoFullscreen(bool v) { _autoFullscreen = v; notifyListeners(); _save(); }

  bool _keepScreenOn = true;
  bool get keepScreenOn => _keepScreenOn;
  void setKeepScreenOn(bool v) { _keepScreenOn = v; notifyListeners(); _save(); }

  // ---------- المشغل: الإيماءات ----------
  bool _gestureVolume = true;
  bool get gestureVolume => _gestureVolume;
  void setGestureVolume(bool v) { _gestureVolume = v; notifyListeners(); _save(); }

  bool _gestureBrightness = true;
  bool get gestureBrightness => _gestureBrightness;
  void setGestureBrightness(bool v) { _gestureBrightness = v; notifyListeners(); _save(); }

  bool _gestureSeek = true;
  bool get gestureSeek => _gestureSeek;
  void setGestureSeek(bool v) { _gestureSeek = v; notifyListeners(); _save(); }

  bool _tapToPause = true;
  bool get tapToPause => _tapToPause;
  void setTapToPause(bool v) { _tapToPause = v; notifyListeners(); _save(); }

  bool _doubleTapSeek = true;
  bool get doubleTapSeek => _doubleTapSeek;
  void setDoubleTapSeek(bool v) { _doubleTapSeek = v; notifyListeners(); _save(); }

  bool _longPressSpeed = true;
  bool get longPressSpeed => _longPressSpeed;
  void setLongPressSpeed(bool v) { _longPressSpeed = v; notifyListeners(); _save(); }

  bool _vibrateOnEnd = false;
  bool get vibrateOnEnd => _vibrateOnEnd;
  void setVibrateOnEnd(bool v) { _vibrateOnEnd = v; notifyListeners(); _save(); }

  // ---------- المشغل: التقديم والترجيع ----------
  int _doubleTapSeekSeconds = 10;
  int get doubleTapSeekSeconds => _doubleTapSeekSeconds;

  bool _showSeekPreview = true;
  bool get showSeekPreview => _showSeekPreview;
  void setShowSeekPreview(bool v) { _showSeekPreview = v; notifyListeners(); _save(); }

  bool _showSeekTime = true;
  bool get showSeekTime => _showSeekTime;
  void setShowSeekTime(bool v) { _showSeekTime = v; notifyListeners(); _save(); }

  // ---------- المشغل: واجهة المشغل ----------
  bool _autoHideControls = true;
  bool get autoHideControls => _autoHideControls;
  void setAutoHideControls(bool v) { _autoHideControls = v; notifyListeners(); _save(); }

  int _controlsHideSeconds = 4;
  int get controlsHideSeconds => _controlsHideSeconds;

  bool _showRemainingTime = true;
  bool get showRemainingTime => _showRemainingTime;
  void setShowRemainingTime(bool v) { _showRemainingTime = v; notifyListeners(); _save(); }

  bool _showElapsedTime = true;
  bool get showElapsedTime => _showElapsedTime;
  void setShowElapsedTime(bool v) { _showElapsedTime = v; notifyListeners(); _save(); }

  bool _showVideoTitle = true;
  bool get showVideoTitle => _showVideoTitle;
  void setShowVideoTitle(bool v) { _showVideoTitle = v; notifyListeners(); _save(); }

  bool _showBattery = false;
  bool get showBattery => _showBattery;
  void setShowBattery(bool v) { _showBattery = v; notifyListeners(); _save(); }

  bool _showClock = false;
  bool get showClock => _showClock;
  void setShowClock(bool v) { _showClock = v; notifyListeners(); _save(); }

  // ---------- المشغل: القوائم ----------
  bool _continuousPlayback = true;
  bool get continuousPlayback => _continuousPlayback;
  void setContinuousPlayback(bool v) { _continuousPlayback = v; notifyListeners(); _save(); }

  bool _removeVideoAfterPlayback = false;
  bool get removeVideoAfterPlayback => _removeVideoAfterPlayback;
  void setRemoveVideoAfterPlayback(bool v) { _removeVideoAfterPlayback = v; notifyListeners(); _save(); }

  bool _rememberLastPlaylist = false;
  bool get rememberLastPlaylist => _rememberLastPlaylist;
  void setRememberLastPlaylist(bool v) { _rememberLastPlaylist = v; notifyListeners(); _save(); }

  bool _savePlaylistOrder = false;
  bool get savePlaylistOrder => _savePlaylistOrder;
  void setSavePlaylistOrder(bool v) { _savePlaylistOrder = v; notifyListeners(); _save(); }

  bool _shufflePlaylist = false;
  bool get shufflePlaylist => _shufflePlaylist;
  void setShufflePlaylist(bool v) { _shufflePlaylist = v; notifyListeners(); _save(); }

  // ---------- المشغل: الطاقة ----------
  bool _preventScreenLock = true;
  bool get preventScreenLock => _preventScreenLock;
  void setPreventScreenLock(bool v) { _preventScreenLock = v; notifyListeners(); _save(); }

  bool _reduceBrightnessOnPause = false;
  bool get reduceBrightnessOnPause => _reduceBrightnessOnPause;
  void setReduceBrightnessOnPause(bool v) { _reduceBrightnessOnPause = v; notifyListeners(); _save(); }

  bool _stopAfterVideo = false;
  bool get stopAfterVideo => _stopAfterVideo;
  void setStopAfterVideo(bool v) { _stopAfterVideo = v; notifyListeners(); _save(); }

  int _sleepTimerMinutes = 0;
  int get sleepTimerMinutes => _sleepTimerMinutes;
  void setSleepTimerMinutes(int v) { _sleepTimerMinutes = v; notifyListeners(); _save(); }

  // ---------- المشغل: التحكم ----------
  bool _volumeKeysSeek = false;
  bool get volumeKeysSeek => _volumeKeysSeek;
  void setVolumeKeysSeek(bool v) { _volumeKeysSeek = v; notifyListeners(); _save(); }

  bool _keyboardSupport = false;
  bool get keyboardSupport => _keyboardSupport;
  void setKeyboardSupport(bool v) { _keyboardSupport = v; notifyListeners(); _save(); }

  bool _gamepadSupport = false;
  bool get gamepadSupport => _gamepadSupport;
  void setGamepadSupport(bool v) { _gamepadSupport = v; notifyListeners(); _save(); }

  // ---------- المشغل: خيارات متقدمة ----------
  String _hwDecoderMode = 'auto';
  String get hwDecoderMode => _hwDecoderMode;

  bool _fallbackToSoftware = true;
  bool get fallbackToSoftware => _fallbackToSoftware;
  void setFallbackToSoftware(bool v) { _fallbackToSoftware = v; notifyListeners(); _save(); }

  bool _lowLatencyPlayback = false;
  bool get lowLatencyPlayback => _lowLatencyPlayback;
  void setLowLatencyPlayback(bool v) { _lowLatencyPlayback = v; notifyListeners(); _save(); }

  bool _frameDropping = true;
  bool get frameDropping => _frameDropping;
  void setFrameDropping(bool v) { _frameDropping = v; notifyListeners(); _save(); }

  bool _vsync = true;
  bool get vsync => _vsync;
  void setVsync(bool v) { _vsync = v; notifyListeners(); _save(); }

  bool _loggingEnabled = false;
  bool get loggingEnabled => _loggingEnabled;
  void setLoggingEnabled(bool v) { _loggingEnabled = v; notifyListeners(); _save(); }

  bool _showVideoInfo = false;
  bool get showVideoInfo => _showVideoInfo;
  void setShowVideoInfo(bool v) { _showVideoInfo = v; notifyListeners(); _save(); }

  // ---------- الصوت ----------
  double _defaultAudioBoost = 100.0;
  double get defaultAudioBoost => _defaultAudioBoost;

  String _preferredAudioLanguage = 'ara';
  String get preferredAudioLanguage => _preferredAudioLanguage;

  bool _surroundSound = false;
  bool get surroundSound => _surroundSound;
  void setSurroundSound(bool v) { _surroundSound = v; notifyListeners(); _save(); }

  bool _bassBoost = false;
  bool get bassBoost => _bassBoost;
  void setBassBoost(bool v) { _bassBoost = v; notifyListeners(); _save(); }

  double _audioBalance = 0.0;
  double get audioBalance => _audioBalance;
  void setAudioBalance(double v) { _audioBalance = v.clamp(-1.0, 1.0); notifyListeners(); _save(); }

  String _audioOutputMode = 'Stereo';
  String get audioOutputMode => _audioOutputMode;
  void setAudioOutputMode(String v) { _audioOutputMode = v; notifyListeners(); _save(); }

  int _audioDelayMs = 0;
  int get audioDelayMs => _audioDelayMs;
  void setAudioDelayMs(int v) { _audioDelayMs = v; notifyListeners(); _save(); }

  bool _autoSwitchBluetooth = true;
  bool get autoSwitchBluetooth => _autoSwitchBluetooth;
  void setAutoSwitchBluetooth(bool v) { _autoSwitchBluetooth = v; notifyListeners(); _save(); }

  bool _rememberVolumePerVideo = false;
  bool get rememberVolumePerVideo => _rememberVolumePerVideo;
  void setRememberVolumePerVideo(bool v) { _rememberVolumePerVideo = v; notifyListeners(); _save(); }

  bool _resetVolumePerVideo = true;
  bool get resetVolumePerVideo => _resetVolumePerVideo;
  void setResetVolumePerVideo(bool v) { _resetVolumePerVideo = v; notifyListeners(); _save(); }

  List<double> _equalizerBands = [0,0,0,0,0,0,0,0,0,0];
  List<double> get equalizerBands => _equalizerBands;
  void setEqualizerBands(List<double> bands) { _equalizerBands = bands; notifyListeners(); _save(); }

  // الإعدادات الصوتية الجديدة
  String _equalizerPreset = 'Off';
  String get equalizerPreset => _equalizerPreset;
  void setEqualizerPreset(String v) { _equalizerPreset = v; notifyListeners(); _save(); }

  bool _normalizeVolume = false;
  bool get normalizeVolume => _normalizeVolume;
  void setNormalizeVolume(bool v) { _normalizeVolume = v; notifyListeners(); _save(); }

  double _audioBoostLevel = 1.0; // 1.0 = off, 3.0 = max boost
  double get audioBoostLevel => _audioBoostLevel;
  void setAudioBoostLevel(double v) { _audioBoostLevel = v; notifyListeners(); _save(); }

  // ---------- الترجمة ----------
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

  // ---------- المكتبة ----------
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

  // ---------- عام ----------
  int _themeSeedColorValue = 0xFF1B6CA8;
  Color get themeSeedColor => Color(_themeSeedColorValue);

  bool _silentResume = false;
  bool get silentResume => _silentResume;

  bool _autoPipOnBackground = false;
  bool get autoPipOnBackground => _autoPipOnBackground;

  bool _smartRotationEnabled = true;
  bool get smartRotationEnabled => _smartRotationEnabled;

  bool _longPressSpeedEnabled = true;
  bool get longPressSpeedEnabled => _longPressSpeedEnabled;

  double _longPressSpeedValue = 2.0;
  double get longPressSpeedValue => _longPressSpeedValue;

  double _gestureSensitivity = 1.0;
  double get gestureSensitivity => _gestureSensitivity;

  String _colorFormat = 'yuv';
  String get colorFormat => _colorFormat;

  bool _autoHideStatusBar = false;
  bool get autoHideStatusBar => _autoHideStatusBar;
  void setAutoHideStatusBar(bool v) { _autoHideStatusBar = v; notifyListeners(); _save(); }

  bool _animationsEnabled = true;
  bool get animationsEnabled => _animationsEnabled;
  void setAnimationsEnabled(bool v) { _animationsEnabled = v; notifyListeners(); _save(); }

  // ---------- اللغة ----------
  String _appLanguageCode = 'system';
  String get appLanguageCode => _appLanguageCode;
  Locale? get appLocale => _appLanguageCode == 'system' ? null : Locale(_appLanguageCode);
  void setAppLanguageCode(String v) { _appLanguageCode = v; notifyListeners(); _save(); }

  // ---------- load / save ----------
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
    _autoPlay = p.getBool('autoPlay') ?? true;
    _rememberPosition = p.getBool('rememberPosition') ?? true;
    _rememberPlaybackSpeed = p.getBool('rememberPlaybackSpeed') ?? false;
    _loopMode = p.getString('loopMode') ?? 'none';
    _autoNextVideo = p.getBool('autoNextVideo') ?? true;
    _defaultSpeed = p.getDouble('defaultSpeed') ?? 1.0;
    _rememberSpeed = p.getBool('rememberSpeed') ?? false;
    _allowSpeedUpTo4x = p.getBool('allowSpeedUpTo4x') ?? true;
    _pitchCorrection = p.getBool('pitchCorrection') ?? false;
    _defaultVideoMode = p.getString('defaultVideoMode') ?? 'contain';
    _rememberVideoMode = p.getBool('rememberVideoMode') ?? true;
    _autoRotate = p.getBool('autoRotate') ?? true;
    _autoFullscreen = p.getBool('autoFullscreen') ?? false;
    _keepScreenOn = p.getBool('keepScreenOn') ?? true;
    _gestureVolume = p.getBool('gestureVolume') ?? true;
    _gestureBrightness = p.getBool('gestureBrightness') ?? true;
    _gestureSeek = p.getBool('gestureSeek') ?? true;
    _tapToPause = p.getBool('tapToPause') ?? true;
    _doubleTapSeek = p.getBool('doubleTapSeek') ?? true;
    _longPressSpeed = p.getBool('longPressSpeed') ?? true;
    _vibrateOnEnd = p.getBool('vibrateOnEnd') ?? false;
    _doubleTapSeekSeconds = p.getInt('doubleTapSeekSeconds') ?? 10;
    _showSeekPreview = p.getBool('showSeekPreview') ?? true;
    _showSeekTime = p.getBool('showSeekTime') ?? true;
    _autoHideControls = p.getBool('autoHideControls') ?? true;
    _controlsHideSeconds = p.getInt('controlsHideSeconds') ?? 4;
    _showRemainingTime = p.getBool('showRemainingTime') ?? true;
    _showElapsedTime = p.getBool('showElapsedTime') ?? true;
    _showVideoTitle = p.getBool('showVideoTitle') ?? true;
    _showBattery = p.getBool('showBattery') ?? false;
    _showClock = p.getBool('showClock') ?? false;
    _continuousPlayback = p.getBool('continuousPlayback') ?? true;
    _removeVideoAfterPlayback = p.getBool('removeVideoAfterPlayback') ?? false;
    _rememberLastPlaylist = p.getBool('rememberLastPlaylist') ?? false;
    _savePlaylistOrder = p.getBool('savePlaylistOrder') ?? false;
    _shufflePlaylist = p.getBool('shufflePlaylist') ?? false;
    _preventScreenLock = p.getBool('preventScreenLock') ?? true;
    _reduceBrightnessOnPause = p.getBool('reduceBrightnessOnPause') ?? false;
    _stopAfterVideo = p.getBool('stopAfterVideo') ?? false;
    _sleepTimerMinutes = p.getInt('sleepTimerMinutes') ?? 0;
    _volumeKeysSeek = p.getBool('volumeKeysSeek') ?? false;
    _keyboardSupport = p.getBool('keyboardSupport') ?? false;
    _gamepadSupport = p.getBool('gamepadSupport') ?? false;
    _hwDecoderMode = p.getString('hwDecoderMode') ?? 'auto';
    _fallbackToSoftware = p.getBool('fallbackToSoftware') ?? true;
    _lowLatencyPlayback = p.getBool('lowLatencyPlayback') ?? false;
    _frameDropping = p.getBool('frameDropping') ?? true;
    _vsync = p.getBool('vsync') ?? true;
    _loggingEnabled = p.getBool('loggingEnabled') ?? false;
    _showVideoInfo = p.getBool('showVideoInfo') ?? false;
    _defaultAudioBoost = p.getDouble('defaultAudioBoost') ?? 100.0;
    _preferredAudioLanguage = p.getString('preferredAudioLanguage') ?? 'ara';
    _surroundSound = p.getBool('surroundSound') ?? false;
    _bassBoost = p.getBool('bassBoost') ?? false;
    _audioBalance = p.getDouble('audioBalance') ?? 0.0;
    _audioOutputMode = p.getString('audioOutputMode') ?? 'Stereo';
    _audioDelayMs = p.getInt('audioDelayMs') ?? 0;
    _autoSwitchBluetooth = p.getBool('autoSwitchBluetooth') ?? true;
    _rememberVolumePerVideo = p.getBool('rememberVolumePerVideo') ?? false;
    _resetVolumePerVideo = p.getBool('resetVolumePerVideo') ?? true;
    final eqList = p.getStringList('equalizerBands');
    if (eqList != null && eqList.length == 10) {
      _equalizerBands = eqList.map((e) => double.tryParse(e) ?? 0.0).toList();
    }
    _equalizerPreset = p.getString('equalizerPreset') ?? 'Off';
    _normalizeVolume = p.getBool('normalizeVolume') ?? false;
    _audioBoostLevel = p.getDouble('audioBoostLevel') ?? 1.0;

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
    _themeSeedColorValue = p.getInt('themeSeedColorValue') ?? 0xFF1B6CA8;
    _silentResume = p.getBool('silentResume') ?? false;
    _autoPipOnBackground = p.getBool('autoPipOnBackground') ?? false;
    _smartRotationEnabled = p.getBool('smartRotationEnabled') ?? true;
    _longPressSpeedEnabled = p.getBool('longPressSpeedEnabled') ?? true;
    _longPressSpeedValue = p.getDouble('longPressSpeedValue') ?? 2.0;
    _gestureSensitivity = p.getDouble('gestureSensitivity') ?? 1.0;
    _colorFormat = p.getString('colorFormat') ?? 'yuv';
    _autoHideStatusBar = p.getBool('autoHideStatusBar') ?? false;
    _animationsEnabled = p.getBool('animationsEnabled') ?? true;
    _appLanguageCode = p.getString('appLanguageCode') ?? 'system';

    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('subtitleSettingsData', json.encode(_subtitleSettings.toMap()));
    await p.setInt('themeMode', _themeMode.index);
    await p.setBool('autoPlay', _autoPlay);
    await p.setBool('rememberPosition', _rememberPosition);
    await p.setBool('rememberPlaybackSpeed', _rememberPlaybackSpeed);
    await p.setString('loopMode', _loopMode);
    await p.setBool('autoNextVideo', _autoNextVideo);
    await p.setDouble('defaultSpeed', _defaultSpeed);
    await p.setBool('rememberSpeed', _rememberSpeed);
    await p.setBool('allowSpeedUpTo4x', _allowSpeedUpTo4x);
    await p.setBool('pitchCorrection', _pitchCorrection);
    await p.setString('defaultVideoMode', _defaultVideoMode);
    await p.setBool('rememberVideoMode', _rememberVideoMode);
    await p.setBool('autoRotate', _autoRotate);
    await p.setBool('autoFullscreen', _autoFullscreen);
    await p.setBool('keepScreenOn', _keepScreenOn);
    await p.setBool('gestureVolume', _gestureVolume);
    await p.setBool('gestureBrightness', _gestureBrightness);
    await p.setBool('gestureSeek', _gestureSeek);
    await p.setBool('tapToPause', _tapToPause);
    await p.setBool('doubleTapSeek', _doubleTapSeek);
    await p.setBool('longPressSpeed', _longPressSpeed);
    await p.setBool('vibrateOnEnd', _vibrateOnEnd);
    await p.setInt('doubleTapSeekSeconds', _doubleTapSeekSeconds);
    await p.setBool('showSeekPreview', _showSeekPreview);
    await p.setBool('showSeekTime', _showSeekTime);
    await p.setBool('autoHideControls', _autoHideControls);
    await p.setInt('controlsHideSeconds', _controlsHideSeconds);
    await p.setBool('showRemainingTime', _showRemainingTime);
    await p.setBool('showElapsedTime', _showElapsedTime);
    await p.setBool('showVideoTitle', _showVideoTitle);
    await p.setBool('showBattery', _showBattery);
    await p.setBool('showClock', _showClock);
    await p.setBool('continuousPlayback', _continuousPlayback);
    await p.setBool('removeVideoAfterPlayback', _removeVideoAfterPlayback);
    await p.setBool('rememberLastPlaylist', _rememberLastPlaylist);
    await p.setBool('savePlaylistOrder', _savePlaylistOrder);
    await p.setBool('shufflePlaylist', _shufflePlaylist);
    await p.setBool('preventScreenLock', _preventScreenLock);
    await p.setBool('reduceBrightnessOnPause', _reduceBrightnessOnPause);
    await p.setBool('stopAfterVideo', _stopAfterVideo);
    await p.setInt('sleepTimerMinutes', _sleepTimerMinutes);
    await p.setBool('volumeKeysSeek', _volumeKeysSeek);
    await p.setBool('keyboardSupport', _keyboardSupport);
    await p.setBool('gamepadSupport', _gamepadSupport);
    await p.setString('hwDecoderMode', _hwDecoderMode);
    await p.setBool('fallbackToSoftware', _fallbackToSoftware);
    await p.setBool('lowLatencyPlayback', _lowLatencyPlayback);
    await p.setBool('frameDropping', _frameDropping);
    await p.setBool('vsync', _vsync);
    await p.setBool('loggingEnabled', _loggingEnabled);
    await p.setBool('showVideoInfo', _showVideoInfo);
    await p.setDouble('defaultAudioBoost', _defaultAudioBoost);
    await p.setString('preferredAudioLanguage', _preferredAudioLanguage);
    await p.setBool('surroundSound', _surroundSound);
    await p.setBool('bassBoost', _bassBoost);
    await p.setDouble('audioBalance', _audioBalance);
    await p.setString('audioOutputMode', _audioOutputMode);
    await p.setInt('audioDelayMs', _audioDelayMs);
    await p.setBool('autoSwitchBluetooth', _autoSwitchBluetooth);
    await p.setBool('rememberVolumePerVideo', _rememberVolumePerVideo);
    await p.setBool('resetVolumePerVideo', _resetVolumePerVideo);
    await p.setStringList('equalizerBands', _equalizerBands.map((e) => e.toString()).toList());
    await p.setString('equalizerPreset', _equalizerPreset);
    await p.setBool('normalizeVolume', _normalizeVolume);
    await p.setDouble('audioBoostLevel', _audioBoostLevel);

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
    await p.setInt('themeSeedColorValue', _themeSeedColorValue);
    await p.setBool('silentResume', _silentResume);
    await p.setBool('autoPipOnBackground', _autoPipOnBackground);
    await p.setBool('smartRotationEnabled', _smartRotationEnabled);
    await p.setBool('longPressSpeedEnabled', _longPressSpeedEnabled);
    await p.setDouble('longPressSpeedValue', _longPressSpeedValue);
    await p.setDouble('gestureSensitivity', _gestureSensitivity);
    await p.setString('colorFormat', _colorFormat);
    await p.setBool('autoHideStatusBar', _autoHideStatusBar);
    await p.setBool('animationsEnabled', _animationsEnabled);
    await p.setString('appLanguageCode', _appLanguageCode);
  }

  void resetAll() {
    _subtitleSettings = SubtitleSettings();
    _themeMode = ThemeMode.system;
    _autoPlay = true;
    _rememberPosition = true;
    _rememberPlaybackSpeed = false;
    _loopMode = 'none';
    _autoNextVideo = true;
    _defaultSpeed = 1.0;
    _rememberSpeed = false;
    _allowSpeedUpTo4x = true;
    _pitchCorrection = false;
    _defaultVideoMode = 'contain';
    _rememberVideoMode = true;
    _autoRotate = true;
    _autoFullscreen = false;
    _keepScreenOn = true;
    _gestureVolume = true;
    _gestureBrightness = true;
    _gestureSeek = true;
    _tapToPause = true;
    _doubleTapSeek = true;
    _longPressSpeed = true;
    _vibrateOnEnd = false;
    _doubleTapSeekSeconds = 10;
    _showSeekPreview = true;
    _showSeekTime = true;
    _autoHideControls = true;
    _controlsHideSeconds = 4;
    _showRemainingTime = true;
    _showElapsedTime = true;
    _showVideoTitle = true;
    _showBattery = false;
    _showClock = false;
    _continuousPlayback = true;
    _removeVideoAfterPlayback = false;
    _rememberLastPlaylist = false;
    _savePlaylistOrder = false;
    _shufflePlaylist = false;
    _preventScreenLock = true;
    _reduceBrightnessOnPause = false;
    _stopAfterVideo = false;
    _sleepTimerMinutes = 0;
    _volumeKeysSeek = false;
    _keyboardSupport = false;
    _gamepadSupport = false;
    _hwDecoderMode = 'auto';
    _fallbackToSoftware = true;
    _lowLatencyPlayback = false;
    _frameDropping = true;
    _vsync = true;
    _loggingEnabled = false;
    _showVideoInfo = false;
    _defaultAudioBoost = 100.0;
    _preferredAudioLanguage = 'ara';
    _surroundSound = false;
    _bassBoost = false;
    _audioBalance = 0.0;
    _audioOutputMode = 'Stereo';
    _audioDelayMs = 0;
    _autoSwitchBluetooth = true;
    _rememberVolumePerVideo = false;
    _resetVolumePerVideo = true;
    _equalizerBands = [0,0,0,0,0,0,0,0,0,0];
    _equalizerPreset = 'Off';
    _normalizeVolume = false;
    _audioBoostLevel = 1.0;
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
    _themeSeedColorValue = 0xFF1B6CA8;
    _silentResume = false;
    _autoPipOnBackground = false;
    _smartRotationEnabled = true;
    _longPressSpeedEnabled = true;
    _longPressSpeedValue = 2.0;
    _gestureSensitivity = 1.0;
    _colorFormat = 'yuv';
    _autoHideStatusBar = false;
    _animationsEnabled = true;
    _appLanguageCode = 'system';
    _save();
    notifyListeners();
  }

  Map<String, dynamic> exportToJson() {
    return {
      'subtitleSettings': _subtitleSettings.toMap(),
      'themeMode': _themeMode.index,
      'autoPlay': _autoPlay,
      'rememberPosition': _rememberPosition,
      'rememberPlaybackSpeed': _rememberPlaybackSpeed,
      'loopMode': _loopMode,
      'autoNextVideo': _autoNextVideo,
      'defaultSpeed': _defaultSpeed,
      'rememberSpeed': _rememberSpeed,
      'allowSpeedUpTo4x': _allowSpeedUpTo4x,
      'pitchCorrection': _pitchCorrection,
      'defaultVideoMode': _defaultVideoMode,
      'rememberVideoMode': _rememberVideoMode,
      'autoRotate': _autoRotate,
      'autoFullscreen': _autoFullscreen,
      'keepScreenOn': _keepScreenOn,
      'gestureVolume': _gestureVolume,
      'gestureBrightness': _gestureBrightness,
      'gestureSeek': _gestureSeek,
      'tapToPause': _tapToPause,
      'doubleTapSeek': _doubleTapSeek,
      'longPressSpeed': _longPressSpeed,
      'vibrateOnEnd': _vibrateOnEnd,
      'doubleTapSeekSeconds': _doubleTapSeekSeconds,
      'showSeekPreview': _showSeekPreview,
      'showSeekTime': _showSeekTime,
      'autoHideControls': _autoHideControls,
      'controlsHideSeconds': _controlsHideSeconds,
      'showRemainingTime': _showRemainingTime,
      'showElapsedTime': _showElapsedTime,
      'showVideoTitle': _showVideoTitle,
      'showBattery': _showBattery,
      'showClock': _showClock,
      'continuousPlayback': _continuousPlayback,
      'removeVideoAfterPlayback': _removeVideoAfterPlayback,
      'rememberLastPlaylist': _rememberLastPlaylist,
      'savePlaylistOrder': _savePlaylistOrder,
      'shufflePlaylist': _shufflePlaylist,
      'preventScreenLock': _preventScreenLock,
      'reduceBrightnessOnPause': _reduceBrightnessOnPause,
      'stopAfterVideo': _stopAfterVideo,
      'sleepTimerMinutes': _sleepTimerMinutes,
      'volumeKeysSeek': _volumeKeysSeek,
      'keyboardSupport': _keyboardSupport,
      'gamepadSupport': _gamepadSupport,
      'hwDecoderMode': _hwDecoderMode,
      'fallbackToSoftware': _fallbackToSoftware,
      'lowLatencyPlayback': _lowLatencyPlayback,
      'frameDropping': _frameDropping,
      'vsync': _vsync,
      'loggingEnabled': _loggingEnabled,
      'showVideoInfo': _showVideoInfo,
      'defaultAudioBoost': _defaultAudioBoost,
      'preferredAudioLanguage': _preferredAudioLanguage,
      'surroundSound': _surroundSound,
      'bassBoost': _bassBoost,
      'audioBalance': _audioBalance,
      'audioOutputMode': _audioOutputMode,
      'audioDelayMs': _audioDelayMs,
      'autoSwitchBluetooth': _autoSwitchBluetooth,
      'rememberVolumePerVideo': _rememberVolumePerVideo,
      'resetVolumePerVideo': _resetVolumePerVideo,
      'equalizerBands': _equalizerBands,
      'equalizerPreset': _equalizerPreset,
      'normalizeVolume': _normalizeVolume,
      'audioBoostLevel': _audioBoostLevel,
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
      'themeSeedColorValue': _themeSeedColorValue,
      'silentResume': _silentResume,
      'autoPipOnBackground': _autoPipOnBackground,
      'smartRotationEnabled': _smartRotationEnabled,
      'longPressSpeedEnabled': _longPressSpeedEnabled,
      'longPressSpeedValue': _longPressSpeedValue,
      'gestureSensitivity': _gestureSensitivity,
      'colorFormat': _colorFormat,
      'autoHideStatusBar': _autoHideStatusBar,
      'animationsEnabled': _animationsEnabled,
      'appLanguageCode': _appLanguageCode,
    };
  }

  Future<void> importFromJson(Map<String, dynamic> jsonSettings) async {
    T read<T>(String key, T fallback) {
      final v = jsonSettings[key];
      if (v is T) return v;
      if (v != null && fallback is double && v is num) return v.toDouble() as T;
      if (fallback is int && v is num) return v.toInt() as T;
      if (fallback is List<double> && v is List) return List<double>.from(v) as T;
      return fallback;
    }

    if (jsonSettings.containsKey('subtitleSettings')) {
      _subtitleSettings = SubtitleSettings.fromMap(jsonSettings['subtitleSettings']);
    }

    _themeMode = ThemeMode.values[read('themeMode', _themeMode.index)];
    _autoPlay = read('autoPlay', _autoPlay);
    _rememberPosition = read('rememberPosition', _rememberPosition);
    _rememberPlaybackSpeed = read('rememberPlaybackSpeed', _rememberPlaybackSpeed);
    _loopMode = read('loopMode', _loopMode);
    _autoNextVideo = read('autoNextVideo', _autoNextVideo);
    _defaultSpeed = read('defaultSpeed', _defaultSpeed);
    _rememberSpeed = read('rememberSpeed', _rememberSpeed);
    _allowSpeedUpTo4x = read('allowSpeedUpTo4x', _allowSpeedUpTo4x);
    _pitchCorrection = read('pitchCorrection', _pitchCorrection);
    _defaultVideoMode = read('defaultVideoMode', _defaultVideoMode);
    _rememberVideoMode = read('rememberVideoMode', _rememberVideoMode);
    _autoRotate = read('autoRotate', _autoRotate);
    _autoFullscreen = read('autoFullscreen', _autoFullscreen);
    _keepScreenOn = read('keepScreenOn', _keepScreenOn);
    _gestureVolume = read('gestureVolume', _gestureVolume);
    _gestureBrightness = read('gestureBrightness', _gestureBrightness);
    _gestureSeek = read('gestureSeek', _gestureSeek);
    _tapToPause = read('tapToPause', _tapToPause);
    _doubleTapSeek = read('doubleTapSeek', _doubleTapSeek);
    _longPressSpeed = read('longPressSpeed', _longPressSpeed);
    _vibrateOnEnd = read('vibrateOnEnd', _vibrateOnEnd);
    _doubleTapSeekSeconds = read('doubleTapSeekSeconds', _doubleTapSeekSeconds);
    _showSeekPreview = read('showSeekPreview', _showSeekPreview);
    _showSeekTime = read('showSeekTime', _showSeekTime);
    _autoHideControls = read('autoHideControls', _autoHideControls);
    _controlsHideSeconds = read('controlsHideSeconds', _controlsHideSeconds);
    _showRemainingTime = read('showRemainingTime', _showRemainingTime);
    _showElapsedTime = read('showElapsedTime', _showElapsedTime);
    _showVideoTitle = read('showVideoTitle', _showVideoTitle);
    _showBattery = read('showBattery', _showBattery);
    _showClock = read('showClock', _showClock);
    _continuousPlayback = read('continuousPlayback', _continuousPlayback);
    _removeVideoAfterPlayback = read('removeVideoAfterPlayback', _removeVideoAfterPlayback);
    _rememberLastPlaylist = read('rememberLastPlaylist', _rememberLastPlaylist);
    _savePlaylistOrder = read('savePlaylistOrder', _savePlaylistOrder);
    _shufflePlaylist = read('shufflePlaylist', _shufflePlaylist);
    _preventScreenLock = read('preventScreenLock', _preventScreenLock);
    _reduceBrightnessOnPause = read('reduceBrightnessOnPause', _reduceBrightnessOnPause);
    _stopAfterVideo = read('stopAfterVideo', _stopAfterVideo);
    _sleepTimerMinutes = read('sleepTimerMinutes', _sleepTimerMinutes);
    _volumeKeysSeek = read('volumeKeysSeek', _volumeKeysSeek);
    _keyboardSupport = read('keyboardSupport', _keyboardSupport);
    _gamepadSupport = read('gamepadSupport', _gamepadSupport);
    _hwDecoderMode = read('hwDecoderMode', _hwDecoderMode);
    _fallbackToSoftware = read('fallbackToSoftware', _fallbackToSoftware);
    _lowLatencyPlayback = read('lowLatencyPlayback', _lowLatencyPlayback);
    _frameDropping = read('frameDropping', _frameDropping);
    _vsync = read('vsync', _vsync);
    _loggingEnabled = read('loggingEnabled', _loggingEnabled);
    _showVideoInfo = read('showVideoInfo', _showVideoInfo);
    _defaultAudioBoost = read('defaultAudioBoost', _defaultAudioBoost);
    _preferredAudioLanguage = read('preferredAudioLanguage', _preferredAudioLanguage);
    _surroundSound = read('surroundSound', _surroundSound);
    _bassBoost = read('bassBoost', _bassBoost);
    _audioBalance = read('audioBalance', _audioBalance);
    _audioOutputMode = read('audioOutputMode', _audioOutputMode);
    _audioDelayMs = read('audioDelayMs', _audioDelayMs);
    _autoSwitchBluetooth = read('autoSwitchBluetooth', _autoSwitchBluetooth);
    _rememberVolumePerVideo = read('rememberVolumePerVideo', _rememberVolumePerVideo);
    _resetVolumePerVideo = read('resetVolumePerVideo', _resetVolumePerVideo);
    _equalizerBands = read<List<double>>('equalizerBands', _equalizerBands);
    _equalizerPreset = read('equalizerPreset', _equalizerPreset);
    _normalizeVolume = read('normalizeVolume', _normalizeVolume);
    _audioBoostLevel = read('audioBoostLevel', _audioBoostLevel);

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
    _themeSeedColorValue = read('themeSeedColorValue', _themeSeedColorValue);
    _silentResume = read('silentResume', _silentResume);
    _autoPipOnBackground = read('autoPipOnBackground', _autoPipOnBackground);
    _smartRotationEnabled = read('smartRotationEnabled', _smartRotationEnabled);
    _longPressSpeedEnabled = read('longPressSpeedEnabled', _longPressSpeedEnabled);
    _longPressSpeedValue = read('longPressSpeedValue', _longPressSpeedValue);
    _gestureSensitivity = read('gestureSensitivity', _gestureSensitivity);
    _colorFormat = read('colorFormat', _colorFormat);
    _autoHideStatusBar = read('autoHideStatusBar', _autoHideStatusBar);
    _animationsEnabled = read('animationsEnabled', _animationsEnabled);
    _appLanguageCode = read('appLanguageCode', _appLanguageCode);

    notifyListeners();
    await _save();
  }
}