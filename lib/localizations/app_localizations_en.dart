// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String mediaKitInitError(String error) {
    return 'Failed to initialize MediaKit:\n$error';
  }

  @override
  String ffmpegInitError(Object error) {
    return 'Failed to initialize FFmpeg:\n$error';
  }

  @override
  String settingsLoadError(Object error) {
    return 'Failed to load settings:\n$error';
  }

  @override
  String get errorOccurredTitle => 'Sorry, an error occurred';

  @override
  String get retryButton => 'Retry';

  @override
  String get requestingPermissions => 'Requesting permissions...';

  @override
  String get permissionsRequiredTitle => 'Permissions required';

  @override
  String get permissionsRequiredBody =>
      'The app needs media access permission to display videos.';

  @override
  String get grantPermissionsButton => 'Grant permissions';

  @override
  String get skipButton => 'Skip';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get noFavoriteVideos => 'No favorite videos';

  @override
  String get languageSettingLabel => 'Language';

  @override
  String get systemLanguageOption => 'System language';

  @override
  String get arabicLanguageOption => 'Arabic';

  @override
  String get englishLanguageOption => 'English';

  @override
  String get frenchLanguageOption => 'French';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'General';

  @override
  String get appearanceOption => 'Appearance';

  @override
  String get languageOption => 'Language';

  @override
  String get themeColorOption => 'App color';

  @override
  String get themeColorSubtitle => 'Primary interface color (Material You)';

  @override
  String get playerSection => 'Player';

  @override
  String get playbackSection => 'Playback';

  @override
  String get autoPlayOption => 'Auto play';

  @override
  String get resumePositionOption => 'Resume last position';

  @override
  String get rememberSpeedOption => 'Remember playback speed';

  @override
  String get repeatModeOption => 'Repeat mode';

  @override
  String get repeatNone => 'None';

  @override
  String get repeatVideo => 'Repeat video';

  @override
  String get repeatPlaylist => 'Repeat playlist';

  @override
  String get autoNextOption => 'Auto next video';

  @override
  String get autoPipOption => 'Auto picture-in-picture';

  @override
  String get speedSection => 'Playback speed';

  @override
  String get defaultSpeedOption => 'Default speed';

  @override
  String get rememberLastSpeedOption => 'Remember last speed';

  @override
  String get allow4xOption => 'Allow speed up to 4×';

  @override
  String get pitchCorrectionOption => 'Pitch correction';

  @override
  String get videoDisplaySection => 'Video display';

  @override
  String get defaultVideoModeOption => 'Default mode';

  @override
  String get rememberVideoModeOption => 'Remember last mode';

  @override
  String get autoRotateOption => 'Auto rotate';

  @override
  String get autoFullscreenOption => 'Auto fullscreen';

  @override
  String get keepScreenOnOption => 'Keep screen on';

  @override
  String get gesturesSection => 'Gestures';

  @override
  String get gestureVolumeOption => 'Swipe for volume';

  @override
  String get gestureBrightnessOption => 'Swipe for brightness';

  @override
  String get gestureSeekOption => 'Swipe to seek';

  @override
  String get tapToPauseOption => 'Tap to pause';

  @override
  String get doubleTapOption => 'Double tap';

  @override
  String get longPressSpeedOption => 'Long press = temporary speed ×2';

  @override
  String get vibrateOnEndOption => 'Vibrate on end';

  @override
  String get seekSection => 'Seeking';

  @override
  String get seekDurationOption => 'Skip duration';

  @override
  String get seekPreviewOption => 'Show preview while seeking';

  @override
  String get seekTimeOption => 'Show time while seeking';

  @override
  String get uiSection => 'Player UI';

  @override
  String get autoHideControlsOption => 'Auto-hide controls';

  @override
  String get hideDelayOption => 'Hide delay';

  @override
  String get showRemainingTimeOption => 'Show remaining time';

  @override
  String get showElapsedTimeOption => 'Show elapsed time';

  @override
  String get showVideoTitleOption => 'Show video title';

  @override
  String get showBatteryOption => 'Show battery';

  @override
  String get showClockOption => 'Show clock';

  @override
  String get playlistSection => 'Playlist';

  @override
  String get continuousPlaybackOption => 'Continuous playback';

  @override
  String get removeAfterPlaybackOption => 'Remove after playback';

  @override
  String get rememberPlaylistOption => 'Remember last playlist';

  @override
  String get savePlaylistOrderOption => 'Save playback order';

  @override
  String get shufflePlaylistOption => 'Shuffle';

  @override
  String get energySection => 'Energy';

  @override
  String get preventLockOption => 'Prevent screen lock';

  @override
  String get reduceBrightnessOption => 'Reduce brightness on pause';

  @override
  String get stopAfterVideoOption => 'Stop after video ends';

  @override
  String get sleepTimerOption => 'Sleep timer';

  @override
  String get sleepTimerDisabled => 'Disabled';

  @override
  String sleepTimerMinutes(Object minutes) {
    return '$minutes min';
  }

  @override
  String get controlSection => 'Control';

  @override
  String get volumeKeysSeekOption => 'Volume keys to seek';

  @override
  String get keyboardSupportOption => 'Keyboard support';

  @override
  String get gamepadSupportOption => 'Gamepad support';

  @override
  String get advancedSection => 'Advanced';

  @override
  String get decoderModeOption => 'Decoder mode';

  @override
  String get fallbackSoftwareOption => 'Fallback to software';

  @override
  String get lowLatencyOption => 'Low latency playback';

  @override
  String get frameDroppingOption => 'Frame dropping';

  @override
  String get vsyncOption => 'VSync';

  @override
  String get loggingOption => 'Logging';

  @override
  String get showVideoInfoOption => 'Show video info';

  @override
  String get audioSection => 'Audio';

  @override
  String get audioGeneralSection => 'General';

  @override
  String get audioBoostOption => 'Default volume boost';

  @override
  String get audioBalanceOption => 'Balance';

  @override
  String get rememberVolumeOption => 'Remember volume per video';

  @override
  String get resetVolumeOption => 'Reset volume per video';

  @override
  String get audioOutputSection => 'Audio output';

  @override
  String get audioOutputModeOption => 'Output mode';

  @override
  String get autoBluetoothOption => 'Auto-switch on Bluetooth';

  @override
  String get audioTracksSection => 'Audio tracks';

  @override
  String get preferredAudioLanguageOption => 'Preferred audio language';

  @override
  String get equalizerSection => 'Equalizer';

  @override
  String get equalizerEnabledOption => 'Enable equalizer';

  @override
  String get openEqualizerOption => 'Open graphic equalizer';

  @override
  String get equalizerBandsSubtitle => '10 bands';

  @override
  String get audioSyncSection => 'Audio sync';

  @override
  String get audioDelayOption => 'Audio delay (ms)';

  @override
  String get resetButton => 'Reset';

  @override
  String get audioProcessingSection => 'Audio processing';

  @override
  String get surroundSoundOption => 'Surround sound';

  @override
  String get surroundSoundSubtitle => 'Virtual surround simulation';

  @override
  String get bassBoostOption => 'Bass Boost';

  @override
  String get bassBoostSubtitle => 'Amplify low frequencies';

  @override
  String get subtitlesSection => 'Subtitles';

  @override
  String get subAppearanceSection => 'Appearance';

  @override
  String get subPositionSection => 'Position';

  @override
  String get subBehaviorSection => 'Behavior';

  @override
  String get subCompatibilitySection => 'Compatibility';

  @override
  String get fontSizeOption => 'Font size';

  @override
  String get fontFamilyOption => 'Font family';

  @override
  String get subScaleOption => 'Subtitle scale';

  @override
  String get lineSpacingOption => 'Line spacing';

  @override
  String get maxLinesOption => 'Max lines';

  @override
  String get wrapTextOption => 'Wrap text';

  @override
  String get wrapTextSubtitle => 'Auto wrap subtitle text';

  @override
  String get letterSpacingOption => 'Letter spacing';

  @override
  String get wordSpacingOption => 'Word spacing';

  @override
  String get fontWeightOption => 'Font weight';

  @override
  String get fontWeightLight => 'Light';

  @override
  String get fontWeightNormal => 'Normal';

  @override
  String get fontWeightSemiBold => 'Semi-bold';

  @override
  String get fontWeightBold => 'Bold';

  @override
  String get textOpacityOption => 'Text opacity';

  @override
  String get textColorOption => 'Text color';

  @override
  String get backgroundSwitch => 'Text background';

  @override
  String get backgroundColorOption => 'Background color';

  @override
  String get backgroundOpacityOption => 'Background opacity';

  @override
  String get backgroundRadiusOption => 'Background radius';

  @override
  String get outlineSwitch => 'Text outline';

  @override
  String get outlineSubtitle => 'Outline around each character';

  @override
  String get outlineColorOption => 'Outline color';

  @override
  String get outlineWidthOption => 'Outline width';

  @override
  String get outlineScaleOption => 'Outline scale';

  @override
  String get shadowSwitch => 'Text shadow';

  @override
  String get shadowSubtitle => 'Shadow behind subtitle text';

  @override
  String get shadowColorOption => 'Shadow color';

  @override
  String get shadowOpacityOption => 'Shadow opacity';

  @override
  String get shadowOffsetXOption => 'Horizontal offset';

  @override
  String get shadowOffsetYOption => 'Vertical offset';

  @override
  String get shadowBlurOption => 'Shadow blur';

  @override
  String get backgroundSection => 'Background';

  @override
  String get backgroundShapeOption => 'Background shape';

  @override
  String get backgroundShapeRectangle => 'Rectangle';

  @override
  String get backgroundShapeRounded => 'Rounded';

  @override
  String get backgroundShapeCapsule => 'Capsule';

  @override
  String get backgroundBorderSwitch => 'Background border';

  @override
  String get backgroundBorderColorOption => 'Border color';

  @override
  String get backgroundBorderWidthOption => 'Border width';

  @override
  String get backgroundPaddingOption => 'Background padding';

  @override
  String get italicOption => 'Italic effect';

  @override
  String get italicSubtitle => 'Enable italic font for subtitles';

  @override
  String get resetAppearanceButton => 'Reset appearance';

  @override
  String get positionOption => 'Subtitle position';

  @override
  String get positionTop => 'Top';

  @override
  String get positionCenter => 'Center';

  @override
  String get positionBottom => 'Bottom';

  @override
  String get bottomMarginOption => 'Bottom margin';

  @override
  String get horizontalMarginOption => 'Horizontal margin';

  @override
  String get verticalMarginOption => 'Vertical margin';

  @override
  String get safeAreaPaddingOption => 'Safe area padding';

  @override
  String get keepInsideVideoOption => 'Keep inside video';

  @override
  String get keepInsideVideoSubtitle =>
      'Prevent subtitles from going outside video boundaries';

  @override
  String get respectNotchOption => 'Respect notch';

  @override
  String get respectNotchSubtitle => 'Avoid notch area';

  @override
  String get textDirectionOption => 'Text direction';

  @override
  String get textDirectionRTL => 'Right to left';

  @override
  String get textDirectionLTR => 'Left to right';

  @override
  String get resetPositionButton => 'Reset position';

  @override
  String get autoShowSubtitlesOption => 'Auto show subtitles';

  @override
  String get autoShowSubtitlesSubtitle => 'Enable on playback start';

  @override
  String get subtitleFolderOption => 'Subtitle folder';

  @override
  String get subtitleEncodingOption => 'Character encoding';

  @override
  String get preferredSubtitleLanguageOption => 'Preferred subtitle language';

  @override
  String get defaultSyncOption => 'Default sync';

  @override
  String get scaleModeOption => 'Scale mode';

  @override
  String get scaleModeFixed => 'Fixed size';

  @override
  String get scaleModeResolution => 'By resolution';

  @override
  String get scaleModeWindow => 'By window';

  @override
  String get scaleModeSmart => 'Smart (recommended)';

  @override
  String get loadLastUsedOption => 'Load last used subtitle';

  @override
  String get hideWhenNoDialogOption => 'Hide when no dialog';

  @override
  String get resetBehaviorButton => 'Reset behavior';

  @override
  String get improveAnimationOption => 'Improve font animation';

  @override
  String get complexTextOption => 'Complex text rendering';

  @override
  String get improveSsaAssOption => 'Improve SSA/ASS rendering';

  @override
  String get ignoreAssFontsOption => 'Ignore ASS fonts';

  @override
  String get ignoreAssEffectsOption => 'Ignore ASS effects';

  @override
  String get unicodeSupportOption => 'Full Unicode support';

  @override
  String get antiAliasingOption => 'Anti-aliasing';

  @override
  String get hdrSupportOption => 'HDR support';

  @override
  String get resetCompatibilityButton => 'Reset compatibility';

  @override
  String get librarySection => 'Library';

  @override
  String get sortByOption => 'Default sort';

  @override
  String get sortDescOption => 'Descending order';

  @override
  String get libraryGridViewOption => 'Library grid view';

  @override
  String get foldersGridViewOption => 'Folders grid view';

  @override
  String get recentGridViewOption => 'Recent grid view';

  @override
  String get hiddenFilesOption => 'Hidden files';

  @override
  String get storageSection => 'Storage';

  @override
  String get thumbnailCacheOption => 'Thumbnail cache';

  @override
  String get calculatingSize => 'Calculating...';

  @override
  String get clearCacheButton => 'Clear';

  @override
  String get backupSection => 'Backup';

  @override
  String get exportSettingsOption => 'Export settings';

  @override
  String get importSettingsOption => 'Import settings';

  @override
  String get resetAllButton => 'Reset all settings';

  @override
  String get resetAllDialogTitle => 'Reset settings';

  @override
  String get resetAllDialogBody =>
      'Are you sure you want to reset all settings to default?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmResetButton => 'Reset';

  @override
  String get settingsSavedMessage => 'Settings restored';

  @override
  String get clearCacheDialogTitle => 'Clear thumbnail cache';

  @override
  String get clearCacheDialogBody =>
      'All cached thumbnails will be deleted and regenerated when you open the library again.';

  @override
  String get cacheClearedMessage => 'Thumbnail cache cleared';

  @override
  String exportSuccessMessage(Object path) {
    return 'Settings saved to: $path';
  }

  @override
  String exportFailMessage(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get importSuccessMessage => 'Settings imported successfully';

  @override
  String importFailMessage(Object error) {
    return 'Import failed: $error';
  }

  @override
  String get decoderAuto => 'Auto (recommended)';

  @override
  String get decoderHW => 'HW+ (hardware)';

  @override
  String get decoderSW => 'SW (software)';

  @override
  String get colorFormatYCbCr => 'YCbCr (default)';

  @override
  String get colorFormatRGBFull => 'RGB Full (vivid colors)';

  @override
  String get colorFormatRGBLimited => 'RGB Limited';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get sortByName => 'Name';

  @override
  String get sortBySize => 'Size';

  @override
  String get sortByDuration => 'Duration';

  @override
  String get sortByDate => 'Date';

  @override
  String get videoModeContain => 'Contain';

  @override
  String get videoModeCover => 'Cover';

  @override
  String get videoModeFill => 'Fill';

  @override
  String get videoModeStretch => 'Stretch';

  @override
  String get audioModeStereo => 'Stereo';

  @override
  String get audioModeMono => 'Mono';

  @override
  String get audioModeSurround => 'Surround';

  @override
  String get equalizerDialogTitle => 'Graphic Equalizer';

  @override
  String get applyButton => 'Apply';
}
