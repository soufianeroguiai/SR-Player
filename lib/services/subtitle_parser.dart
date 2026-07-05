class SubtitleParser {
  static String clean(String? rawText, {bool ignoreAssEffects = false}) {
    if (rawText == null || rawText.trim().isEmpty) return '';

    String text = rawText;

    text = text.replaceAll(r'\N', '\n');

    if (ignoreAssEffects) {
      text = text.replaceAll(RegExp(r'\{.*?\}'), '');
    }

    text = text.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u061C]'), '');

    return text.trim();
  }
}