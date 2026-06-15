import 'dart:io';
import '../models/video_file.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaScanner {
  static const _videoExtensions = [
    'mp4', 'mkv', 'avi', 'mov', 'webm', '3gp', 'flv', 'm4v', 'wmv', 'ts', 'mts'
  ];

  static final _scanDirs = [
    '/storage/emulated/0',
    '/storage/emulated/0/DCIM',
    '/storage/emulated/0/Movies',
    '/storage/emulated/0/Download',
    '/storage/emulated/0/Downloads',
    '/storage/emulated/0/Videos',
    '/storage/emulated/0/WhatsApp/Media/WhatsApp Video',
    '/storage/emulated/0/Telegram',
  ];

  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Try Android 13+ first
      final videos = await Permission.videos.request();
      if (videos.isGranted) return true;

      // Fallback for older Android
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
    return true;
  }

  static Future<List<VideoFile>> scan() async {
    final granted = await requestPermissions();
    if (!granted) return [];

    final List<VideoFile> files = [];
    final Set<String> seen = {};

    for (final dirPath in _scanDirs) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await _scanDir(dir, files, seen);
      }
    }

    files.sort((a, b) => b.modified.compareTo(a.modified));
    return files;
  }

  static Future<void> _scanDir(
    Directory dir,
    List<VideoFile> results,
    Set<String> seen,
  ) async {
    try {
      final entities = dir.listSync(recursive: true, followLinks: false);
      for (final e in entities) {
        if (e is File && !seen.contains(e.path)) {
          final ext = e.path.split('.').last.toLowerCase();
          if (_videoExtensions.contains(ext)) {
            seen.add(e.path);
            final stat = e.statSync();
            final parts = e.path.split('/');
            results.add(VideoFile(
              path: e.path,
              name: parts.last,
              size: stat.size,
              modified: stat.modified,
              folder: parts.length > 1 ? parts[parts.length - 2] : 'Unknown',
            ));
          }
        }
      }
    } catch (_) {}
  }
}
