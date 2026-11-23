class SubtitleRenderService {
  static String processText(
    String rawText, {
    required bool ignoreAssFonts,
    required bool ignoreAssEffects,
    required bool fullUnicodeRtlSupport,
  }) {
    if (rawText.trim().isEmpty) return '';

    String processed = rawText;

    processed = processed.replaceAll(RegExp(r'\\[Nn]'), '\n');

    if (ignoreAssEffects || ignoreAssFonts) {
      processed = _parseAssTags(processed, ignoreAssEffects, ignoreAssFonts);
    }

    if (ignoreAssEffects) {
      processed = processed.replaceAll(RegExp(r'\{.*?\}'), '');
    }

    processed = processed.replaceAll(RegExp(r'\{\s*\}'), '');

    processed = processed.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u061C]'), '');

    if (fullUnicodeRtlSupport && _containsArabic(processed)) {
      processed = '\u2067$processed\u2069';
    }

    return processed.trim();
  }

  static String _parseAssTags(String text, bool ignoreEffects, bool ignoreFonts) {
    if (ignoreEffects) {
      return text.replaceAll(RegExp(r'\{[^}]*\}'), '');
    }

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