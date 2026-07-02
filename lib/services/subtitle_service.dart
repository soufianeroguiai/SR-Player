import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/subtitle_settings.dart';
import 'subtitle_encodings.dart';
import 'subtitle_render_service.dart';

class SubtitleEntry {
  final Duration start;
  final Duration end;
  final String text;
  SubtitleEntry({required this.start, required this.end, required this.text});
}

class SubtitleService {
  static final Map<String, List<SubtitleEntry>> _cache = {};

  static String? findSrt(String videoPath) {
    final base = videoPath.replaceAll(RegExp(r'\.[^.]+$'), '');
    for (final ext in ['.srt', '.SRT', '.ssa', '.SSA', '.ass', '.ASS']) {
      final f = File('$base$ext');
      if (f.existsSync()) return f.path;
    }
    return null;
  }

  static Future<List<SubtitleEntry>> load(
    String path, {
    required SubtitleSettings settings,
    String encoding = 'UTF-8',
  }) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }

    try {
      final bytes = await File(path).readAsBytes();
      final ext = path.split('.').last.toLowerCase();

      final entries = await compute(parseSubtitleContent, {
        'bytes': bytes,
        'ext': ext,
        'encoding': encoding,
        'ignoreAssFonts': settings.ignoreAssFonts,
        'ignoreAssEffects': settings.ignoreAssEffects,
        'hideWhenNoDialog': settings.hideWhenNoDialog,
        'fullUnicodeRtlSupport': settings.fullUnicodeRtlSupport,
      });

      _cache[path] = entries;
      return entries;
    } catch (_) {
      return [];
    }
  }

  static int findCurrentEntryIndex(List<SubtitleEntry> entries, Duration position) {
    if (entries.isEmpty) return -1;
    int left = 0;
    int right = entries.length - 1;
    int result = -1;

    while (left <= right) {
      final mid = (left + right) ~/ 2;
      if (entries[mid].start <= position) {
        result = mid;
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }

    if (result != -1 && entries[result].end < position) {
      return -1;
    }
    return result;
  }

  static void clearCache() {
    _cache.clear();
  }
}

List<SubtitleEntry> parseSubtitleContent(Map<String, dynamic> params) {
  final bytes = params['bytes'] as List<int>;
  final ext = params['ext'] as String;
  final encodingName = params['encoding'] as String;

  final bool ignoreAssFonts = params['ignoreAssFonts'] ?? false;
  final bool ignoreAssEffects = params['ignoreAssEffects'] ?? false;
  final bool hideWhenNoDialog = params['hideWhenNoDialog'] ?? false;
  final bool fullUnicodeRtlSupport = params['fullUnicodeRtlSupport'] ?? true;

  final content = SubtitleEncodings.decode(bytes, encodingName);

  if (ext == 'ssa' || ext == 'ass') {
    return _parseSsa(content, ignoreAssFonts, ignoreAssEffects, hideWhenNoDialog, fullUnicodeRtlSupport);
  } else {
    return _parseSrt(content, fullUnicodeRtlSupport);
  }
}

List<SubtitleEntry> _parseSrt(String content, bool fullUnicodeRtlSupport) {
  final entries = <SubtitleEntry>[];
  final blocks = content.trim().split(RegExp(r'\r?\n\r?\n'));

  for (final block in blocks) {
    final lines = block.trim().split(RegExp(r'\r?\n'));
    if (lines.length < 3) continue;
    try {
      final timeLine = lines[1];
      final parts = timeLine.split(' --> ');
      if (parts.length != 2) continue;

      final start = _parseTime(parts[0].trim());
      final end = _parseTime(parts[1].trim().split(' ').first);

      String text = lines.sublist(2).join('\n').replaceAll(RegExp(r'<[^>]*>'), '').trim();

      if (fullUnicodeRtlSupport) {
        text = SubtitleRenderService.processText(text, ignoreAssFonts: false, ignoreAssEffects: false, fullUnicodeRtlSupport: true);
      }

      if (text.isNotEmpty) {
        entries.add(SubtitleEntry(start: start, end: end, text: text));
      }
    } catch (_) {}
  }
  return entries;
}

List<SubtitleEntry> _parseSsa(
  String content,
  bool ignoreAssFonts,
  bool ignoreAssEffects,
  bool hideWhenNoDialog,
  bool fullUnicodeRtlSupport,
) {
  final entries = <SubtitleEntry>[];
  bool inEvents = false;
  final lines = content.split(RegExp(r'\r?\n'));
  int formatIndex = -1;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('[Events]')) {
      inEvents = true;
      continue;
    }
    if (trimmed.startsWith('[') && !trimmed.startsWith('[Events]')) {
      inEvents = false;
      continue;
    }
    if (!inEvents) continue;
    if (trimmed.startsWith('Format:')) {
      final fields = trimmed.substring(7).split(',').map((e) => e.trim()).toList();
      formatIndex = fields.indexOf('Text');
      continue;
    }
    if (trimmed.startsWith('Dialogue:')) {
      if (formatIndex < 0) continue;
      final parts = _splitDialogue(trimmed.substring(9));
      if (parts.length <= formatIndex) continue;
      try {
        final start = _parseSsaTime(parts[1]);
        final end = _parseSsaTime(parts[2]);
        final rawText = parts.sublist(formatIndex).join(',');
        final cleanText = SubtitleRenderService.processText(
          rawText,
          ignoreAssFonts: ignoreAssFonts,
          ignoreAssEffects: ignoreAssEffects,
          fullUnicodeRtlSupport: fullUnicodeRtlSupport,
        );
        if (cleanText.isEmpty && hideWhenNoDialog) continue;
        if (cleanText.isNotEmpty) {
          entries.add(SubtitleEntry(start: start, end: end, text: cleanText));
        }
      } catch (_) {}
    }
  }
  return entries;
}

List<String> _splitDialogue(String line) {
  final parts = <String>[];
  int depth = 0;
  final current = StringBuffer();
  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '{') depth++;
    if (char == '}') depth--;
    if (char == ',' && depth == 0) {
      parts.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  parts.add(current.toString().trim());
  return parts;
}

Duration _parseSsaTime(String s) {
  s = s.trim();
  final parts = s.split(':');
  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;
  final secParts = parts[2].split('.');
  final seconds = int.tryParse(secParts[0]) ?? 0;
  final centiseconds = int.tryParse(secParts[1]) ?? 0;
  return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: centiseconds * 10);
}

Duration _parseTime(String s) {
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