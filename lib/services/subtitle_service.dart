import 'dart:io';

class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String text;
  SubtitleEntry({required this.start, required this.end, required this.text});
}

class SubtitleService {
  /// Auto-detect .srt file next to the video
  static String? findSrt(String videoPath) {
    final base = videoPath.replaceAll(RegExp(r'\.[^.]+$'), '');
    for (final ext in ['.srt', '.SRT']) {
      final f = File('$base$ext');
      if (f.existsSync()) return f.path;
    }
    return null;
  }

  /// Parse SRT file — no external library needed
  static Future<List<SubtitleEntry>> load(String path) async {
    try {
      final content = await File(path).readAsString();
      return _parse(content);
    } catch (_) {
      return [];
    }
  }

  static List<SubtitleEntry> _parse(String content) {
    final entries = <SubtitleEntry>[];
    final blocks = content.trim().split(RegExp(r'\r?\n\r?\n'));

    for (final block in blocks) {
      final lines = block.trim().split(RegExp(r'\r?\n'));
      if (lines.length < 3) continue;
      try {
        // line 0 = index number, line 1 = timestamps
        final timeLine = lines[1];
        final parts = timeLine.split(' --> ');
        if (parts.length != 2) continue;

        final start = _parseTime(parts[0].trim());
        final end   = _parseTime(parts[1].trim().split(' ').first);
        final text  = lines.sublist(2).join('\n')
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .trim();

        if (text.isNotEmpty) {
          entries.add(SubtitleEntry(start: start, end: end, text: text));
        }
      } catch (_) {}
    }
    return entries;
  }

  /// Parse "00:01:23,456" or "00:01:23.456"
  static Duration _parseTime(String s) {
    final normalized = s.replaceAll(',', '.');
    final dotIndex = normalized.lastIndexOf('.');
    int ms = 0;
    String hms = normalized;

    if (dotIndex != -1) {
      ms = int.tryParse(normalized.substring(dotIndex + 1).padRight(3, '0').substring(0, 3)) ?? 0;
      hms = normalized.substring(0, dotIndex);
    }

    final parts = hms.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    final sec = int.tryParse(parts[2]) ?? 0;
    return Duration(hours: h, minutes: m, seconds: sec, milliseconds: ms);
  }
}
