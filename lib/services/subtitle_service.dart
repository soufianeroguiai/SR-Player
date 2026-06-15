import 'dart:io';
import 'package:srt_parser/srt_parser.dart';

class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String text;
  SubtitleEntry({required this.start, required this.end, required this.text});
}

class SubtitleService {
  /// ابحث تلقائياً عن ملف .srt بجانب الفيديو
  static String? findSrt(String videoPath) {
    final base = videoPath.replaceAll(RegExp(r'\.[^.]+$'), '');
    for (final ext in ['.srt', '.SRT']) {
      final f = File('$base$ext');
      if (f.existsSync()) return f.path;
    }
    return null;
  }

  /// تحليل ملف SRT وإرجاع قائمة SubtitleEntry
  static Future<List<SubtitleEntry>> load(String path) async {
    try {
      final content = await File(path).readAsString();
      final parser = SrtParser();
      final subtitles = parser.parse(content);
      return subtitles.map((s) => SubtitleEntry(
        start: _ms(s.startTime),
        end:   _ms(s.endTime),
        text:  s.data.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
      )).toList();
    } catch (e) {
      return [];
    }
  }

  static Duration _ms(int ms) => Duration(milliseconds: ms);
}
