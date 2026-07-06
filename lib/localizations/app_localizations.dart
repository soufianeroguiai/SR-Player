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
/// import 'localizations/app_localizations.dart';
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
  /// **'تكرار الفيديو'**
  String get repeatVideo;

  /// No description provided for @repeatPlaylist.
  ///
  /// In ar, this message translates to:
  /// **'تكرار القائمة'**
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
