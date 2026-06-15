import 'dart:typed_data';

class VideoItem {
  final String id;
  final String path;
  final String name;
  final int size;
  final DateTime modified;
  final String folder;
  final Duration duration;
  Uint8List? thumbnail;

  VideoItem({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
    required this.folder,
    required this.duration,
    this.thumbnail,
  });

  String get extension => path.split('.').last.toLowerCase();

  String get formattedSize {
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(0)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String get formattedDuration {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String get formattedDate {
    final y = modified.year;
    final mo = modified.month.toString().padLeft(2, '0');
    final d = modified.day.toString().padLeft(2, '0');
    return '$y-$mo-$d';
  }
}
