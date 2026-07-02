class SubtitleRenderService {
  static String processText(
    String rawText, {
    required bool ignoreAssFonts,
    required bool ignoreAssEffects,
    required bool fullUnicodeRtlSupport,
  }) {
    String processed = rawText;

    if (ignoreAssEffects || ignoreAssFonts) {
      processed = _parseAssTags(processed, ignoreAssEffects, ignoreAssFonts);
    }

    processed = processed.replaceAll(RegExp(r'\\[Nn]'), '\n');

    if (fullUnicodeRtlSupport && _containsArabic(processed)) {
      processed = '\u2067$processed\u2069';
    }

    return processed.trim();
  }

  static String _parseAssTags(String text, bool ignoreEffects, bool ignoreFonts) {
    String result = text;

    if (ignoreEffects) {
      result = result.replaceAll(RegExp(r'\{[^}]*\}'), '');
    } else if (ignoreFonts) {
      result = result.replaceAll(RegExp(r'\\fn[^}\\]*'), '');
      result = result.replaceAll(RegExp(r'\\fs\d+'), '');
      result = result.replaceAll(RegExp(r'\\fsc[xy]?\d+'), '');
      result = result.replaceAll(RegExp(r'\\fsp\d+'), '');
      result = result.replaceAll(RegExp(r'\\bord\d+'), '');
      result = result.replaceAll(RegExp(r'\\blur\d+'), '');
      result = result.replaceAll(RegExp(r'\\be\d+'), '');
      result = result.replaceAll(RegExp(r'\\shad\d+'), '');
      result = result.replaceAll(RegExp(r'\\fr[xyz]?\d+'), '');
      result = result.replaceAll(RegExp(r'\\c&H[^}&]+'), '');
      result = result.replaceAll(RegExp(r'\\alpha&H[^}&]+'), '');
      result = result.replaceAll(RegExp(r'\\move\([^}]*\)'), '');
      result = result.replaceAll(RegExp(r'\\fade\([^}]*\)'), '');
      result = result.replaceAll(RegExp(r'\\clip\([^}]*\)'), '');
      result = result.replaceAll(RegExp(r'\\t\([^}]*\)'), '');
      result = result.replaceAll(RegExp(r'\\q\d'), '');
      result = result.replaceAll(RegExp(r'\\an\d'), '');
      result = result.replaceAll(RegExp(r'\\pos\([^}]*\)'), '');
      result = result.replaceAll(RegExp(r'\\org\([^}]*\)'), '');
      result = result.replaceAll(RegExp(r'\\k[f]?\d+'), '');
      result = result.replaceAll(RegExp(r'\\K\d+'), '');
      result = result.replaceAll(RegExp(r'\\p\d+'), '');
      result = result.replaceAll(RegExp(r'\\pbo\d+'), '');
    }

    return result;
  }

  static bool _containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}