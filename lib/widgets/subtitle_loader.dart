import 'dart:io';

class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String text;

  SubtitleEntry({
    required this.start,
    required this.end,
    required this.text,
  });
}

class SubtitleLoader {
  /// Tries to auto-find a .srt file next to the video file
  static String? findSrtFor(String videoPath) {
    final base = videoPath.replaceAll(RegExp(r'\.[^.]+$'), '');
    final srt = '$base.srt';
    if (File(srt).existsSync()) return srt;

    // Also try same name with different extension
    final parts = videoPath.split('/');
    final name = parts.last.replaceAll(RegExp(r'\.[^.]+$'), '');
    final dir = parts.sublist(0, parts.length - 1).join('/');
    final srt2 = '$dir/$name.srt';
    if (File(srt2).existsSync()) return srt2;

    return null;
  }

  static Future<List<SubtitleEntry>> loadSrt(String path) async {
    final file = File(path);
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      return parseSrt(content);
    } catch (_) {
      return [];
    }
  }

  static List<SubtitleEntry> parseSrt(String content) {
    final entries = <SubtitleEntry>[];
    // Split by blank lines
    final blocks = content.trim().split(RegExp(r'\r?\n\r?\n'));

    for (final block in blocks) {
      final lines = block.trim().split(RegExp(r'\r?\n'));
      if (lines.length < 3) continue;
      try {
        // Skip index line (lines[0])
        final timeLine = lines[1];
        final parts = timeLine.split(' --> ');
        if (parts.length != 2) continue;

        final start = _parseTime(parts[0].trim());
        final end = _parseTime(parts[1].split(' ').first.trim()); // ignore positioning
        final text = lines
            .sublist(2)
            .join('\n')
            .replaceAll(RegExp(r'<[^>]*>'), '') // strip HTML tags
            .trim();

        if (text.isNotEmpty) {
          entries.add(SubtitleEntry(start: start, end: end, text: text));
        }
      } catch (_) {}
    }
    return entries;
  }

  static Duration _parseTime(String s) {
    // Format: 00:01:02,500 or 00:01:02.500
    final normalized = s.replaceAll(',', '.');
    final main = normalized.split('.');
    final ms = int.tryParse(main.last.padRight(3, '0').substring(0, 3)) ?? 0;
    final hms = main.first.split(':');
    final h = int.parse(hms[0]);
    final m = int.parse(hms[1]);
    final sec = int.parse(hms[2]);
    return Duration(hours: h, minutes: m, seconds: sec, milliseconds: ms);
  }
}
