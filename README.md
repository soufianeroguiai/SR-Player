# MX Clone - Flutter Video Player

تطبيق مشغل فيديو كامل مبني بـ Flutter مستوحى من MX Player.

## المميزات

- **مسح تلقائي** لجميع الفيديوهات على الجهاز
- **تصفية بالمجلد** مع شريط الفلترة السريع
- **بحث** في الفيديوهات
- **الملفات الأخيرة** مع إمكانية مسحها
- **عرض بالمجلدات** مع إجمالي الحجم
- **مشغل كامل** مع:
  - تحكم باللمس (play/pause/seek)
  - Gesture controls:
    - يسار: سطوع الشاشة (سحب للأعلى/أسفل)
    - يمين: مستوى الصوت (سحب للأعلى/أسفل)
    - وسط: التقديم/الإرجاع (سحب يمين/يسار)
  - Double tap للتقديم ±10 ثواني
  - شريط التقدم
  - سرعة التشغيل (0.25x - 2x)
  - وضع Fullscreen
- **ترجمة SRT**:
  - تحميل تلقائي إذا كان ملف .srt بنفس اسم الفيديو
  - تحميل يدوي من زر في المشغل
  - تفعيل/تعطيل بزر واحد
- **معلومات الفيديو** (اسم، حجم، مدة، مجلد، مسار)
- **Wakelock** - الشاشة لا تنطفئ أثناء التشغيل

## التثبيت

### 1. المتطلبات

- Flutter 3.10+
- Android SDK 21+

### 2. تثبيت الـ packages

```bash
flutter pub get
```

### 3. Android Permissions

الملف `android/app/src/main/AndroidManifest.xml` موجود ومضبوط.

لـ Android 11+ (API 30+) أضف في `android/app/build.gradle`:
```gradle
android {
    ...
    defaultConfig {
        ...
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

### 4. تشغيل التطبيق

```bash
flutter run
```

### 5. بناء APK

```bash
flutter build apk --release
```

## الـ Packages المستخدمة

| Package | الوظيفة |
|---------|---------|
| `video_player` | تشغيل الفيديو |
| `file_picker` | اختيار الملفات |
| `permission_handler` | صلاحيات الجهاز |
| `shared_preferences` | حفظ الملفات الأخيرة |
| `wakelock_plus` | منع إطفاء الشاشة |
| `screen_brightness` | التحكم في السطوع |
| `volume_controller` | التحكم في الصوت |

## هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية
├── theme/
│   └── app_theme.dart          # ثيم التطبيق (داكن + برتقالي)
├── models/
│   └── video_file.dart         # نموذج ملف الفيديو
├── services/
│   ├── media_scanner.dart      # مسح الفيديوهات
│   └── recent_files_service.dart # حفظ الأخيرة
├── screens/
│   ├── home_screen.dart        # الشاشة الرئيسية
│   ├── player_screen.dart      # المشغل
│   └── info_screen.dart        # معلومات الفيديو
└── widgets/
    ├── video_card.dart         # بطاقة الفيديو
    └── subtitle_loader.dart    # محمّل الترجمة SRT
```

## الترجمة SRT

ضع ملف الترجمة بنفس اسم الفيديو:
```
/Movies/فيلم.mp4
/Movies/فيلم.srt   ← يُحمَّل تلقائياً
```

أو اضغط زر 📤 في المشغل لتحميل ملف يدوياً.
