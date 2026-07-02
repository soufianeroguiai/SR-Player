class SubtitleRenderService {
  /// ينظف أو يعدل نصوص الترجمة بناءً على إعدادات المستخدم المتقدمة.
  static String processText(
    String rawText, {
    required bool ignoreAssFonts,
    required bool ignoreAssEffects,
    required bool fullUnicodeRtlSupport,
  }) {
    String processed = rawText;

    // معالجة علامات SSA/ASS
    if (ignoreAssEffects || ignoreAssFonts) {
      // إذا طلب تجاهل كل التأثيرات، نزيل كل شيء بين {}
      if (ignoreAssEffects) {
        processed = processed.replaceAll(RegExp(r'\{[^}]*\}'), '');
      } 
      // إذا طلب تجاهل الخطوط فقط، نزيل علامات الخطوط وحجمها
      else if (ignoreAssFonts) {
        processed = processed.replaceAll(RegExp(r'\\fn[^}\\]*'), '');
        processed = processed.replaceAll(RegExp(r'\\fs\d+'), '');
      }
    }

    // تنظيف الأسطر الإضافية أو الفارغة
    processed = processed.replaceAll(RegExp(r'\\[Nn]'), '\n');

    // دعم Unicode الكامل لاتجاه النصوص (إضافة علامة RLM للنصوص العربية إذا لزم الأمر)
    // مفيد جداً عند دمج نصوص إنجليزية وعربية في نفس السطر
    if (fullUnicodeRtlSupport && _containsArabic(processed)) {
      // إضافة Right-To-Left Embedding لضمان عدم انعكاس الأرقام والرموز
      processed = '\u202B$processed\u202C';
    }

    return processed.trim();
  }

  /// يتحقق مما إذا كان النص يحتوي على حروف عربية.
  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
