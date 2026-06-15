# S-Player 🎬

مشغّل فيديو متكامل مبني بـ Flutter مستوحى من MX Player.

## المميزات

### 📚 المكتبة
- مسح تلقائي لجميع الفيديوهات عبر `photo_manager`
- صور مصغرة (Thumbnails) حقيقية من الفيديوهات
- تصفية حسب المجلد
- عرض قائمة أو شبكة (Grid/List)
- ترتيب حسب: التاريخ، الاسم، الحجم، المدة
- الملفات الأخيرة مع إمكانية المسح
- بحث سريع

### 🎬 المشغّل (better_player)
- إيماءات السطوع والصوت مدمجة
- التحكم بسرعة التشغيل (0.25x → 2x)
- دعم ترجمة SRT / VTT مع تحميل تلقائي
- تقديم/إرجاع ±10 ثواني
- Fullscreen / Portrait
- تذكر موضع التشغيل
- Picture-in-Picture جاهز للتفعيل

### ⚙️ الإعدادات
- المظهر: داكن / فاتح / تلقائي
- تذكر موضع التشغيل
- تشغيل تلقائي
- سرعة التشغيل الافتراضية
- إظهار الترجمة تلقائياً
- الترتيب الافتراضي
- عرض الشبكة/القائمة

### 🛠️ تقني
- Flutter Embedding **v2**
- Material Design **3** كامل
- أيقونات **Material Symbols Rounded**
- Provider للـ State Management
- package: `com.splayer.app`

## المكتبات

| المكتبة | الوظيفة |
|---------|---------|
| `better_player` | مشغل متقدم مع إيماءات + ترجمة + سرعة |
| `photo_manager` | مسح الوسائط + thumbnails |
| `video_thumbnail` | صور مصغرة إضافية |
| `srt_parser` | تحليل ملفات الترجمة |
| `file_picker` | اختيار ملف يدوي |
| `permission_handler` | إدارة الصلاحيات |
| `material_symbols_icons` | أيقونات MD3 Rounded |
| `provider` | State Management |
| `shared_preferences` | حفظ الإعدادات |
| `wakelock_plus` | منع إطفاء الشاشة |
| `share_plus` | مشاركة الملفات |
| `flutter_pip` | Picture-in-Picture |

## التثبيت

```bash
cd s_player
flutter pub get
flutter run
```

## بناء APK

```bash
flutter build apk --release
```

## هيكل المشروع

```
lib/
├── main.dart
├── theme/app_theme.dart          # MD3 Theme
├── models/video_item.dart        # نموذج البيانات
├── providers/
│   ├── settings_provider.dart    # الإعدادات
│   └── library_provider.dart     # المكتبة + photo_manager
├── screens/
│   ├── home_screen.dart          # الشاشة الرئيسية
│   ├── player_screen.dart        # المشغل (better_player)
│   ├── settings_screen.dart      # الإعدادات
│   └── info_screen.dart          # معلومات الفيديو
└── widgets/
    └── video_card.dart           # بطاقة الفيديو (List + Grid)
```
