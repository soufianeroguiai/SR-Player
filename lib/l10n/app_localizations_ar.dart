// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String mediaKitInitError(String error) {
    return 'فشل تهيئة MediaKit:\n$error';
  }

  @override
  String ffmpegInitError(Object error) {
    return 'فشل تهيئة FFmpeg:\n$error';
  }

  @override
  String settingsLoadError(Object error) {
    return 'فشل تحميل الإعدادات:\n$error';
  }

  @override
  String get errorOccurredTitle => 'عذراً، حدث خطأ';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get requestingPermissions => 'جاري طلب الصلاحيات...';

  @override
  String get permissionsRequiredTitle => 'الصلاحيات مطلوبة';

  @override
  String get permissionsRequiredBody =>
      'يحتاج التطبيق إلى إذن الوصول إلى الوسائط لعرض الفيديوهات.';

  @override
  String get grantPermissionsButton => 'منح الصلاحيات';

  @override
  String get skipButton => 'تخطي';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get noFavoriteVideos => 'لا توجد فيديوهات مفضلة';

  @override
  String get languageSettingLabel => 'اللغة';

  @override
  String get systemLanguageOption => 'لغة النظام';

  @override
  String get arabicLanguageOption => 'العربية';

  @override
  String get englishLanguageOption => 'الإنجليزية';

  @override
  String get frenchLanguageOption => 'الفرنسية';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get generalSection => 'عام';

  @override
  String get appearanceOption => 'المظهر';

  @override
  String get languageOption => 'اللغة';

  @override
  String get themeColorOption => 'لون التطبيق';

  @override
  String get themeColorSubtitle => 'لون الواجهة الأساسي (Material You)';

  @override
  String get playerSection => 'المشغل';

  @override
  String get playbackSection => 'التشغيل';

  @override
  String get autoPlayOption => 'التشغيل التلقائي';

  @override
  String get resumePositionOption => 'استئناف آخر موضع';

  @override
  String get rememberSpeedOption => 'تذكر سرعة التشغيل';

  @override
  String get repeatModeOption => 'التشغيل المتكرر';

  @override
  String get repeatNone => 'بدون';

  @override
  String get repeatVideo => 'تكرار: الفيديو';

  @override
  String get repeatPlaylist => 'تكرار: القائمة';

  @override
  String get autoNextOption => 'الانتقال للفيديو التالي تلقائياً';

  @override
  String get autoPipOption => 'الانتقال للوضع المصغر عند الخروج';

  @override
  String get speedSection => 'سرعة التشغيل';

  @override
  String get defaultSpeedOption => 'سرعة التشغيل الافتراضية';

  @override
  String get rememberLastSpeedOption => 'تذكر آخر سرعة';

  @override
  String get allow4xOption => 'السماح بسرعة حتى 4×';

  @override
  String get pitchCorrectionOption => 'تصحيح طبقة الصوت (Pitch Correction)';

  @override
  String get videoDisplaySection => 'عرض الفيديو';

  @override
  String get defaultVideoModeOption => 'الوضع الافتراضي';

  @override
  String get rememberVideoModeOption => 'تذكر آخر وضع';

  @override
  String get autoRotateOption => 'تدوير تلقائي';

  @override
  String get autoFullscreenOption => 'ملء الشاشة تلقائياً';

  @override
  String get keepScreenOnOption => 'إبقاء الشاشة مضاءة';

  @override
  String get gesturesSection => 'التحكم بالإيماءات';

  @override
  String get gestureVolumeOption => 'السحب للصوت';

  @override
  String get gestureBrightnessOption => 'السحب للسطوع';

  @override
  String get gestureSeekOption => 'السحب للتقديم والترجيع';

  @override
  String get tapToPauseOption => 'النقر للإيقاف';

  @override
  String get doubleTapOption => 'النقر المزدوج';

  @override
  String get longPressSpeedOption => 'الضغط المطول = سرعة مؤقتة ×2';

  @override
  String get vibrateOnEndOption => 'اهتزاز عند الوصول للنهاية';

  @override
  String get seekSection => 'التقديم والترجيع';

  @override
  String get seekDurationOption => 'مدة التخطي';

  @override
  String get seekPreviewOption => 'إظهار معاينة أثناء السحب';

  @override
  String get seekTimeOption => 'إظهار الوقت أثناء السحب';

  @override
  String get uiSection => 'واجهة المشغل';

  @override
  String get autoHideControlsOption => 'إخفاء الأزرار تلقائياً';

  @override
  String get hideDelayOption => 'مدة الإخفاء';

  @override
  String get showRemainingTimeOption => 'إظهار الوقت المتبقي';

  @override
  String get showElapsedTimeOption => 'إظهار الوقت المنقضي';

  @override
  String get showVideoTitleOption => 'إظهار اسم الفيديو';

  @override
  String get showBatteryOption => 'إظهار البطارية';

  @override
  String get showClockOption => 'إظهار الساعة';

  @override
  String get playlistSection => 'القوائم';

  @override
  String get continuousPlaybackOption => 'التشغيل المتواصل';

  @override
  String get removeAfterPlaybackOption => 'إزالة الفيديو بعد التشغيل';

  @override
  String get rememberPlaylistOption => 'تذكر القائمة الأخيرة';

  @override
  String get savePlaylistOrderOption => 'حفظ ترتيب التشغيل';

  @override
  String get shufflePlaylistOption => 'تشغيل عشوائي';

  @override
  String get energySection => 'الطاقة';

  @override
  String get preventLockOption => 'منع قفل الشاشة';

  @override
  String get reduceBrightnessOption => 'خفض السطوع عند التوقف';

  @override
  String get stopAfterVideoOption => 'إيقاف التشغيل بعد انتهاء الفيديو';

  @override
  String get sleepTimerOption => 'مؤقت النوم (Sleep Timer)';

  @override
  String get sleepTimerDisabled => 'معطل';

  @override
  String sleepTimerMinutes(Object minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get controlSection => 'التحكم';

  @override
  String get volumeKeysSeekOption => 'أزرار الصوت للتقديم';

  @override
  String get keyboardSupportOption => 'دعم لوحة المفاتيح';

  @override
  String get gamepadSupportOption => 'دعم يد التحكم';

  @override
  String get advancedSection => 'خيارات متقدمة';

  @override
  String get decoderModeOption => 'وضع فك التشفير';

  @override
  String get fallbackSoftwareOption => 'الرجوع إلى Software عند الفشل';

  @override
  String get lowLatencyOption => 'تشغيل منخفض التأخير';

  @override
  String get frameDroppingOption => 'Frame Dropping';

  @override
  String get vsyncOption => 'VSync';

  @override
  String get loggingOption => 'Logging';

  @override
  String get showVideoInfoOption => 'إظهار معلومات الفيديو';

  @override
  String get audioSection => 'الصوت';

  @override
  String get audioGeneralSection => 'الصوت العام';

  @override
  String get audioBoostOption => 'تضخيم الصوت الافتراضي';

  @override
  String get audioBalanceOption => 'موازنة الصوت (Balance)';

  @override
  String get rememberVolumeOption => 'تذكر مستوى الصوت لكل فيديو';

  @override
  String get resetVolumeOption => 'إعادة ضبط مستوى الصوت لكل فيديو';

  @override
  String get audioOutputSection => 'إخراج الصوت';

  @override
  String get audioOutputModeOption => 'وضع إخراج الصوت';

  @override
  String get autoBluetoothOption => 'التحويل التلقائي عند توصيل سماعة';

  @override
  String get audioTracksSection => 'المسارات الصوتية';

  @override
  String get preferredAudioLanguageOption => 'لغة الصوت المفضلة';

  @override
  String get equalizerSection => 'معادل الصوت';

  @override
  String get equalizerEnabledOption => 'تشغيل المعادل';

  @override
  String get openEqualizerOption => 'فتح المعادل الرسومي';

  @override
  String get equalizerBandsSubtitle => '10 نطاقات';

  @override
  String get audioSyncSection => 'مزامنة الصوت';

  @override
  String get audioDelayOption => 'تأخير الصوت (ms)';

  @override
  String get resetButton => 'إعادة ضبط';

  @override
  String get audioProcessingSection => 'معالجة الصوت';

  @override
  String get surroundSoundOption => 'صوت محيطي (Surround)';

  @override
  String get surroundSoundSubtitle => 'محاكاة صوت محيطي';

  @override
  String get bassBoostOption => 'Bass Boost';

  @override
  String get bassBoostSubtitle => 'تضخيم الترددات المنخفضة';

  @override
  String get subtitlesSection => 'الترجمة';

  @override
  String get subAppearanceSection => 'المظهر';

  @override
  String get subPositionSection => 'الموضع';

  @override
  String get subBehaviorSection => 'السلوك';

  @override
  String get subCompatibilitySection => 'التوافق';

  @override
  String get fontSizeOption => 'حجم الخط';

  @override
  String get fontFamilyOption => 'نوع الخط';

  @override
  String get subScaleOption => 'مقياس الترجمة';

  @override
  String get lineSpacingOption => 'تباعد الأسطر';

  @override
  String get maxLinesOption => 'أقصى عدد للأسطر';

  @override
  String get wrapTextOption => 'لف النص';

  @override
  String get wrapTextSubtitle => 'لف النص التلقائي للترجمة';

  @override
  String get letterSpacingOption => 'تباعد الحروف';

  @override
  String get wordSpacingOption => 'تباعد الكلمات';

  @override
  String get fontWeightOption => 'سمك الخط';

  @override
  String get fontWeightLight => 'خفيف';

  @override
  String get fontWeightNormal => 'عادي';

  @override
  String get fontWeightSemiBold => 'شبه عريض';

  @override
  String get fontWeightBold => 'عريض جداً';

  @override
  String get textOpacityOption => 'شفافية النص';

  @override
  String get textColorOption => 'لون النص';

  @override
  String get backgroundSwitch => 'خلفية النص';

  @override
  String get backgroundColorOption => 'لون الخلفية';

  @override
  String get backgroundOpacityOption => 'شفافية الخلفية';

  @override
  String get backgroundRadiusOption => 'زوايا الخلفية';

  @override
  String get outlineSwitch => 'حدّ خارجي للنص';

  @override
  String get outlineSubtitle => 'إطار حول كل حرف';

  @override
  String get outlineColorOption => 'لون الحدّ';

  @override
  String get outlineWidthOption => 'سماكة الحدّ';

  @override
  String get outlineScaleOption => 'مقياس مستقل للحدود';

  @override
  String get shadowSwitch => 'ظل النص';

  @override
  String get shadowSubtitle => 'ظل خلف نص الترجمة';

  @override
  String get shadowColorOption => 'لون الظل';

  @override
  String get shadowOpacityOption => 'شفافية الظل';

  @override
  String get shadowOffsetXOption => 'إزاحة أفقية';

  @override
  String get shadowOffsetYOption => 'إزاحة رأسية';

  @override
  String get shadowBlurOption => 'تمويه الظل';

  @override
  String get backgroundSection => 'الخلفية';

  @override
  String get backgroundShapeOption => 'شكل الخلفية';

  @override
  String get backgroundShapeRectangle => 'مستطيل';

  @override
  String get backgroundShapeRounded => 'مدور';

  @override
  String get backgroundShapeCapsule => 'كبسولة';

  @override
  String get backgroundBorderSwitch => 'حدود الخلفية';

  @override
  String get backgroundBorderColorOption => 'لون الحدود';

  @override
  String get backgroundBorderWidthOption => 'سماكة الحدود';

  @override
  String get backgroundPaddingOption => 'Padding الخلفية';

  @override
  String get italicOption => 'تأثير مائل';

  @override
  String get italicSubtitle => 'تفعيل الخط المائل للترجمة';

  @override
  String get resetAppearanceButton => 'إعادة ضبط المظهر';

  @override
  String get positionOption => 'موضع الترجمة';

  @override
  String get positionTop => 'أعلى';

  @override
  String get positionCenter => 'وسط';

  @override
  String get positionBottom => 'أسفل';

  @override
  String get bottomMarginOption => 'الارتفاع عن الأسفل';

  @override
  String get horizontalMarginOption => 'الهامش الأفقي';

  @override
  String get verticalMarginOption => 'الهامش العمودي';

  @override
  String get safeAreaPaddingOption => 'هامش الأمان';

  @override
  String get keepInsideVideoOption => 'البقاء داخل الفيديو';

  @override
  String get keepInsideVideoSubtitle => 'عدم خروج الترجمة خارج حدود الفيديو';

  @override
  String get respectNotchOption => 'احترام النوتش';

  @override
  String get respectNotchSubtitle => 'تجنب منطقة الثقب أو النوتش';

  @override
  String get textDirectionOption => 'اتجاه النص';

  @override
  String get textDirectionRTL => 'من اليمين إلى اليسار';

  @override
  String get textDirectionLTR => 'من اليسار إلى اليمين';

  @override
  String get resetPositionButton => 'إعادة ضبط الموضع';

  @override
  String get autoShowSubtitlesOption => 'إظهار الترجمة تلقائياً';

  @override
  String get autoShowSubtitlesSubtitle => 'تفعيل عند بدء التشغيل';

  @override
  String get subtitleFolderOption => 'مجلد الترجمة';

  @override
  String get subtitleEncodingOption => 'ترميز الأحرف';

  @override
  String get preferredSubtitleLanguageOption => 'لغة الترجمة المفضلة';

  @override
  String get defaultSyncOption => 'مزامنة افتراضية';

  @override
  String get scaleModeOption => 'طريقة قياس الترجمة';

  @override
  String get scaleModeFixed => 'حجم ثابت';

  @override
  String get scaleModeResolution => 'حسب دقة الفيديو';

  @override
  String get scaleModeWindow => 'حسب حجم النافذة';

  @override
  String get scaleModeSmart => 'ذكي (موصى به)';

  @override
  String get loadLastUsedOption => 'تحميل آخر ترجمة مستخدمة';

  @override
  String get hideWhenNoDialogOption => 'إخفاء الترجمة عند عدم وجود حوار';

  @override
  String get resetBehaviorButton => 'إعادة ضبط السلوك';

  @override
  String get improveAnimationOption => 'تحسين حركة الخط';

  @override
  String get complexTextOption => 'تحسين معالجة النصوص المعقدة';

  @override
  String get improveSsaAssOption => 'تحسين عرض SSA/ASS';

  @override
  String get ignoreAssFontsOption => 'تجاهل الخط المحدد داخل ASS';

  @override
  String get ignoreAssEffectsOption => 'تجاهل بعض تأثيرات ASS';

  @override
  String get unicodeSupportOption => 'دعم Unicode الكامل';

  @override
  String get antiAliasingOption => 'تحسين Anti-Aliasing';

  @override
  String get hdrSupportOption => 'دعم HDR';

  @override
  String get resetCompatibilityButton => 'إعادة ضبط التوافق';

  @override
  String get librarySection => 'المكتبة';

  @override
  String get sortByOption => 'الترتيب الافتراضي';

  @override
  String get sortDescOption => 'ترتيب تنازلي';

  @override
  String get libraryGridViewOption => 'عرض شبكي للمكتبة';

  @override
  String get foldersGridViewOption => 'عرض شبكي للمجلدات';

  @override
  String get recentGridViewOption => 'عرض شبكي للأخيرة';

  @override
  String get hiddenFilesOption => 'الملفات المخفية';

  @override
  String get storageSection => 'التخزين';

  @override
  String get thumbnailCacheOption => 'ذاكرة الصور المصغرة';

  @override
  String get calculatingSize => 'جارٍ الحساب...';

  @override
  String get clearCacheButton => 'مسح';

  @override
  String get backupSection => 'النسخ الاحتياطي';

  @override
  String get exportSettingsOption => 'تصدير الإعدادات';

  @override
  String get importSettingsOption => 'استيراد الإعدادات';

  @override
  String get resetAllButton => 'استعادة الإعدادات الافتراضية';

  @override
  String get resetAllDialogTitle => 'استعادة الإعدادات';

  @override
  String get resetAllDialogBody =>
      'هل تريد إعادة جميع الإعدادات إلى الوضع الافتراضي؟';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get confirmResetButton => 'استعادة';

  @override
  String get settingsSavedMessage => 'تم استعادة الإعدادات';

  @override
  String get clearCacheDialogTitle => 'مسح ذاكرة الصور المصغرة';

  @override
  String get clearCacheDialogBody =>
      'سيتم حذف كل الصور المصغرة المخزَّنة، وستُعاد توليدها تلقائياً عند فتح المكتبة من جديد.';

  @override
  String get cacheClearedMessage => 'تم مسح ذاكرة الصور المصغرة';

  @override
  String exportSuccessMessage(Object path) {
    return 'تم حفظ الإعدادات في: $path';
  }

  @override
  String exportFailMessage(Object error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get importSuccessMessage => 'تم استيراد الإعدادات بنجاح';

  @override
  String importFailMessage(Object error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get decoderAuto => 'تلقائي (موصى)';

  @override
  String get decoderHW => 'HW+ (عتاد)';

  @override
  String get decoderSW => 'SW (برمجي)';

  @override
  String get colorFormatYCbCr => 'YCbCr (افتراضي)';

  @override
  String get colorFormatRGBFull => 'RGB Full (ألوان حيوية)';

  @override
  String get colorFormatRGBLimited => 'RGB Limited';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeSystem => 'تلقائي';

  @override
  String get sortByName => 'الاسم';

  @override
  String get sortBySize => 'الحجم';

  @override
  String get sortByDuration => 'المدة';

  @override
  String get sortByDate => 'التاريخ';

  @override
  String get videoModeContain => 'Contain';

  @override
  String get videoModeCover => 'Cover';

  @override
  String get videoModeFill => 'Fill';

  @override
  String get videoModeStretch => 'Stretch';

  @override
  String get audioModeStereo => 'ستيريو';

  @override
  String get audioModeMono => 'أحادي';

  @override
  String get audioModeSurround => 'محيطي';

  @override
  String get equalizerDialogTitle => 'المعادل الرسومي';

  @override
  String get applyButton => 'تطبيق';

  @override
  String get appTitle => 'SR Player';

  @override
  String get libraryTab => 'مكتبة';

  @override
  String get myFilesTab => 'ملفاتي';

  @override
  String get recentTab => 'الأخيرة';

  @override
  String get personalTab => 'الشخصي';

  @override
  String get collectionsTooltip => 'المجموعات';

  @override
  String get viewOptionsTooltip => 'خيارات العرض والفرز';

  @override
  String get searchTooltip => 'بحث';

  @override
  String get favoritesLabel => 'المفضلة';

  @override
  String get playlistLabel => 'قائمة التشغيل';

  @override
  String get queueLabel => 'قائمة الانتظار';

  @override
  String get gridView => 'شبكة';

  @override
  String get listView => 'قائمة';

  @override
  String get descending => 'تنازلي';

  @override
  String get ascending => 'تصاعدي';

  @override
  String get noPreviousVideo => 'لا يوجد فيديو سابق';

  @override
  String selectedCount(Object selected, Object total) {
    return '$selected / $total محدد';
  }

  @override
  String get shareFiles => 'مشاركة ملفات';

  @override
  String hiddenFilesToast(Object count) {
    return 'تم إخفاء $count ملف';
  }

  @override
  String get backToFolders => 'رجوع إلى المجلدات';

  @override
  String videosCount(Object count) {
    return '$count فيديو';
  }

  @override
  String get playVideo => 'تشغيل';

  @override
  String get videoInfo => 'معلومات الفيديو';

  @override
  String get addToFavorites => 'إضافة للمفضلة';

  @override
  String get removeFromFavorites => 'إزالة من المفضلة';

  @override
  String get addToPlaylist => 'إضافة إلى قائمة التشغيل';

  @override
  String get alreadyInPlaylist => 'موجود في قائمة التشغيل';

  @override
  String get addedToPlaylist => 'تمت الإضافة إلى قائمة التشغيل';

  @override
  String get alreadyInPlaylistToast => 'الملف موجود مسبقاً في القائمة';

  @override
  String get renameFile => 'تغيير الاسم';

  @override
  String get share => 'مشاركة';

  @override
  String get copyPath => 'نسخ المسار';

  @override
  String get openInFileManager => 'فتح في مدير الملفات';

  @override
  String get hide => 'إخفاء';

  @override
  String get unhide => 'إلغاء الإخفاء';

  @override
  String get delete => 'حذف';

  @override
  String get playAll => 'تشغيل الكل';

  @override
  String get shufflePlay => 'تشغيل عشوائي';

  @override
  String get hideAll => 'إخفاء الكل';

  @override
  String get unhideAll => 'إظهار الكل';

  @override
  String get deleteFolder => 'حذف المجلد';

  @override
  String get renameDialogTitle => 'تغيير الاسم';

  @override
  String get newNameHint => 'الاسم الجديد';

  @override
  String get okButton => 'موافق';

  @override
  String get deleteFileTitle => 'حذف الملف';

  @override
  String deleteFileConfirm(Object name) {
    return 'هل أنت متأكد من حذف \"$name\"؟';
  }

  @override
  String get deleteFilesTitle => 'حذف الملفات';

  @override
  String deleteFilesConfirm(Object count) {
    return 'هل أنت متأكد من حذف $count فيديو؟';
  }

  @override
  String get deleteFolderTitle => 'حذف المجلد';

  @override
  String deleteFolderConfirm(Object count) {
    return 'هل أنت متأكد من حذف $count فيديو؟';
  }

  @override
  String fileDeletedToast(Object name) {
    return 'تم حذف \"$name\"';
  }

  @override
  String filesDeletedToast(Object count) {
    return 'تم حذف $count فيديو';
  }

  @override
  String get renameSuccess => 'تم تغيير الاسم بنجاح';

  @override
  String renameFailed(Object error) {
    return 'فشل تغيير الاسم: $error';
  }

  @override
  String get pathCopiedToast => 'تم نسخ المسار';

  @override
  String get fileManagerError => 'تعذر فتح مدير الملفات';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get cancel => 'إلغاء';

  @override
  String hideFilesToast(Object count) {
    return 'تم إخفاء $count ملف';
  }

  @override
  String folderVideosCount(Object count, Object size) {
    return '$count فيديو  •  $size';
  }

  @override
  String get screenLocked => 'تم قفل الشاشة';

  @override
  String get colorAdjustment => 'تنسيق الألوان';

  @override
  String get playbackSpeed => 'سرعة التشغيل';

  @override
  String get speed => 'السرعة';

  @override
  String get custom => 'مخصص';

  @override
  String get apply => 'تطبيق';

  @override
  String get sleepTimer => 'مؤقت النوم';

  @override
  String get selectTimeMinutes => 'اختر الوقت (دقائق)';

  @override
  String get customMinute => 'مخصص (دقيقة)';

  @override
  String get start => 'بدء';

  @override
  String resumeFrom(Object time) {
    return 'استئناف $time';
  }

  @override
  String get tapToStartFromBeginning => 'اضغط للبداية';

  @override
  String get subtitleSettings => 'إعدادات الترجمة';

  @override
  String get audioSettings => 'إعدادات الصوت';

  @override
  String get more => 'المزيد';

  @override
  String get playlistEditor => 'قوائم التشغيل';

  @override
  String get releaseToOpen => 'أطلق للفتح';

  @override
  String get slideToUnlock => 'اسحب لفتح القفل ←';

  @override
  String get subtitleLoaded => '✅ تم تحميل الترجمة';

  @override
  String subtitleLoadFailed(Object error) {
    return 'فشل تحميل الترجمة: $error';
  }

  @override
  String get externalSubtitleRemoved => 'تمت إزالة الترجمة الخارجية';

  @override
  String playerError(Object error) {
    return 'تعذر تشغيل الملف: $error';
  }

  @override
  String statsResolution(Object height, Object res, Object width) {
    return 'الدقة: $width×$height ($res)';
  }

  @override
  String statsCodec(Object codec) {
    return 'الترميز: $codec';
  }

  @override
  String statsFps(Object fps) {
    return 'معدل الإطارات: $fps fps';
  }

  @override
  String statsHdr(Object status) {
    return 'HDR: $status';
  }

  @override
  String statsHw(Object status) {
    return 'تسريع العتاد (HW): $status';
  }

  @override
  String statsPosition(Object dur, Object pos) {
    return 'الموضع: $pos / $dur';
  }

  @override
  String statsSpeed(Object speed) {
    return 'السرعة: ${speed}x';
  }

  @override
  String statsAudioDelay(Object delay) {
    return 'تأخير الصوت: ${delay}s';
  }

  @override
  String statsSubSync(Object sync) {
    return 'مزامنة الترجمة: ${sync}s';
  }

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get enabled => 'مفعّل';

  @override
  String get disabled => 'معطّل';

  @override
  String get nightModeOn => 'تم تفعيل الوضع الليلي';

  @override
  String get nightModeOff => 'تم إيقاف الوضع الليلي';

  @override
  String get sleepTimerStopped => 'تم إيقاف التشغيل بواسطة المؤقت';

  @override
  String get noActiveTrack => 'لا يوجد مسار نشط';

  @override
  String get audioLabel => 'الصوت';

  @override
  String get audioTracks => 'المسارات الصوتية';

  @override
  String audioTracksCount(Object count) {
    return '$count مسارات';
  }

  @override
  String get volumeLevel => 'مستوى الصوت';

  @override
  String get equalizerLabel => 'المعادل';

  @override
  String get audioSyncLabel => 'مزامنة الصوت';

  @override
  String get audioInfo => 'معلومات الصوت';

  @override
  String audioTrackNumber(Object number) {
    return 'مسار صوتي $number';
  }

  @override
  String get mute => 'كتم الصوت';

  @override
  String get bassBoostLabel => 'Bass Boost';

  @override
  String get trebleBoostLabel => 'Treble Boost';

  @override
  String get bassBoostDesc => 'تضخيم الترددات المنخفضة';

  @override
  String get trebleBoostDesc => 'تضخيم الترددات العالية';

  @override
  String get openGraphicEqualizer => 'فتح المعادل الرسومي';

  @override
  String get bands10 => '10 نطاقات تردد';

  @override
  String get audioDelay => 'تأخير الصوت';

  @override
  String get audioDelayHelp => 'القيمة السالبة تُقدم الصوت، والموجبة تؤخره';

  @override
  String get language => 'اللغة';

  @override
  String get titleLabel => 'العنوان';

  @override
  String get codec => 'الترميز';

  @override
  String get channel => 'القناة';

  @override
  String get bitrate => 'معدل البت';

  @override
  String get unknown => 'غير معروف';

  @override
  String get noAudioInfo => 'لا توجد معلومات صوتية';

  @override
  String get subtitleLabel => 'الترجمة';

  @override
  String get embeddedSubtitles => 'الترجمات المدمجة';

  @override
  String embeddedSubtitlesCount(Object count) {
    return '$count مسارات';
  }

  @override
  String get externalSubtitles => 'الترجمات الخارجية';

  @override
  String get externalFile => 'ملف خارجي';

  @override
  String get none => 'لا يوجد';

  @override
  String get appearance => 'المظهر';

  @override
  String get position => 'الموضع';

  @override
  String get sync => 'المزامنة';

  @override
  String get encoding => 'الترميز';

  @override
  String get advancedOptions => 'خيارات متقدمة';

  @override
  String subtitleTrackNumber(Object number) {
    return 'ترجمة $number';
  }

  @override
  String get pickSubtitleFile => 'اختيار ملف ترجمة';

  @override
  String get removeExternalSubtitle => 'إزالة الترجمة الخارجية';

  @override
  String get fontSize => 'حجم الخط';

  @override
  String get systemDefaultFont => 'System Default';

  @override
  String get textBackground => 'خلفية النص';

  @override
  String get backgroundOpacity => 'شفافية الخلفية';

  @override
  String get italic => 'خط مائل';

  @override
  String get bottomMargin => 'الارتفاع عن الأسفل';

  @override
  String get horizontalMargin => 'الهامش الأفقي';

  @override
  String get subtitleDelay => 'تأخير الترجمة';

  @override
  String get subtitleDelayHelp =>
      'القيمة السالبة تُقدم الترجمة، والموجبة تؤخرها';

  @override
  String get saveAsDefault => 'حفظ الإعدادات كافتراضية';

  @override
  String get saveAsDefaultDesc => 'تنطبق على جميع الفيديوهات';

  @override
  String get screenshot => 'لقطة شاشة';

  @override
  String get repeatOff => 'تكرار: بدون';

  @override
  String get screenLockDisabled => 'قفل الشاشة: ممنوع';

  @override
  String get screenLockEnabled => 'قفل الشاشة: مسموح';

  @override
  String get hideVideoInfo => 'إخفاء معلومات الفيديو';

  @override
  String get showVideoInfo => 'إظهار معلومات الفيديو';

  @override
  String get aspectRatio => 'نسبة العرض';

  @override
  String get contain => 'احتواء';

  @override
  String get cover => 'تغطية';

  @override
  String get fill => 'ملء';

  @override
  String get stretch => 'تمديد';

  @override
  String get free => 'حر (سحب/تكبير بإصبعين)';

  @override
  String get pip => 'نافذة عائمة (PiP)';

  @override
  String get repeatAB => 'تكرار مقطع A-B';

  @override
  String get repeatABDisabled => 'غير مفعّل';

  @override
  String get repeatABSetA => 'A محددة';

  @override
  String get repeatABActive => 'A-B مفعّل';

  @override
  String get setPointA => 'تحديد نقطة البداية (A)';

  @override
  String get resetPointA => 'إعادة تحديد A عند الموضع الحالي';

  @override
  String get setPointB => 'تحديد نقطة النهاية (B)';

  @override
  String get cancelRepeat => 'إلغاء التكرار';

  @override
  String get bookmarks => 'إشارات مرجعية';

  @override
  String get addBookmark => 'إضافة إشارة عند الموضع الحالي';

  @override
  String get noBookmarks => 'لا توجد إشارات محفوظة فهاد الفيديو';

  @override
  String get playerSettings => 'إعدادات المشغل';

  @override
  String playbackSpeedWithValue(Object speed) {
    return 'سرعة التشغيل (${speed}x)';
  }

  @override
  String get rememberPosition => 'تذكر موضع التشغيل';

  @override
  String get statsForNerds => 'معلومات تقنية (Stats for Nerds)';

  @override
  String get graphicEqualizerTitle => 'المعادل الرسومي';

  @override
  String get pickColor => 'اختر لوناً';

  @override
  String get searchHint => 'ابحث عن فيديو...';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get noVideosFound => 'ما لقينا فيديوهات';

  @override
  String get noRecentVideos => 'ما شفتي فيديو بعد';

  @override
  String fileCount(Object count) {
    return '$count ملف';
  }

  @override
  String get clear => 'مسح';

  @override
  String get noFoldersFound => 'ما لقينا مجلدات';

  @override
  String folderVideoCount(Object count, Object size) {
    return '$count فيديو  •  $size';
  }

  @override
  String get openFileHint => 'اضغط \"فتح ملف\" لاختيار فيديو';

  @override
  String get chooseFont => 'اختر الخط';

  @override
  String get chooseBoost => 'تضخيم الصوت الافتراضي (%)';

  @override
  String get chooseAudioLanguage => 'اختر لغة الصوت المفضلة';

  @override
  String get chooseEncoding => 'اختر ترميز الأحرف';

  @override
  String get chooseSubtitleLanguage => 'اختر لغة الترجمة المفضلة';

  @override
  String get syncDefault => 'المزامنة الافتراضية (ثواني)';

  @override
  String get exampleSync => 'مثال: -0.5 أو 1.0';

  @override
  String get chooseAppearance => 'اختر المظهر';

  @override
  String get chooseLanguage => 'اختر اللغة / Choose language';

  @override
  String get playbackSpeedTitle => 'سرعة التشغيل';

  @override
  String get sortByTitle => 'ترتيب حسب';

  @override
  String get doubleTapSeekTitle => 'مدة القفز عند النقر المزدوج';

  @override
  String get controlsHideDelayTitle => 'مدة اختفاء أزرار التحكم';

  @override
  String get longPressSpeedTitle => 'سرعة الضغط المطول';

  @override
  String get gestureSensitivityTitle => 'حساسية الإيماءات';

  @override
  String get seconds5 => '5 ثوانٍ';

  @override
  String get seconds10 => '10 ثوانٍ';

  @override
  String get seconds15 => '15 ثانية';

  @override
  String get seconds30 => '30 ثانية';

  @override
  String get seconds2 => '2 ثانية';

  @override
  String get seconds4 => '4 ثوانٍ';

  @override
  String get seconds6 => '6 ثوانٍ';

  @override
  String get seconds10b => '10 ثوانٍ';

  @override
  String get hiddenFilesTitle => 'الملفات المخفية';

  @override
  String get showAll => 'إظهار الكل';

  @override
  String get noHiddenFiles => 'لا توجد ملفات مخفية';

  @override
  String get show => 'إظهار';

  @override
  String get unhideAllConfirmTitle => 'إظهار كل الملفات';

  @override
  String get unhideAllConfirmBody => 'هل تريد إظهار جميع الملفات المخفية؟';

  @override
  String get fileInfo => 'معلومات الملف';

  @override
  String get sizeLabel => 'الحجم';

  @override
  String get folderLabel => 'المجلد';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get extensionLabel => 'الامتداد';

  @override
  String get videoInfoLabel => 'معلومات الفيديو';

  @override
  String get durationLabel => 'المدة';

  @override
  String get pathLabel => 'المسار';

  @override
  String get playlistTitle => 'قائمة التشغيل';

  @override
  String get emptyPlaylist => 'قائمة التشغيل فارغة';
}
