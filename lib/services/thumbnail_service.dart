import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_item.dart';

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final Map<String, ValueNotifier<Uint8List?>> _notifiers = {};
  final Set<String> _pendingPaths = {};
  final List<VideoItem> _queue = [];
  int _activeJobs = 0;
  static const int _maxConcurrent = 2;

  ValueNotifier<Uint8List?> getNotifier(VideoItem video) {
    final path = video.path;
    if (!_notifiers.containsKey(path)) {
      _notifiers[path] = ValueNotifier(null);
      _generate(video);
    }
    return _notifiers[path]!;
  }

  Future<void> _generate(VideoItem video) async {
    final path = video.path;
    final cacheFile = await _cacheFile(path);
    
    if (await cacheFile.exists()) {
      _notifiers[path]?.value = await cacheFile.readAsBytes();
      if (video.subtitlesNotifier.value.isEmpty && ['mkv', 'mp4', 'avi', 'webm', 'm4v'].contains(video.extension)) {
        _queueItem(video);
      }
      return;
    }
    _queueItem(video);
  }

  void _queueItem(VideoItem video) {
    if (!_pendingPaths.contains(video.path)) {
      _pendingPaths.add(video.path);
      _queue.add(video);
      _processQueue();
    }
  }

  void _processQueue() async {
    while (_queue.isNotEmpty && _activeJobs < _maxConcurrent) {
      _activeJobs++;
      final video = _queue.removeAt(0);
      final path = video.path;
      
      try {
        final player = Player();
        await player.open(Media(path), play: false);
        await Future.delayed(const Duration(milliseconds: 600));

        // 1. فحص الترجمات المدمجة داخل ملف الفيديو
        final tracks = player.state.tracks.subtitle;
        final types = <String>{};
        for (final track in tracks) {
          final id = (track.id ?? '').toLowerCase();
          final title = (track.title ?? '').toLowerCase();
          if (id.contains('srt') || title.contains('srt') || title.contains('subrip')) types.add('SRT');
          if (id.contains('ass') || title.contains('ass')) types.add('ASS');
          if (id.contains('ssa') || title.contains('ssa')) types.add('SSA');
          if (id.contains('vtt') || title.contains('vtt')) types.add('VTT');
        }
        
        if (types.isNotEmpty) {
          video.subtitleTypes = types.toList();
          video.subtitlesNotifier.value = video.subtitleTypes;
        }

        // 2. استخراج لقطة الشاشة المصغرة
        if (_notifiers[path]?.value == null) {
          final screenshot = await player.screenshot(format: 'image/jpeg');
          if (screenshot != null && screenshot.isNotEmpty) {
            final cacheFile = await _cacheFile(path);
            await cacheFile.writeAsBytes(screenshot);
            _notifiers[path]?.value = screenshot;
          }
        }
        await player.dispose();
      } catch (e) {
        debugPrint("خطأ في معالجة الفيديو: $e");
      } finally {
        _pendingPaths.remove(path);
        _activeJobs--;
        _processQueue();
      }
    }
  }

  Future<File> _cacheFile(String videoPath) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/thumb_${videoPath.hashCode}.jpg');
  }
}
