/// Services/subtitle_render_service.dart
/// خدمة معالجة نصوص الترجمة (تنظيف، إزالة تأثيرات ASS، دعم RTL)
/// تُستخدم مرة واحدة عند تحميل الترجمة أو عند ورود نص جديد من المشغل.

class SubtitleRenderService {
  static String processText(
    String rawText, {
    required bool ignoreAssFonts,
    required bool ignoreAssEffects,
    required bool fullUnicodeRtlSupport,
  }) {
    if (rawText.trim().isEmpty) return '';

    String processed = rawText;

    // 1. تحويل فواصل الأسطر الخاصة بـ ASS إلى \n نظامي
    processed = processed.replaceAll(RegExp(r'\\[Nn]'), '\n');

    // 2. إزالة أكواد ASS (خطوط، تأثيرات، أو كل شيء)
    if (ignoreAssEffects || ignoreAssFonts) {
      processed = _parseAssTags(processed, ignoreAssEffects, ignoreAssFonts);
    }

    if (ignoreAssEffects) {
      // إزالة أي أقواس متبقية (تأثيرات لم تعالجها _parseAssTags)
      processed = processed.replaceAll(RegExp(r'\{.*?\}'), '');
    }

    // 3. إزالة رموز الاتجاه المخفية (Bidi Controls)
    processed = processed.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u061C]'), '');

    // 4. دعم RTL بإضافة وسم ترتيب Unicode إذا كان النص عربيًا
    if (fullUnicodeRtlSupport && _containsArabic(processed)) {
      processed = '\u2067$processed\u2069';
    }

    return processed.trim();
  }

  // --- private helpers ---

  /// يعالج أكواد ASS: إما يحذف كل الأقواس (تأثيرات) أو فقط ما يتعلق بالخطوط
  static String _parseAssTags(String text, bool ignoreEffects, bool ignoreFonts) {
    if (ignoreEffects) {
      // إزالة كل ما بين {} بما في ذلك تأثيرات الحركة والقص...
      return text.replaceAll(RegExp(r'\{[^}]*\}'), '');
    }

    // وضع تجاهل الخطوط فقط (إزالة وسوم معينة دون إزالة الأقواس بالكامل)
    String result = text;
    if (ignoreFonts) {
      result = result
          .replaceAll(RegExp(r'\\fn[^}\\]*'), '')
          .replaceAll(RegExp(r'\\fs\d+'), '')
          .replaceAll(RegExp(r'\\fsc[xy]?\d+'), '')
          .replaceAll(RegExp(r'\\fsp\d+'), '')
          .replaceAll(RegExp(r'\\bord\d+'), '')
          .replaceAll(RegExp(r'\\blur\d+'), '')
          .replaceAll(RegExp(r'\\be\d+'), '')
          .replaceAll(RegExp(r'\\shad\d+'), '')
          .replaceAll(RegExp(r'\\fr[xyz]?\d+'), '')
          .replaceAll(RegExp(r'\\c&H[^}&]+'), '')
          .replaceAll(RegExp(r'\\alpha&H[^}&]+'), '')
          .replaceAll(RegExp(r'\\move\([^}]*\)'), '')
          .replaceAll(RegExp(r'\\fade\([^}]*\)'), '')
          .replaceAll(RegExp(r'\\clip\([^}]*\)'), '')
          .replaceAll(RegExp(r'\\t\([^}]*\)'), '')
          .replaceAll(RegExp(r'\\q\d'), '')
          .replaceAll(RegExp(r'\\an\d'), '')
          .replaceAll(RegExp(r'\\pos\([^}]*\)'), '')
          .replaceAll(RegExp(r'\\org\([^}]*\)'), '')
          .replaceAll(RegExp(r'\\k[f]?\d+'), '')
          .replaceAll(RegExp(r'\\K\d+'), '')
          .replaceAll(RegExp(r'\\p\d+'), '')
          .replaceAll(RegExp(r'\\pbo\d+'), '');
    }
    return result;
  }

  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}