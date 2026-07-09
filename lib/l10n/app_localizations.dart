import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @mediaKitInitError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تهيئة MediaKit:\n{error}'**
  String mediaKitInitError(String error);

  /// No description provided for @ffmpegInitError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تهيئة FFmpeg:\n{error}'**
  String ffmpegInitError(Object error);

  /// No description provided for @settingsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الإعدادات:\n{error}'**
  String settingsLoadError(Object error);

  /// No description provided for @errorOccurredTitle.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، حدث خطأ'**
  String get errorOccurredTitle;

  /// No description provided for @retryButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryButton;

  /// No description provided for @requestingPermissions.
  ///
  /// In ar, this message translates to:
  /// **'جاري طلب الصلاحيات...'**
  String get requestingPermissions;

  /// No description provided for @permissionsRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات مطلوبة'**
  String get permissionsRequiredTitle;

  /// No description provided for @permissionsRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج التطبيق إلى إذن الوصول إلى الوسائط لعرض الفيديوهات.'**
  String get permissionsRequiredBody;

  /// No description provided for @grantPermissionsButton.
  ///
  /// In ar, this message translates to:
  /// **'منح الصلاحيات'**
  String get grantPermissionsButton;

  /// No description provided for @scanFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الفيديوهات. اسحب للأسفل أو اضغط لإعادة المحاولة.'**
  String get scanFailedMessage;

  /// No description provided for @skipButton.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skipButton;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTitle;

  /// No description provided for @noFavoriteVideos.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فيديوهات مفضلة'**
  String get noFavoriteVideos;

  /// No description provided for @languageSettingLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageSettingLabel;

  /// No description provided for @systemLanguageOption.
  ///
  /// In ar, this message translates to:
  /// **'لغة النظام'**
  String get systemLanguageOption;

  /// No description provided for @arabicLanguageOption.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabicLanguageOption;

  /// No description provided for @englishLanguageOption.
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get englishLanguageOption;

  /// No description provided for @frenchLanguageOption.
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية'**
  String get frenchLanguageOption;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @generalSection.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get generalSection;

  /// No description provided for @appearanceOption.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearanceOption;

  /// No description provided for @languageOption.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get languageOption;

  /// No description provided for @themeColorOption.
  ///
  /// In ar, this message translates to:
  /// **'لون التطبيق'**
  String get themeColorOption;

  /// No description provided for @themeColorSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لون الواجهة الأساسي (Material You)'**
  String get themeColorSubtitle;

  /// No description provided for @playerSection.
  ///
  /// In ar, this message translates to:
  /// **'المشغل'**
  String get playerSection;

  /// No description provided for @playbackSection.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل'**
  String get playbackSection;

  /// No description provided for @autoPlayOption.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل التلقائي'**
  String get autoPlayOption;

  /// No description provided for @resumePositionOption.
  ///
  /// In ar, this message translates to:
  /// **'استئناف آخر موضع'**
  String get resumePositionOption;

  /// No description provided for @rememberSpeedOption.
  ///
  /// In ar, this message translates to:
  /// **'تذكر سرعة التشغيل'**
  String get rememberSpeedOption;

  /// No description provided for @repeatModeOption.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل المتكرر'**
  String get repeatModeOption;

  /// No description provided for @repeatNone.
  ///
  /// In ar, this message translates to:
  /// **'بدون'**
  String get repeatNone;

  /// No description provided for @repeatVideo.
  ///
  /// In ar, this message translates to:
  /// **'تكرار: الفيديو'**
  String get repeatVideo;

  /// No description provided for @repeatPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'تكرار: القائمة'**
  String get repeatPlaylist;

  /// No description provided for @autoNextOption.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال للفيديو التالي تلقائياً'**
  String get autoNextOption;

  /// No description provided for @autoPipOption.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال للوضع المصغر عند الخروج'**
  String get autoPipOption;

  /// No description provided for @speedSection.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل'**
  String get speedSection;

  /// No description provided for @defaultSpeedOption.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل الافتراضية'**
  String get defaultSpeedOption;

  /// No description provided for @rememberLastSpeedOption.
  ///
  /// In ar, this message translates to:
  /// **'تذكر آخر سرعة'**
  String get rememberLastSpeedOption;

  /// No description provided for @allow4xOption.
  ///
  /// In ar, this message translates to:
  /// **'السماح بسرعة حتى 4×'**
  String get allow4xOption;

  /// No description provided for @pitchCorrectionOption.
  ///
  /// In ar, this message translates to:
  /// **'تصحيح طبقة الصوت (Pitch Correction)'**
  String get pitchCorrectionOption;

  /// No description provided for @videoDisplaySection.
  ///
  /// In ar, this message translates to:
  /// **'عرض الفيديو'**
  String get videoDisplaySection;

  /// No description provided for @defaultVideoModeOption.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الافتراضي'**
  String get defaultVideoModeOption;

  /// No description provided for @rememberVideoModeOption.
  ///
  /// In ar, this message translates to:
  /// **'تذكر آخر وضع'**
  String get rememberVideoModeOption;

  /// No description provided for @autoRotateOption.
  ///
  /// In ar, this message translates to:
  /// **'تدوير تلقائي'**
  String get autoRotateOption;

  /// No description provided for @autoFullscreenOption.
  ///
  /// In ar, this message translates to:
  /// **'ملء الشاشة تلقائياً'**
  String get autoFullscreenOption;

  /// No description provided for @keepScreenOnOption.
  ///
  /// In ar, this message translates to:
  /// **'إبقاء الشاشة مضاءة'**
  String get keepScreenOnOption;

  /// No description provided for @gesturesSection.
  ///
  /// In ar, this message translates to:
  /// **'التحكم بالإيماءات'**
  String get gesturesSection;

  /// No description provided for @gestureVolumeOption.
  ///
  /// In ar, this message translates to:
  /// **'السحب للصوت'**
  String get gestureVolumeOption;

  /// No description provided for @gestureBrightnessOption.
  ///
  /// In ar, this message translates to:
  /// **'السحب للسطوع'**
  String get gestureBrightnessOption;

  /// No description provided for @gestureSeekOption.
  ///
  /// In ar, this message translates to:
  /// **'السحب للتقديم والترجيع'**
  String get gestureSeekOption;

  /// No description provided for @tapToPauseOption.
  ///
  /// In ar, this message translates to:
  /// **'النقر للإيقاف'**
  String get tapToPauseOption;

  /// No description provided for @doubleTapOption.
  ///
  /// In ar, this message translates to:
  /// **'النقر المزدوج'**
  String get doubleTapOption;

  /// No description provided for @longPressSpeedOption.
  ///
  /// In ar, this message translates to:
  /// **'الضغط المطول = سرعة مؤقتة ×2'**
  String get longPressSpeedOption;

  /// No description provided for @vibrateOnEndOption.
  ///
  /// In ar, this message translates to:
  /// **'اهتزاز عند الوصول للنهاية'**
  String get vibrateOnEndOption;

  /// No description provided for @seekSection.
  ///
  /// In ar, this message translates to:
  /// **'التقديم والترجيع'**
  String get seekSection;

  /// No description provided for @seekDurationOption.
  ///
  /// In ar, this message translates to:
  /// **'مدة التخطي'**
  String get seekDurationOption;

  /// No description provided for @seekPreviewOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار معاينة أثناء السحب'**
  String get seekPreviewOption;

  /// No description provided for @seekTimeOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الوقت أثناء السحب'**
  String get seekTimeOption;

  /// No description provided for @uiSection.
  ///
  /// In ar, this message translates to:
  /// **'واجهة المشغل'**
  String get uiSection;

  /// No description provided for @autoHideControlsOption.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الأزرار تلقائياً'**
  String get autoHideControlsOption;

  /// No description provided for @hideDelayOption.
  ///
  /// In ar, this message translates to:
  /// **'مدة الإخفاء'**
  String get hideDelayOption;

  /// No description provided for @showRemainingTimeOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الوقت المتبقي'**
  String get showRemainingTimeOption;

  /// No description provided for @showElapsedTimeOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الوقت المنقضي'**
  String get showElapsedTimeOption;

  /// No description provided for @showVideoTitleOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار اسم الفيديو'**
  String get showVideoTitleOption;

  /// No description provided for @showBatteryOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار البطارية'**
  String get showBatteryOption;

  /// No description provided for @showClockOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الساعة'**
  String get showClockOption;

  /// No description provided for @playlistSection.
  ///
  /// In ar, this message translates to:
  /// **'القوائم'**
  String get playlistSection;

  /// No description provided for @continuousPlaybackOption.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل المتواصل'**
  String get continuousPlaybackOption;

  /// No description provided for @removeAfterPlaybackOption.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الفيديو بعد التشغيل'**
  String get removeAfterPlaybackOption;

  /// No description provided for @rememberPlaylistOption.
  ///
  /// In ar, this message translates to:
  /// **'تذكر القائمة الأخيرة'**
  String get rememberPlaylistOption;

  /// No description provided for @savePlaylistOrderOption.
  ///
  /// In ar, this message translates to:
  /// **'حفظ ترتيب التشغيل'**
  String get savePlaylistOrderOption;

  /// No description provided for @shufflePlaylistOption.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل عشوائي'**
  String get shufflePlaylistOption;

  /// No description provided for @energySection.
  ///
  /// In ar, this message translates to:
  /// **'الطاقة'**
  String get energySection;

  /// No description provided for @preventLockOption.
  ///
  /// In ar, this message translates to:
  /// **'منع قفل الشاشة'**
  String get preventLockOption;

  /// No description provided for @reduceBrightnessOption.
  ///
  /// In ar, this message translates to:
  /// **'خفض السطوع عند التوقف'**
  String get reduceBrightnessOption;

  /// No description provided for @stopAfterVideoOption.
  ///
  /// In ar, this message translates to:
  /// **'إيقاف التشغيل بعد انتهاء الفيديو'**
  String get stopAfterVideoOption;

  /// No description provided for @sleepTimerOption.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت النوم (Sleep Timer)'**
  String get sleepTimerOption;

  /// No description provided for @sleepTimerDisabled.
  ///
  /// In ar, this message translates to:
  /// **'معطل'**
  String get sleepTimerDisabled;

  /// No description provided for @sleepTimerMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة'**
  String sleepTimerMinutes(Object minutes);

  /// No description provided for @controlSection.
  ///
  /// In ar, this message translates to:
  /// **'التحكم'**
  String get controlSection;

  /// No description provided for @volumeKeysSeekOption.
  ///
  /// In ar, this message translates to:
  /// **'أزرار الصوت للتقديم'**
  String get volumeKeysSeekOption;

  /// No description provided for @keyboardSupportOption.
  ///
  /// In ar, this message translates to:
  /// **'دعم لوحة المفاتيح'**
  String get keyboardSupportOption;

  /// No description provided for @gamepadSupportOption.
  ///
  /// In ar, this message translates to:
  /// **'دعم يد التحكم'**
  String get gamepadSupportOption;

  /// No description provided for @advancedSection.
  ///
  /// In ar, this message translates to:
  /// **'خيارات متقدمة'**
  String get advancedSection;

  /// No description provided for @decoderModeOption.
  ///
  /// In ar, this message translates to:
  /// **'وضع فك التشفير'**
  String get decoderModeOption;

  /// No description provided for @fallbackSoftwareOption.
  ///
  /// In ar, this message translates to:
  /// **'الرجوع إلى Software عند الفشل'**
  String get fallbackSoftwareOption;

  /// No description provided for @lowLatencyOption.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل منخفض التأخير'**
  String get lowLatencyOption;

  /// No description provided for @frameDroppingOption.
  ///
  /// In ar, this message translates to:
  /// **'Frame Dropping'**
  String get frameDroppingOption;

  /// No description provided for @vsyncOption.
  ///
  /// In ar, this message translates to:
  /// **'VSync'**
  String get vsyncOption;

  /// No description provided for @loggingOption.
  ///
  /// In ar, this message translates to:
  /// **'Logging'**
  String get loggingOption;

  /// No description provided for @showVideoInfoOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار معلومات الفيديو'**
  String get showVideoInfoOption;

  /// No description provided for @audioSection.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get audioSection;

  /// No description provided for @audioGeneralSection.
  ///
  /// In ar, this message translates to:
  /// **'الصوت العام'**
  String get audioGeneralSection;

  /// No description provided for @audioBoostOption.
  ///
  /// In ar, this message translates to:
  /// **'تضخيم الصوت الافتراضي'**
  String get audioBoostOption;

  /// No description provided for @audioBalanceOption.
  ///
  /// In ar, this message translates to:
  /// **'موازنة الصوت (Balance)'**
  String get audioBalanceOption;

  /// No description provided for @rememberVolumeOption.
  ///
  /// In ar, this message translates to:
  /// **'تذكر مستوى الصوت لكل فيديو'**
  String get rememberVolumeOption;

  /// No description provided for @resetVolumeOption.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط مستوى الصوت لكل فيديو'**
  String get resetVolumeOption;

  /// No description provided for @audioOutputSection.
  ///
  /// In ar, this message translates to:
  /// **'إخراج الصوت'**
  String get audioOutputSection;

  /// No description provided for @audioOutputModeOption.
  ///
  /// In ar, this message translates to:
  /// **'وضع إخراج الصوت'**
  String get audioOutputModeOption;

  /// No description provided for @autoBluetoothOption.
  ///
  /// In ar, this message translates to:
  /// **'التحويل التلقائي عند توصيل سماعة'**
  String get autoBluetoothOption;

  /// No description provided for @audioTracksSection.
  ///
  /// In ar, this message translates to:
  /// **'المسارات الصوتية'**
  String get audioTracksSection;

  /// No description provided for @preferredAudioLanguageOption.
  ///
  /// In ar, this message translates to:
  /// **'لغة الصوت المفضلة'**
  String get preferredAudioLanguageOption;

  /// No description provided for @equalizerSection.
  ///
  /// In ar, this message translates to:
  /// **'معادل الصوت'**
  String get equalizerSection;

  /// No description provided for @equalizerEnabledOption.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل المعادل'**
  String get equalizerEnabledOption;

  /// No description provided for @openEqualizerOption.
  ///
  /// In ar, this message translates to:
  /// **'فتح المعادل الرسومي'**
  String get openEqualizerOption;

  /// No description provided for @equalizerBandsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'10 نطاقات'**
  String get equalizerBandsSubtitle;

  /// No description provided for @audioSyncSection.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الصوت'**
  String get audioSyncSection;

  /// No description provided for @audioDelayOption.
  ///
  /// In ar, this message translates to:
  /// **'تأخير الصوت (ms)'**
  String get audioDelayOption;

  /// No description provided for @resetButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط'**
  String get resetButton;

  /// No description provided for @audioProcessingSection.
  ///
  /// In ar, this message translates to:
  /// **'معالجة الصوت'**
  String get audioProcessingSection;

  /// No description provided for @surroundSoundOption.
  ///
  /// In ar, this message translates to:
  /// **'صوت محيطي (Surround)'**
  String get surroundSoundOption;

  /// No description provided for @surroundSoundSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'محاكاة صوت محيطي'**
  String get surroundSoundSubtitle;

  /// No description provided for @bassBoostOption.
  ///
  /// In ar, this message translates to:
  /// **'Bass Boost'**
  String get bassBoostOption;

  /// No description provided for @bassBoostSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تضخيم الترددات المنخفضة'**
  String get bassBoostSubtitle;

  /// No description provided for @subtitlesSection.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get subtitlesSection;

  /// No description provided for @subAppearanceSection.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get subAppearanceSection;

  /// No description provided for @subPositionSection.
  ///
  /// In ar, this message translates to:
  /// **'الموضع'**
  String get subPositionSection;

  /// No description provided for @subBehaviorSection.
  ///
  /// In ar, this message translates to:
  /// **'السلوك'**
  String get subBehaviorSection;

  /// No description provided for @subCompatibilitySection.
  ///
  /// In ar, this message translates to:
  /// **'التوافق'**
  String get subCompatibilitySection;

  /// No description provided for @fontSizeOption.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSizeOption;

  /// No description provided for @fontFamilyOption.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخط'**
  String get fontFamilyOption;

  /// No description provided for @subScaleOption.
  ///
  /// In ar, this message translates to:
  /// **'مقياس الترجمة'**
  String get subScaleOption;

  /// No description provided for @lineSpacingOption.
  ///
  /// In ar, this message translates to:
  /// **'تباعد الأسطر'**
  String get lineSpacingOption;

  /// No description provided for @maxLinesOption.
  ///
  /// In ar, this message translates to:
  /// **'أقصى عدد للأسطر'**
  String get maxLinesOption;

  /// No description provided for @wrapTextOption.
  ///
  /// In ar, this message translates to:
  /// **'لف النص'**
  String get wrapTextOption;

  /// No description provided for @wrapTextSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لف النص التلقائي للترجمة'**
  String get wrapTextSubtitle;

  /// No description provided for @letterSpacingOption.
  ///
  /// In ar, this message translates to:
  /// **'تباعد الحروف'**
  String get letterSpacingOption;

  /// No description provided for @wordSpacingOption.
  ///
  /// In ar, this message translates to:
  /// **'تباعد الكلمات'**
  String get wordSpacingOption;

  /// No description provided for @fontWeightOption.
  ///
  /// In ar, this message translates to:
  /// **'سمك الخط'**
  String get fontWeightOption;

  /// No description provided for @fontWeightLight.
  ///
  /// In ar, this message translates to:
  /// **'خفيف'**
  String get fontWeightLight;

  /// No description provided for @fontWeightNormal.
  ///
  /// In ar, this message translates to:
  /// **'عادي'**
  String get fontWeightNormal;

  /// No description provided for @fontWeightSemiBold.
  ///
  /// In ar, this message translates to:
  /// **'شبه عريض'**
  String get fontWeightSemiBold;

  /// No description provided for @fontWeightBold.
  ///
  /// In ar, this message translates to:
  /// **'عريض جداً'**
  String get fontWeightBold;

  /// No description provided for @textOpacityOption.
  ///
  /// In ar, this message translates to:
  /// **'شفافية النص'**
  String get textOpacityOption;

  /// No description provided for @textColorOption.
  ///
  /// In ar, this message translates to:
  /// **'لون النص'**
  String get textColorOption;

  /// No description provided for @backgroundSwitch.
  ///
  /// In ar, this message translates to:
  /// **'خلفية النص'**
  String get backgroundSwitch;

  /// No description provided for @backgroundColorOption.
  ///
  /// In ar, this message translates to:
  /// **'لون الخلفية'**
  String get backgroundColorOption;

  /// No description provided for @backgroundOpacityOption.
  ///
  /// In ar, this message translates to:
  /// **'شفافية الخلفية'**
  String get backgroundOpacityOption;

  /// No description provided for @backgroundRadiusOption.
  ///
  /// In ar, this message translates to:
  /// **'زوايا الخلفية'**
  String get backgroundRadiusOption;

  /// No description provided for @outlineSwitch.
  ///
  /// In ar, this message translates to:
  /// **'حدّ خارجي للنص'**
  String get outlineSwitch;

  /// No description provided for @outlineSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إطار حول كل حرف'**
  String get outlineSubtitle;

  /// No description provided for @outlineColorOption.
  ///
  /// In ar, this message translates to:
  /// **'لون الحدّ'**
  String get outlineColorOption;

  /// No description provided for @outlineWidthOption.
  ///
  /// In ar, this message translates to:
  /// **'سماكة الحدّ'**
  String get outlineWidthOption;

  /// No description provided for @outlineScaleOption.
  ///
  /// In ar, this message translates to:
  /// **'مقياس مستقل للحدود'**
  String get outlineScaleOption;

  /// No description provided for @shadowSwitch.
  ///
  /// In ar, this message translates to:
  /// **'ظل النص'**
  String get shadowSwitch;

  /// No description provided for @shadowSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ظل خلف نص الترجمة'**
  String get shadowSubtitle;

  /// No description provided for @shadowColorOption.
  ///
  /// In ar, this message translates to:
  /// **'لون الظل'**
  String get shadowColorOption;

  /// No description provided for @shadowOpacityOption.
  ///
  /// In ar, this message translates to:
  /// **'شفافية الظل'**
  String get shadowOpacityOption;

  /// No description provided for @shadowOffsetXOption.
  ///
  /// In ar, this message translates to:
  /// **'إزاحة أفقية'**
  String get shadowOffsetXOption;

  /// No description provided for @shadowOffsetYOption.
  ///
  /// In ar, this message translates to:
  /// **'إزاحة رأسية'**
  String get shadowOffsetYOption;

  /// No description provided for @shadowBlurOption.
  ///
  /// In ar, this message translates to:
  /// **'تمويه الظل'**
  String get shadowBlurOption;

  /// No description provided for @backgroundSection.
  ///
  /// In ar, this message translates to:
  /// **'الخلفية'**
  String get backgroundSection;

  /// No description provided for @backgroundShapeOption.
  ///
  /// In ar, this message translates to:
  /// **'شكل الخلفية'**
  String get backgroundShapeOption;

  /// No description provided for @backgroundShapeRectangle.
  ///
  /// In ar, this message translates to:
  /// **'مستطيل'**
  String get backgroundShapeRectangle;

  /// No description provided for @backgroundShapeRounded.
  ///
  /// In ar, this message translates to:
  /// **'مدور'**
  String get backgroundShapeRounded;

  /// No description provided for @backgroundShapeCapsule.
  ///
  /// In ar, this message translates to:
  /// **'كبسولة'**
  String get backgroundShapeCapsule;

  /// No description provided for @backgroundBorderSwitch.
  ///
  /// In ar, this message translates to:
  /// **'حدود الخلفية'**
  String get backgroundBorderSwitch;

  /// No description provided for @backgroundBorderColorOption.
  ///
  /// In ar, this message translates to:
  /// **'لون الحدود'**
  String get backgroundBorderColorOption;

  /// No description provided for @backgroundBorderWidthOption.
  ///
  /// In ar, this message translates to:
  /// **'سماكة الحدود'**
  String get backgroundBorderWidthOption;

  /// No description provided for @backgroundPaddingOption.
  ///
  /// In ar, this message translates to:
  /// **'Padding الخلفية'**
  String get backgroundPaddingOption;

  /// No description provided for @italicOption.
  ///
  /// In ar, this message translates to:
  /// **'تأثير مائل'**
  String get italicOption;

  /// No description provided for @italicSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الخط المائل للترجمة'**
  String get italicSubtitle;

  /// No description provided for @resetAppearanceButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط المظهر'**
  String get resetAppearanceButton;

  /// No description provided for @positionOption.
  ///
  /// In ar, this message translates to:
  /// **'موضع الترجمة'**
  String get positionOption;

  /// No description provided for @positionTop.
  ///
  /// In ar, this message translates to:
  /// **'أعلى'**
  String get positionTop;

  /// No description provided for @positionCenter.
  ///
  /// In ar, this message translates to:
  /// **'وسط'**
  String get positionCenter;

  /// No description provided for @positionBottom.
  ///
  /// In ar, this message translates to:
  /// **'أسفل'**
  String get positionBottom;

  /// No description provided for @bottomMarginOption.
  ///
  /// In ar, this message translates to:
  /// **'الارتفاع عن الأسفل'**
  String get bottomMarginOption;

  /// No description provided for @horizontalMarginOption.
  ///
  /// In ar, this message translates to:
  /// **'الهامش الأفقي'**
  String get horizontalMarginOption;

  /// No description provided for @verticalMarginOption.
  ///
  /// In ar, this message translates to:
  /// **'الهامش العمودي'**
  String get verticalMarginOption;

  /// No description provided for @safeAreaPaddingOption.
  ///
  /// In ar, this message translates to:
  /// **'هامش الأمان'**
  String get safeAreaPaddingOption;

  /// No description provided for @keepInsideVideoOption.
  ///
  /// In ar, this message translates to:
  /// **'البقاء داخل الفيديو'**
  String get keepInsideVideoOption;

  /// No description provided for @keepInsideVideoSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عدم خروج الترجمة خارج حدود الفيديو'**
  String get keepInsideVideoSubtitle;

  /// No description provided for @respectNotchOption.
  ///
  /// In ar, this message translates to:
  /// **'احترام النوتش'**
  String get respectNotchOption;

  /// No description provided for @respectNotchSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تجنب منطقة الثقب أو النوتش'**
  String get respectNotchSubtitle;

  /// No description provided for @textDirectionOption.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه النص'**
  String get textDirectionOption;

  /// No description provided for @textDirectionRTL.
  ///
  /// In ar, this message translates to:
  /// **'من اليمين إلى اليسار'**
  String get textDirectionRTL;

  /// No description provided for @textDirectionLTR.
  ///
  /// In ar, this message translates to:
  /// **'من اليسار إلى اليمين'**
  String get textDirectionLTR;

  /// No description provided for @resetPositionButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط الموضع'**
  String get resetPositionButton;

  /// No description provided for @autoShowSubtitlesOption.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الترجمة تلقائياً'**
  String get autoShowSubtitlesOption;

  /// No description provided for @autoShowSubtitlesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل عند بدء التشغيل'**
  String get autoShowSubtitlesSubtitle;

  /// No description provided for @subtitleFolderOption.
  ///
  /// In ar, this message translates to:
  /// **'مجلد الترجمة'**
  String get subtitleFolderOption;

  /// No description provided for @subtitleEncodingOption.
  ///
  /// In ar, this message translates to:
  /// **'ترميز الأحرف'**
  String get subtitleEncodingOption;

  /// No description provided for @preferredSubtitleLanguageOption.
  ///
  /// In ar, this message translates to:
  /// **'لغة الترجمة المفضلة'**
  String get preferredSubtitleLanguageOption;

  /// No description provided for @defaultSyncOption.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة افتراضية'**
  String get defaultSyncOption;

  /// No description provided for @scaleModeOption.
  ///
  /// In ar, this message translates to:
  /// **'طريقة قياس الترجمة'**
  String get scaleModeOption;

  /// No description provided for @scaleModeFixed.
  ///
  /// In ar, this message translates to:
  /// **'حجم ثابت'**
  String get scaleModeFixed;

  /// No description provided for @scaleModeResolution.
  ///
  /// In ar, this message translates to:
  /// **'حسب دقة الفيديو'**
  String get scaleModeResolution;

  /// No description provided for @scaleModeWindow.
  ///
  /// In ar, this message translates to:
  /// **'حسب حجم النافذة'**
  String get scaleModeWindow;

  /// No description provided for @scaleModeSmart.
  ///
  /// In ar, this message translates to:
  /// **'ذكي (موصى به)'**
  String get scaleModeSmart;

  /// No description provided for @loadLastUsedOption.
  ///
  /// In ar, this message translates to:
  /// **'تحميل آخر ترجمة مستخدمة'**
  String get loadLastUsedOption;

  /// No description provided for @hideWhenNoDialogOption.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الترجمة عند عدم وجود حوار'**
  String get hideWhenNoDialogOption;

  /// No description provided for @resetBehaviorButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط السلوك'**
  String get resetBehaviorButton;

  /// No description provided for @improveAnimationOption.
  ///
  /// In ar, this message translates to:
  /// **'تحسين حركة الخط'**
  String get improveAnimationOption;

  /// No description provided for @complexTextOption.
  ///
  /// In ar, this message translates to:
  /// **'تحسين معالجة النصوص المعقدة'**
  String get complexTextOption;

  /// No description provided for @improveSsaAssOption.
  ///
  /// In ar, this message translates to:
  /// **'تحسين عرض SSA/ASS'**
  String get improveSsaAssOption;

  /// No description provided for @ignoreAssFontsOption.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل الخط المحدد داخل ASS'**
  String get ignoreAssFontsOption;

  /// No description provided for @ignoreAssEffectsOption.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل بعض تأثيرات ASS'**
  String get ignoreAssEffectsOption;

  /// No description provided for @unicodeSupportOption.
  ///
  /// In ar, this message translates to:
  /// **'دعم Unicode الكامل'**
  String get unicodeSupportOption;

  /// No description provided for @antiAliasingOption.
  ///
  /// In ar, this message translates to:
  /// **'تحسين Anti-Aliasing'**
  String get antiAliasingOption;

  /// No description provided for @hdrSupportOption.
  ///
  /// In ar, this message translates to:
  /// **'دعم HDR'**
  String get hdrSupportOption;

  /// No description provided for @resetCompatibilityButton.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط التوافق'**
  String get resetCompatibilityButton;

  /// No description provided for @librarySection.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة'**
  String get librarySection;

  /// No description provided for @sortByOption.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب الافتراضي'**
  String get sortByOption;

  /// No description provided for @sortDescOption.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب تنازلي'**
  String get sortDescOption;

  /// No description provided for @libraryGridViewOption.
  ///
  /// In ar, this message translates to:
  /// **'عرض شبكي للمكتبة'**
  String get libraryGridViewOption;

  /// No description provided for @foldersGridViewOption.
  ///
  /// In ar, this message translates to:
  /// **'عرض شبكي للمجلدات'**
  String get foldersGridViewOption;

  /// No description provided for @recentGridViewOption.
  ///
  /// In ar, this message translates to:
  /// **'عرض شبكي للأخيرة'**
  String get recentGridViewOption;

  /// No description provided for @hiddenFilesOption.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المخفية'**
  String get hiddenFilesOption;

  /// No description provided for @storageSection.
  ///
  /// In ar, this message translates to:
  /// **'التخزين'**
  String get storageSection;

  /// No description provided for @thumbnailCacheOption.
  ///
  /// In ar, this message translates to:
  /// **'ذاكرة الصور المصغرة'**
  String get thumbnailCacheOption;

  /// No description provided for @calculatingSize.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الحساب...'**
  String get calculatingSize;

  /// No description provided for @clearCacheButton.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clearCacheButton;

  /// No description provided for @backupSection.
  ///
  /// In ar, this message translates to:
  /// **'النسخ الاحتياطي'**
  String get backupSection;

  /// No description provided for @exportSettingsOption.
  ///
  /// In ar, this message translates to:
  /// **'تصدير الإعدادات'**
  String get exportSettingsOption;

  /// No description provided for @importSettingsOption.
  ///
  /// In ar, this message translates to:
  /// **'استيراد الإعدادات'**
  String get importSettingsOption;

  /// No description provided for @resetAllButton.
  ///
  /// In ar, this message translates to:
  /// **'استعادة الإعدادات الافتراضية'**
  String get resetAllButton;

  /// No description provided for @resetAllDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة الإعدادات'**
  String get resetAllDialogTitle;

  /// No description provided for @resetAllDialogBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إعادة جميع الإعدادات إلى الوضع الافتراضي؟'**
  String get resetAllDialogBody;

  /// No description provided for @cancelButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelButton;

  /// No description provided for @confirmResetButton.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get confirmResetButton;

  /// No description provided for @settingsSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم استعادة الإعدادات'**
  String get settingsSavedMessage;

  /// No description provided for @clearCacheDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسح ذاكرة الصور المصغرة'**
  String get clearCacheDialogTitle;

  /// No description provided for @clearCacheDialogBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف كل الصور المصغرة المخزَّنة، وستُعاد توليدها تلقائياً عند فتح المكتبة من جديد.'**
  String get clearCacheDialogBody;

  /// No description provided for @cacheClearedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم مسح ذاكرة الصور المصغرة'**
  String get cacheClearedMessage;

  /// No description provided for @exportSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الإعدادات في: {path}'**
  String exportSuccessMessage(Object path);

  /// No description provided for @exportFailMessage.
  ///
  /// In ar, this message translates to:
  /// **'فشل التصدير: {error}'**
  String exportFailMessage(Object error);

  /// No description provided for @importSuccessMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم استيراد الإعدادات بنجاح'**
  String get importSuccessMessage;

  /// No description provided for @importFailMessage.
  ///
  /// In ar, this message translates to:
  /// **'فشل الاستيراد: {error}'**
  String importFailMessage(Object error);

  /// No description provided for @decoderAuto.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (موصى)'**
  String get decoderAuto;

  /// No description provided for @decoderHW.
  ///
  /// In ar, this message translates to:
  /// **'HW+ (عتاد)'**
  String get decoderHW;

  /// No description provided for @decoderSW.
  ///
  /// In ar, this message translates to:
  /// **'SW (برمجي)'**
  String get decoderSW;

  /// No description provided for @colorFormatYCbCr.
  ///
  /// In ar, this message translates to:
  /// **'YCbCr (افتراضي)'**
  String get colorFormatYCbCr;

  /// No description provided for @colorFormatRGBFull.
  ///
  /// In ar, this message translates to:
  /// **'RGB Full (ألوان حيوية)'**
  String get colorFormatRGBFull;

  /// No description provided for @colorFormatRGBLimited.
  ///
  /// In ar, this message translates to:
  /// **'RGB Limited'**
  String get colorFormatRGBLimited;

  /// No description provided for @themeDark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeSystem;

  /// No description provided for @sortByName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get sortByName;

  /// No description provided for @sortBySize.
  ///
  /// In ar, this message translates to:
  /// **'الحجم'**
  String get sortBySize;

  /// No description provided for @sortByDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get sortByDuration;

  /// No description provided for @sortByDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get sortByDate;

  /// No description provided for @videoModeContain.
  ///
  /// In ar, this message translates to:
  /// **'Contain'**
  String get videoModeContain;

  /// No description provided for @videoModeCover.
  ///
  /// In ar, this message translates to:
  /// **'Cover'**
  String get videoModeCover;

  /// No description provided for @videoModeFill.
  ///
  /// In ar, this message translates to:
  /// **'Fill'**
  String get videoModeFill;

  /// No description provided for @videoModeStretch.
  ///
  /// In ar, this message translates to:
  /// **'Stretch'**
  String get videoModeStretch;

  /// No description provided for @audioModeStereo.
  ///
  /// In ar, this message translates to:
  /// **'ستيريو'**
  String get audioModeStereo;

  /// No description provided for @audioModeMono.
  ///
  /// In ar, this message translates to:
  /// **'أحادي'**
  String get audioModeMono;

  /// No description provided for @audioModeSurround.
  ///
  /// In ar, this message translates to:
  /// **'محيطي'**
  String get audioModeSurround;

  /// No description provided for @equalizerDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'المعادل الرسومي'**
  String get equalizerDialogTitle;

  /// No description provided for @applyButton.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get applyButton;

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'SR Player'**
  String get appTitle;

  /// No description provided for @libraryTab.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة'**
  String get libraryTab;

  /// No description provided for @myFilesTab.
  ///
  /// In ar, this message translates to:
  /// **'ملفاتي'**
  String get myFilesTab;

  /// No description provided for @recentTab.
  ///
  /// In ar, this message translates to:
  /// **'الأخيرة'**
  String get recentTab;

  /// No description provided for @personalTab.
  ///
  /// In ar, this message translates to:
  /// **'الشخصي'**
  String get personalTab;

  /// No description provided for @collectionsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'المجموعات'**
  String get collectionsTooltip;

  /// No description provided for @viewOptionsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'خيارات العرض والفرز'**
  String get viewOptionsTooltip;

  /// No description provided for @searchTooltip.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get searchTooltip;

  /// No description provided for @favoritesLabel.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesLabel;

  /// No description provided for @playlistLabel.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التشغيل'**
  String get playlistLabel;

  /// No description provided for @queueLabel.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الانتظار'**
  String get queueLabel;

  /// No description provided for @gridView.
  ///
  /// In ar, this message translates to:
  /// **'شبكة'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In ar, this message translates to:
  /// **'قائمة'**
  String get listView;

  /// No description provided for @descending.
  ///
  /// In ar, this message translates to:
  /// **'تنازلي'**
  String get descending;

  /// No description provided for @ascending.
  ///
  /// In ar, this message translates to:
  /// **'تصاعدي'**
  String get ascending;

  /// No description provided for @noPreviousVideo.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد فيديو سابق'**
  String get noPreviousVideo;

  /// No description provided for @selectedCount.
  ///
  /// In ar, this message translates to:
  /// **'{selected} / {total} محدد'**
  String selectedCount(Object selected, Object total);

  /// No description provided for @shareFiles.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة ملفات'**
  String get shareFiles;

  /// No description provided for @hiddenFilesToast.
  ///
  /// In ar, this message translates to:
  /// **'تم إخفاء {count} ملف'**
  String hiddenFilesToast(Object count);

  /// No description provided for @backToFolders.
  ///
  /// In ar, this message translates to:
  /// **'رجوع إلى المجلدات'**
  String get backToFolders;

  /// No description provided for @videosCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فيديو'**
  String videosCount(Object count);

  /// No description provided for @playVideo.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل'**
  String get playVideo;

  /// No description provided for @videoInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الفيديو'**
  String get videoInfo;

  /// No description provided for @addToFavorites.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للمفضلة'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get removeFromFavorites;

  /// No description provided for @addToPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إلى قائمة التشغيل'**
  String get addToPlaylist;

  /// No description provided for @alreadyInPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'موجود في قائمة التشغيل'**
  String get alreadyInPlaylist;

  /// No description provided for @addedToPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'تمت الإضافة إلى قائمة التشغيل'**
  String get addedToPlaylist;

  /// No description provided for @alreadyInPlaylistToast.
  ///
  /// In ar, this message translates to:
  /// **'الملف موجود مسبقاً في القائمة'**
  String get alreadyInPlaylistToast;

  /// No description provided for @renameFile.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الاسم'**
  String get renameFile;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @copyPath.
  ///
  /// In ar, this message translates to:
  /// **'نسخ المسار'**
  String get copyPath;

  /// No description provided for @openInFileManager.
  ///
  /// In ar, this message translates to:
  /// **'فتح في مدير الملفات'**
  String get openInFileManager;

  /// No description provided for @hide.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get hide;

  /// No description provided for @unhide.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الإخفاء'**
  String get unhide;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @playAll.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل الكل'**
  String get playAll;

  /// No description provided for @shufflePlay.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل عشوائي'**
  String get shufflePlay;

  /// No description provided for @hideAll.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء الكل'**
  String get hideAll;

  /// No description provided for @unhideAll.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الكل'**
  String get unhideAll;

  /// No description provided for @deleteFolder.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجلد'**
  String get deleteFolder;

  /// No description provided for @renameDialogTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الاسم'**
  String get renameDialogTitle;

  /// No description provided for @newNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الجديد'**
  String get newNameHint;

  /// No description provided for @okButton.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get okButton;

  /// No description provided for @deleteFileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملف'**
  String get deleteFileTitle;

  /// No description provided for @deleteFileConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف \"{name}\"؟'**
  String deleteFileConfirm(Object name);

  /// No description provided for @deleteFilesTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الملفات'**
  String get deleteFilesTitle;

  /// No description provided for @deleteFilesConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف {count} فيديو؟'**
  String deleteFilesConfirm(Object count);

  /// No description provided for @deleteFolderTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المجلد'**
  String get deleteFolderTitle;

  /// No description provided for @deleteFolderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف {count} فيديو؟'**
  String deleteFolderConfirm(Object count);

  /// No description provided for @fileDeletedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف \"{name}\"'**
  String fileDeletedToast(Object name);

  /// No description provided for @filesDeletedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف {count} فيديو'**
  String filesDeletedToast(Object count);

  /// No description provided for @renameSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير الاسم بنجاح'**
  String get renameSuccess;

  /// No description provided for @renameFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تغيير الاسم: {error}'**
  String renameFailed(Object error);

  /// No description provided for @pathCopiedToast.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ المسار'**
  String get pathCopiedToast;

  /// No description provided for @fileManagerError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر فتح مدير الملفات'**
  String get fileManagerError;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @hideFilesToast.
  ///
  /// In ar, this message translates to:
  /// **'تم إخفاء {count} ملف'**
  String hideFilesToast(Object count);

  /// No description provided for @folderVideosCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فيديو  •  {size}'**
  String folderVideosCount(Object count, Object size);

  /// No description provided for @screenLocked.
  ///
  /// In ar, this message translates to:
  /// **'تم قفل الشاشة'**
  String get screenLocked;

  /// No description provided for @colorAdjustment.
  ///
  /// In ar, this message translates to:
  /// **'تنسيق الألوان'**
  String get colorAdjustment;

  /// No description provided for @playbackSpeed.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل'**
  String get playbackSpeed;

  /// No description provided for @speed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة'**
  String get speed;

  /// No description provided for @custom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get custom;

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @sleepTimer.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت النوم'**
  String get sleepTimer;

  /// No description provided for @selectTimeMinutes.
  ///
  /// In ar, this message translates to:
  /// **'اختر الوقت (دقائق)'**
  String get selectTimeMinutes;

  /// No description provided for @customMinute.
  ///
  /// In ar, this message translates to:
  /// **'مخصص (دقيقة)'**
  String get customMinute;

  /// No description provided for @start.
  ///
  /// In ar, this message translates to:
  /// **'بدء'**
  String get start;

  /// No description provided for @resumeFrom.
  ///
  /// In ar, this message translates to:
  /// **'استئناف {time}'**
  String resumeFrom(Object time);

  /// No description provided for @tapToStartFromBeginning.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للبداية'**
  String get tapToStartFromBeginning;

  /// No description provided for @subtitleSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الترجمة'**
  String get subtitleSettings;

  /// No description provided for @audioSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الصوت'**
  String get audioSettings;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @playlistEditor.
  ///
  /// In ar, this message translates to:
  /// **'قوائم التشغيل'**
  String get playlistEditor;

  /// No description provided for @releaseToOpen.
  ///
  /// In ar, this message translates to:
  /// **'أطلق للفتح'**
  String get releaseToOpen;

  /// No description provided for @slideToUnlock.
  ///
  /// In ar, this message translates to:
  /// **'اسحب لفتح القفل ←'**
  String get slideToUnlock;

  /// No description provided for @subtitleLoaded.
  ///
  /// In ar, this message translates to:
  /// **'✅ تم تحميل الترجمة'**
  String get subtitleLoaded;

  /// No description provided for @subtitleLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الترجمة: {error}'**
  String subtitleLoadFailed(Object error);

  /// No description provided for @externalSubtitleRemoved.
  ///
  /// In ar, this message translates to:
  /// **'تمت إزالة الترجمة الخارجية'**
  String get externalSubtitleRemoved;

  /// No description provided for @playerError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تشغيل الملف: {error}'**
  String playerError(Object error);

  /// No description provided for @statsResolution.
  ///
  /// In ar, this message translates to:
  /// **'الدقة: {width}×{height} ({res})'**
  String statsResolution(Object height, Object res, Object width);

  /// No description provided for @statsCodec.
  ///
  /// In ar, this message translates to:
  /// **'الترميز: {codec}'**
  String statsCodec(Object codec);

  /// No description provided for @statsFps.
  ///
  /// In ar, this message translates to:
  /// **'معدل الإطارات: {fps} fps'**
  String statsFps(Object fps);

  /// No description provided for @statsHdr.
  ///
  /// In ar, this message translates to:
  /// **'HDR: {status}'**
  String statsHdr(Object status);

  /// No description provided for @statsHw.
  ///
  /// In ar, this message translates to:
  /// **'تسريع العتاد (HW): {status}'**
  String statsHw(Object status);

  /// No description provided for @statsPosition.
  ///
  /// In ar, this message translates to:
  /// **'الموضع: {pos} / {dur}'**
  String statsPosition(Object dur, Object pos);

  /// No description provided for @statsSpeed.
  ///
  /// In ar, this message translates to:
  /// **'السرعة: {speed}x'**
  String statsSpeed(Object speed);

  /// No description provided for @statsAudioDelay.
  ///
  /// In ar, this message translates to:
  /// **'تأخير الصوت: {delay}s'**
  String statsAudioDelay(Object delay);

  /// No description provided for @statsSubSync.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الترجمة: {sync}s'**
  String statsSubSync(Object sync);

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @enabled.
  ///
  /// In ar, this message translates to:
  /// **'مفعّل'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get disabled;

  /// No description provided for @nightModeOn.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل الوضع الليلي'**
  String get nightModeOn;

  /// No description provided for @nightModeOff.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف الوضع الليلي'**
  String get nightModeOff;

  /// No description provided for @sleepTimerStopped.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف التشغيل بواسطة المؤقت'**
  String get sleepTimerStopped;

  /// No description provided for @noActiveTrack.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مسار نشط'**
  String get noActiveTrack;

  /// No description provided for @audioLabel.
  ///
  /// In ar, this message translates to:
  /// **'الصوت'**
  String get audioLabel;

  /// No description provided for @audioTracks.
  ///
  /// In ar, this message translates to:
  /// **'المسارات الصوتية'**
  String get audioTracks;

  /// No description provided for @audioTracksCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مسارات'**
  String audioTracksCount(Object count);

  /// No description provided for @volumeLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الصوت'**
  String get volumeLevel;

  /// No description provided for @equalizerLabel.
  ///
  /// In ar, this message translates to:
  /// **'المعادل'**
  String get equalizerLabel;

  /// No description provided for @audioSyncLabel.
  ///
  /// In ar, this message translates to:
  /// **'مزامنة الصوت'**
  String get audioSyncLabel;

  /// No description provided for @audioInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الصوت'**
  String get audioInfo;

  /// No description provided for @audioTrackNumber.
  ///
  /// In ar, this message translates to:
  /// **'مسار صوتي {number}'**
  String audioTrackNumber(Object number);

  /// No description provided for @mute.
  ///
  /// In ar, this message translates to:
  /// **'كتم الصوت'**
  String get mute;

  /// No description provided for @bassBoostLabel.
  ///
  /// In ar, this message translates to:
  /// **'Bass Boost'**
  String get bassBoostLabel;

  /// No description provided for @trebleBoostLabel.
  ///
  /// In ar, this message translates to:
  /// **'Treble Boost'**
  String get trebleBoostLabel;

  /// No description provided for @bassBoostDesc.
  ///
  /// In ar, this message translates to:
  /// **'تضخيم الترددات المنخفضة'**
  String get bassBoostDesc;

  /// No description provided for @trebleBoostDesc.
  ///
  /// In ar, this message translates to:
  /// **'تضخيم الترددات العالية'**
  String get trebleBoostDesc;

  /// No description provided for @openGraphicEqualizer.
  ///
  /// In ar, this message translates to:
  /// **'فتح المعادل الرسومي'**
  String get openGraphicEqualizer;

  /// No description provided for @bands10.
  ///
  /// In ar, this message translates to:
  /// **'10 نطاقات تردد'**
  String get bands10;

  /// No description provided for @audioDelay.
  ///
  /// In ar, this message translates to:
  /// **'تأخير الصوت'**
  String get audioDelay;

  /// No description provided for @audioDelayHelp.
  ///
  /// In ar, this message translates to:
  /// **'القيمة السالبة تُقدم الصوت، والموجبة تؤخره'**
  String get audioDelayHelp;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @titleLabel.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get titleLabel;

  /// No description provided for @codec.
  ///
  /// In ar, this message translates to:
  /// **'الترميز'**
  String get codec;

  /// No description provided for @channel.
  ///
  /// In ar, this message translates to:
  /// **'القناة'**
  String get channel;

  /// No description provided for @bitrate.
  ///
  /// In ar, this message translates to:
  /// **'معدل البت'**
  String get bitrate;

  /// No description provided for @unknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروف'**
  String get unknown;

  /// No description provided for @noAudioInfo.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معلومات صوتية'**
  String get noAudioInfo;

  /// No description provided for @subtitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get subtitleLabel;

  /// No description provided for @embeddedSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'الترجمات المدمجة'**
  String get embeddedSubtitles;

  /// No description provided for @embeddedSubtitlesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مسارات'**
  String embeddedSubtitlesCount(Object count);

  /// No description provided for @externalSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'الترجمات الخارجية'**
  String get externalSubtitles;

  /// No description provided for @externalFile.
  ///
  /// In ar, this message translates to:
  /// **'ملف خارجي'**
  String get externalFile;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد'**
  String get none;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @position.
  ///
  /// In ar, this message translates to:
  /// **'الموضع'**
  String get position;

  /// No description provided for @sync.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة'**
  String get sync;

  /// No description provided for @encoding.
  ///
  /// In ar, this message translates to:
  /// **'الترميز'**
  String get encoding;

  /// No description provided for @advancedOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات متقدمة'**
  String get advancedOptions;

  /// No description provided for @subtitleTrackNumber.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة {number}'**
  String subtitleTrackNumber(Object number);

  /// No description provided for @pickSubtitleFile.
  ///
  /// In ar, this message translates to:
  /// **'اختيار ملف ترجمة'**
  String get pickSubtitleFile;

  /// No description provided for @removeExternalSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الترجمة الخارجية'**
  String get removeExternalSubtitle;

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSize;

  /// No description provided for @systemDefaultFont.
  ///
  /// In ar, this message translates to:
  /// **'System Default'**
  String get systemDefaultFont;

  /// No description provided for @textBackground.
  ///
  /// In ar, this message translates to:
  /// **'خلفية النص'**
  String get textBackground;

  /// No description provided for @backgroundOpacity.
  ///
  /// In ar, this message translates to:
  /// **'شفافية الخلفية'**
  String get backgroundOpacity;

  /// No description provided for @italic.
  ///
  /// In ar, this message translates to:
  /// **'خط مائل'**
  String get italic;

  /// No description provided for @bottomMargin.
  ///
  /// In ar, this message translates to:
  /// **'الارتفاع عن الأسفل'**
  String get bottomMargin;

  /// No description provided for @horizontalMargin.
  ///
  /// In ar, this message translates to:
  /// **'الهامش الأفقي'**
  String get horizontalMargin;

  /// No description provided for @subtitleDelay.
  ///
  /// In ar, this message translates to:
  /// **'تأخير الترجمة'**
  String get subtitleDelay;

  /// No description provided for @subtitleDelayHelp.
  ///
  /// In ar, this message translates to:
  /// **'القيمة السالبة تُقدم الترجمة، والموجبة تؤخرها'**
  String get subtitleDelayHelp;

  /// No description provided for @saveAsDefault.
  ///
  /// In ar, this message translates to:
  /// **'حفظ الإعدادات كافتراضية'**
  String get saveAsDefault;

  /// No description provided for @saveAsDefaultDesc.
  ///
  /// In ar, this message translates to:
  /// **'تنطبق على جميع الفيديوهات'**
  String get saveAsDefaultDesc;

  /// No description provided for @screenshot.
  ///
  /// In ar, this message translates to:
  /// **'لقطة شاشة'**
  String get screenshot;

  /// No description provided for @repeatOff.
  ///
  /// In ar, this message translates to:
  /// **'تكرار: بدون'**
  String get repeatOff;

  /// No description provided for @screenLockDisabled.
  ///
  /// In ar, this message translates to:
  /// **'قفل الشاشة: ممنوع'**
  String get screenLockDisabled;

  /// No description provided for @screenLockEnabled.
  ///
  /// In ar, this message translates to:
  /// **'قفل الشاشة: مسموح'**
  String get screenLockEnabled;

  /// No description provided for @hideVideoInfo.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء معلومات الفيديو'**
  String get hideVideoInfo;

  /// No description provided for @showVideoInfo.
  ///
  /// In ar, this message translates to:
  /// **'إظهار معلومات الفيديو'**
  String get showVideoInfo;

  /// No description provided for @aspectRatio.
  ///
  /// In ar, this message translates to:
  /// **'نسبة العرض'**
  String get aspectRatio;

  /// No description provided for @contain.
  ///
  /// In ar, this message translates to:
  /// **'احتواء'**
  String get contain;

  /// No description provided for @cover.
  ///
  /// In ar, this message translates to:
  /// **'تغطية'**
  String get cover;

  /// No description provided for @fill.
  ///
  /// In ar, this message translates to:
  /// **'ملء'**
  String get fill;

  /// No description provided for @stretch.
  ///
  /// In ar, this message translates to:
  /// **'تمديد'**
  String get stretch;

  /// No description provided for @free.
  ///
  /// In ar, this message translates to:
  /// **'حر (سحب/تكبير بإصبعين)'**
  String get free;

  /// No description provided for @pip.
  ///
  /// In ar, this message translates to:
  /// **'نافذة عائمة (PiP)'**
  String get pip;

  /// No description provided for @repeatAB.
  ///
  /// In ar, this message translates to:
  /// **'تكرار مقطع A-B'**
  String get repeatAB;

  /// No description provided for @repeatABDisabled.
  ///
  /// In ar, this message translates to:
  /// **'غير مفعّل'**
  String get repeatABDisabled;

  /// No description provided for @repeatABSetA.
  ///
  /// In ar, this message translates to:
  /// **'A محددة'**
  String get repeatABSetA;

  /// No description provided for @repeatABActive.
  ///
  /// In ar, this message translates to:
  /// **'A-B مفعّل'**
  String get repeatABActive;

  /// No description provided for @setPointA.
  ///
  /// In ar, this message translates to:
  /// **'تحديد نقطة البداية (A)'**
  String get setPointA;

  /// No description provided for @resetPointA.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تحديد A عند الموضع الحالي'**
  String get resetPointA;

  /// No description provided for @setPointB.
  ///
  /// In ar, this message translates to:
  /// **'تحديد نقطة النهاية (B)'**
  String get setPointB;

  /// No description provided for @cancelRepeat.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء التكرار'**
  String get cancelRepeat;

  /// No description provided for @bookmarks.
  ///
  /// In ar, this message translates to:
  /// **'إشارات مرجعية'**
  String get bookmarks;

  /// No description provided for @addBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إشارة عند الموضع الحالي'**
  String get addBookmark;

  /// No description provided for @noBookmarks.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشارات محفوظة فهاد الفيديو'**
  String get noBookmarks;

  /// No description provided for @playerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المشغل'**
  String get playerSettings;

  /// No description provided for @playbackSpeedWithValue.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل ({speed}x)'**
  String playbackSpeedWithValue(Object speed);

  /// No description provided for @rememberPosition.
  ///
  /// In ar, this message translates to:
  /// **'تذكر موضع التشغيل'**
  String get rememberPosition;

  /// No description provided for @statsForNerds.
  ///
  /// In ar, this message translates to:
  /// **'معلومات تقنية (Stats for Nerds)'**
  String get statsForNerds;

  /// No description provided for @graphicEqualizerTitle.
  ///
  /// In ar, this message translates to:
  /// **'المعادل الرسومي'**
  String get graphicEqualizerTitle;

  /// No description provided for @pickColor.
  ///
  /// In ar, this message translates to:
  /// **'اختر لوناً'**
  String get pickColor;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن فيديو...'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @noVideosFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا فيديوهات'**
  String get noVideosFound;

  /// No description provided for @noRecentVideos.
  ///
  /// In ar, this message translates to:
  /// **'ما شفتي فيديو بعد'**
  String get noRecentVideos;

  /// No description provided for @fileCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} ملف'**
  String fileCount(Object count);

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @noFoldersFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا مجلدات'**
  String get noFoldersFound;

  /// No description provided for @folderVideoCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} فيديو  •  {size}'**
  String folderVideoCount(Object count, Object size);

  /// No description provided for @openFileHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط \"فتح ملف\" لاختيار فيديو'**
  String get openFileHint;

  /// No description provided for @chooseFont.
  ///
  /// In ar, this message translates to:
  /// **'اختر الخط'**
  String get chooseFont;

  /// No description provided for @chooseBoost.
  ///
  /// In ar, this message translates to:
  /// **'تضخيم الصوت الافتراضي (%)'**
  String get chooseBoost;

  /// No description provided for @chooseAudioLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة الصوت المفضلة'**
  String get chooseAudioLanguage;

  /// No description provided for @chooseEncoding.
  ///
  /// In ar, this message translates to:
  /// **'اختر ترميز الأحرف'**
  String get chooseEncoding;

  /// No description provided for @chooseSubtitleLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة الترجمة المفضلة'**
  String get chooseSubtitleLanguage;

  /// No description provided for @syncDefault.
  ///
  /// In ar, this message translates to:
  /// **'المزامنة الافتراضية (ثواني)'**
  String get syncDefault;

  /// No description provided for @exampleSync.
  ///
  /// In ar, this message translates to:
  /// **'مثال: -0.5 أو 1.0'**
  String get exampleSync;

  /// No description provided for @chooseAppearance.
  ///
  /// In ar, this message translates to:
  /// **'اختر المظهر'**
  String get chooseAppearance;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة / Choose language'**
  String get chooseLanguage;

  /// No description provided for @playbackSpeedTitle.
  ///
  /// In ar, this message translates to:
  /// **'سرعة التشغيل'**
  String get playbackSpeedTitle;

  /// No description provided for @sortByTitle.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب حسب'**
  String get sortByTitle;

  /// No description provided for @doubleTapSeekTitle.
  ///
  /// In ar, this message translates to:
  /// **'مدة القفز عند النقر المزدوج'**
  String get doubleTapSeekTitle;

  /// No description provided for @controlsHideDelayTitle.
  ///
  /// In ar, this message translates to:
  /// **'مدة اختفاء أزرار التحكم'**
  String get controlsHideDelayTitle;

  /// No description provided for @longPressSpeedTitle.
  ///
  /// In ar, this message translates to:
  /// **'سرعة الضغط المطول'**
  String get longPressSpeedTitle;

  /// No description provided for @gestureSensitivityTitle.
  ///
  /// In ar, this message translates to:
  /// **'حساسية الإيماءات'**
  String get gestureSensitivityTitle;

  /// No description provided for @seconds5.
  ///
  /// In ar, this message translates to:
  /// **'5 ثوانٍ'**
  String get seconds5;

  /// No description provided for @seconds10.
  ///
  /// In ar, this message translates to:
  /// **'10 ثوانٍ'**
  String get seconds10;

  /// No description provided for @seconds15.
  ///
  /// In ar, this message translates to:
  /// **'15 ثانية'**
  String get seconds15;

  /// No description provided for @seconds30.
  ///
  /// In ar, this message translates to:
  /// **'30 ثانية'**
  String get seconds30;

  /// No description provided for @seconds2.
  ///
  /// In ar, this message translates to:
  /// **'2 ثانية'**
  String get seconds2;

  /// No description provided for @seconds4.
  ///
  /// In ar, this message translates to:
  /// **'4 ثوانٍ'**
  String get seconds4;

  /// No description provided for @seconds6.
  ///
  /// In ar, this message translates to:
  /// **'6 ثوانٍ'**
  String get seconds6;

  /// No description provided for @seconds10b.
  ///
  /// In ar, this message translates to:
  /// **'10 ثوانٍ'**
  String get seconds10b;

  /// No description provided for @hiddenFilesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المخفية'**
  String get hiddenFilesTitle;

  /// No description provided for @showAll.
  ///
  /// In ar, this message translates to:
  /// **'إظهار الكل'**
  String get showAll;

  /// No description provided for @noHiddenFiles.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملفات مخفية'**
  String get noHiddenFiles;

  /// No description provided for @show.
  ///
  /// In ar, this message translates to:
  /// **'إظهار'**
  String get show;

  /// No description provided for @unhideAllConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كل الملفات'**
  String get unhideAllConfirmTitle;

  /// No description provided for @unhideAllConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إظهار جميع الملفات المخفية؟'**
  String get unhideAllConfirmBody;

  /// No description provided for @fileInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الملف'**
  String get fileInfo;

  /// No description provided for @sizeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحجم'**
  String get sizeLabel;

  /// No description provided for @folderLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجلد'**
  String get folderLabel;

  /// No description provided for @dateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get dateLabel;

  /// No description provided for @extensionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الامتداد'**
  String get extensionLabel;

  /// No description provided for @videoInfoLabel.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الفيديو'**
  String get videoInfoLabel;

  /// No description provided for @durationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get durationLabel;

  /// No description provided for @pathLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسار'**
  String get pathLabel;

  /// No description provided for @playlistTitle.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التشغيل'**
  String get playlistTitle;

  /// No description provided for @emptyPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'قائمة التشغيل فارغة'**
  String get emptyPlaylist;

  /// No description provided for @colorAdjustmentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنسيق الألوان'**
  String get colorAdjustmentTitle;

  /// No description provided for @brightness.
  ///
  /// In ar, this message translates to:
  /// **'السطوع'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In ar, this message translates to:
  /// **'التباين'**
  String get contrast;

  /// No description provided for @saturation.
  ///
  /// In ar, this message translates to:
  /// **'التشبع'**
  String get saturation;

  /// No description provided for @hue.
  ///
  /// In ar, this message translates to:
  /// **'درجة اللون'**
  String get hue;

  /// No description provided for @subtitlePreviewText.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في SR Player'**
  String get subtitlePreviewText;

  /// No description provided for @thumbnailError.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الصورة'**
  String get thumbnailError;

  /// No description provided for @sleepTimerStoppedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف التشغيل بواسطة مؤقت النوم'**
  String get sleepTimerStoppedMessage;

  /// No description provided for @smartEnhanceWaitMessage.
  ///
  /// In ar, this message translates to:
  /// **'Smart Enhance: انتظر بدء التشغيل أولاً'**
  String get smartEnhanceWaitMessage;

  /// No description provided for @hwDecodeFallbackMessage.
  ///
  /// In ar, this message translates to:
  /// **'عتاد الهاتف لا يدعم فك تشفير هذا التنسيق تلقائياً، تم التحويل للسوفتوير.'**
  String get hwDecodeFallbackMessage;

  /// No description provided for @snapshotSavedMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ اللقطة في معرض الصور'**
  String get snapshotSavedMessage;

  /// No description provided for @snapshotSaveFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'فشل الحفظ في المعرض'**
  String get snapshotSaveFailedMessage;

  /// No description provided for @addedToFavoritesMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة للمفضلة'**
  String get addedToFavoritesMessage;

  /// No description provided for @removedFromFavoritesMessage.
  ///
  /// In ar, this message translates to:
  /// **'تمت إزالة من المفضلة'**
  String get removedFromFavoritesMessage;

  /// No description provided for @thumbnailExtractFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر استخراج الصورة'**
  String get thumbnailExtractFailed;

  /// No description provided for @fileNotFoundMessage.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير موجود'**
  String get fileNotFoundMessage;

  /// No description provided for @outputFileEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'الملف الناتج فارغ'**
  String get outputFileEmptyMessage;

  /// No description provided for @ffmpegFailedMessage.
  ///
  /// In ar, this message translates to:
  /// **'فشل معالجة الفيديو'**
  String get ffmpegFailedMessage;

  /// No description provided for @timeoutMessage.
  ///
  /// In ar, this message translates to:
  /// **'انتهى الوقت المحدد'**
  String get timeoutMessage;

  /// No description provided for @externalSubtitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'ترجمة خارجية'**
  String get externalSubtitleLabel;

  /// No description provided for @searchOnlineSubtitles.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن ترجمة أونلاين'**
  String get searchOnlineSubtitles;

  /// No description provided for @noSubtitlesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على ترجمة'**
  String get noSubtitlesFound;

  /// No description provided for @downloadFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التنزيل: {error}'**
  String downloadFailed(Object error);

  /// No description provided for @audioBoostLabel.
  ///
  /// In ar, this message translates to:
  /// **'تعزيز الصوت'**
  String get audioBoostLabel;

  /// No description provided for @equalizerPresetLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريست'**
  String get equalizerPresetLabel;

  /// No description provided for @presetOff.
  ///
  /// In ar, this message translates to:
  /// **'بلا'**
  String get presetOff;

  /// No description provided for @presetRock.
  ///
  /// In ar, this message translates to:
  /// **'روك'**
  String get presetRock;

  /// No description provided for @presetPop.
  ///
  /// In ar, this message translates to:
  /// **'بوب'**
  String get presetPop;

  /// No description provided for @presetMovie.
  ///
  /// In ar, this message translates to:
  /// **'أفلام'**
  String get presetMovie;

  /// No description provided for @presetClassical.
  ///
  /// In ar, this message translates to:
  /// **'كلاسيكي'**
  String get presetClassical;

  /// No description provided for @presetJazz.
  ///
  /// In ar, this message translates to:
  /// **'جاز'**
  String get presetJazz;

  /// No description provided for @presetSpeech.
  ///
  /// In ar, this message translates to:
  /// **'كلام'**
  String get presetSpeech;

  /// No description provided for @presetCustom.
  ///
  /// In ar, this message translates to:
  /// **'مخصص'**
  String get presetCustom;

  /// No description provided for @normalizeVolumeLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسوية الصوت'**
  String get normalizeVolumeLabel;

  /// No description provided for @normalizeVolumeDesc.
  ///
  /// In ar, this message translates to:
  /// **'توحيد مستوى الصوت تلقائياً بين المقاطع'**
  String get normalizeVolumeDesc;

  /// No description provided for @skipSilenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'تخطي الصمت'**
  String get skipSilenceLabel;

  /// No description provided for @skipSilenceDesc.
  ///
  /// In ar, this message translates to:
  /// **'تخطي فترات الصمت تلقائياً أثناء التشغيل'**
  String get skipSilenceDesc;

  /// No description provided for @replayGainLabel.
  ///
  /// In ar, this message translates to:
  /// **'ReplayGain'**
  String get replayGainLabel;

  /// No description provided for @replayGainDesc.
  ///
  /// In ar, this message translates to:
  /// **'ضبط مستوى الصوت حسب بيانات الملف الأصلية'**
  String get replayGainDesc;

  /// No description provided for @outputSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'المخرج'**
  String get outputSectionLabel;

  /// No description provided for @outputStereo.
  ///
  /// In ar, this message translates to:
  /// **'ستيريو'**
  String get outputStereo;

  /// No description provided for @outputMono.
  ///
  /// In ar, this message translates to:
  /// **'أحادي'**
  String get outputMono;

  /// No description provided for @outputLeft.
  ///
  /// In ar, this message translates to:
  /// **'القناة اليسرى'**
  String get outputLeft;

  /// No description provided for @outputRight.
  ///
  /// In ar, this message translates to:
  /// **'القناة اليمنى'**
  String get outputRight;

  /// No description provided for @output51Downmix.
  ///
  /// In ar, this message translates to:
  /// **'دمج 5.1'**
  String get output51Downmix;

  /// No description provided for @outputPassthrough.
  ///
  /// In ar, this message translates to:
  /// **'تمرير مباشر'**
  String get outputPassthrough;

  /// No description provided for @preferredAudioSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللغة المفضلة'**
  String get preferredAudioSectionLabel;

  /// No description provided for @autoOption.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get autoOption;

  /// No description provided for @playbackSectionLabel.
  ///
  /// In ar, this message translates to:
  /// **'التشغيل'**
  String get playbackSectionLabel;

  /// No description provided for @sampleRate.
  ///
  /// In ar, this message translates to:
  /// **'معدل العينة'**
  String get sampleRate;

  /// No description provided for @bitDepth.
  ///
  /// In ar, this message translates to:
  /// **'عمق البت'**
  String get bitDepth;

  /// No description provided for @restorePreviousVolume.
  ///
  /// In ar, this message translates to:
  /// **'استعادة مستوى الصوت السابق'**
  String get restorePreviousVolume;

  /// No description provided for @graphicEqualizerPanelTitle.
  ///
  /// In ar, this message translates to:
  /// **'المعادل الرسومي (10 نطاقات)'**
  String get graphicEqualizerPanelTitle;

  /// No description provided for @channelsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} قنوات'**
  String channelsCount(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
