class SubtitleParser {
  /// ينظف النص الخام القادم من MediaKit ليصبح جاهزاً للعرض
  static String clean(String? rawText, {bool ignoreAssEffects = false}) {
    if (rawText == null || rawText.trim().isEmpty) return '';

    String text = rawText;

    // تحويل فواصل الأسطر الخاصة بـ ASS إلى فواصل نظامية
    text = text.replaceAll(r'\N', '\n');

    // إزالة أكواد التحكم بـ ASS إذا كان المستخدم يريد تجاهل التأثيرات
    if (ignoreAssEffects) {
      text = text.replaceAll(RegExp(r'\{.*?\}'), '');
    }

    // إزالة رموز الاتجاه المخفية (Bidi Controls) التي قد تسبب تشوهاً
    text = text.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u061C]'), '');

    // إزالة الفراغات الزائدة من الأطراف
    return text.trim();
  }
}