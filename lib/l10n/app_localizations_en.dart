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

  @override
  String get appTitle => 'SR Player';

  @override
  String get libraryTab => 'Library';

  @override
  String get myFilesTab => 'My Files';

  @override
  String get recentTab => 'Recent';

  @override
  String get personalTab => 'Personal';

  @override
  String get collectionsTooltip => 'Collections';

  @override
  String get viewOptionsTooltip => 'View & Sort Options';

  @override
  String get searchTooltip => 'Search';

  @override
  String get favoritesLabel => 'Favorites';

  @override
  String get playlistLabel => 'Playlist';

  @override
  String get queueLabel => 'Queue';

  @override
  String get gridView => 'Grid';

  @override
  String get listView => 'List';

  @override
  String get descending => 'Descending';

  @override
  String get ascending => 'Ascending';

  @override
  String get noPreviousVideo => 'No previous video';

  @override
  String selectedCount(Object selected, Object total) {
    return '$selected / $total selected';
  }

  @override
  String get shareFiles => 'Share files';

  @override
  String hiddenFilesToast(Object count) {
    return '$count file(s) hidden';
  }

  @override
  String get backToFolders => 'Back to folders';

  @override
  String videosCount(Object count) {
    return '$count video(s)';
  }

  @override
  String get playVideo => 'Play';

  @override
  String get videoInfo => 'Info';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get alreadyInPlaylist => 'Already in playlist';

  @override
  String get addedToPlaylist => 'Added to playlist';

  @override
  String get alreadyInPlaylistToast => 'File already in playlist';

  @override
  String get renameFile => 'Rename';

  @override
  String get share => 'Share';

  @override
  String get copyPath => 'Copy path';

  @override
  String get openInFileManager => 'Open in file manager';

  @override
  String get hide => 'Hide';

  @override
  String get unhide => 'Unhide';

  @override
  String get delete => 'Delete';

  @override
  String get playAll => 'Play all';

  @override
  String get shufflePlay => 'Shuffle play';

  @override
  String get hideAll => 'Hide all';

  @override
  String get unhideAll => 'Show all';

  @override
  String get deleteFolder => 'Delete folder';

  @override
  String get renameDialogTitle => 'Rename';

  @override
  String get newNameHint => 'New name';

  @override
  String get okButton => 'OK';

  @override
  String get deleteFileTitle => 'Delete file';

  @override
  String deleteFileConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get deleteFilesTitle => 'Delete files';

  @override
  String deleteFilesConfirm(Object count) {
    return 'Are you sure you want to delete $count video(s)?';
  }

  @override
  String get deleteFolderTitle => 'Delete folder';

  @override
  String deleteFolderConfirm(Object count) {
    return 'Are you sure you want to delete $count video(s)?';
  }

  @override
  String fileDeletedToast(Object name) {
    return '\"$name\" deleted';
  }

  @override
  String filesDeletedToast(Object count) {
    return '$count video(s) deleted';
  }

  @override
  String get renameSuccess => 'Renamed successfully';

  @override
  String renameFailed(Object error) {
    return 'Rename failed: $error';
  }

  @override
  String get pathCopiedToast => 'Path copied';

  @override
  String get fileManagerError => 'Could not open file manager';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get cancel => 'Cancel';

  @override
  String hideFilesToast(Object count) {
    return '$count file(s) hidden';
  }

  @override
  String folderVideosCount(Object count, Object size) {
    return '$count video(s)  •  $size';
  }

  @override
  String get screenLocked => 'Screen locked';

  @override
  String get colorAdjustment => 'Color adjustment';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get speed => 'Speed';

  @override
  String get custom => 'Custom';

  @override
  String get apply => 'Apply';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get selectTimeMinutes => 'Select time (minutes)';

  @override
  String get customMinute => 'Custom (minute)';

  @override
  String get start => 'Start';

  @override
  String resumeFrom(Object time) {
    return 'Resume from $time';
  }

  @override
  String get tapToStartFromBeginning => 'Tap to start from beginning';

  @override
  String get subtitleSettings => 'Subtitle settings';

  @override
  String get audioSettings => 'Audio settings';

  @override
  String get more => 'More';

  @override
  String get playlistEditor => 'Playlist editor';

  @override
  String get releaseToOpen => 'Release to open';

  @override
  String get slideToUnlock => 'Slide to unlock →';

  @override
  String get subtitleLoaded => '✅ Subtitle loaded';

  @override
  String subtitleLoadFailed(Object error) {
    return 'Failed to load subtitle: $error';
  }

  @override
  String get externalSubtitleRemoved => 'External subtitle removed';

  @override
  String playerError(Object error) {
    return 'Unable to play file: $error';
  }

  @override
  String statsResolution(Object height, Object res, Object width) {
    return 'Resolution: $width×$height ($res)';
  }

  @override
  String statsCodec(Object codec) {
    return 'Codec: $codec';
  }

  @override
  String statsFps(Object fps) {
    return 'Frame rate: $fps fps';
  }

  @override
  String statsHdr(Object status) {
    return 'HDR: $status';
  }

  @override
  String statsHw(Object status) {
    return 'Hardware acceleration: $status';
  }

  @override
  String statsPosition(Object dur, Object pos) {
    return 'Position: $pos / $dur';
  }

  @override
  String statsSpeed(Object speed) {
    return 'Speed: ${speed}x';
  }

  @override
  String statsAudioDelay(Object delay) {
    return 'Audio delay: ${delay}s';
  }

  @override
  String statsSubSync(Object sync) {
    return 'Subtitle sync: ${sync}s';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get nightModeOn => 'Night mode enabled';

  @override
  String get nightModeOff => 'Night mode disabled';

  @override
  String get sleepTimerStopped => 'Playback stopped by sleep timer';
}
