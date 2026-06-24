import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail_gen/video_thumbnail_gen.dart'; // ✅ الاستيراد الصحيح
import '../models/video_item.dart';

/// يولّد ويخزّن الصور المصغّرة لفيديوهات المكتبة.
///
/// ترتيب الأولوية:
/// 1. ذاكرة التخزين المؤقت (ملف JPEG محلي) — فوري
/// 2. photo_manager (AssetEntity) — سريع وnative للـ MP4
/// 3. video_thumbnail_gen — يدعم MKV/HEVC/أي صيغة يدعمها ffmpeg
class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final Map<String, ValueNotifier<Uint8List?>> _notifiers = {};
  final Set<String> _pending = {};
  int _active = 0;
  static const _maxConcurrent = 3;
  final List<Future<void> Function()> _queue = [];

  ValueNotifier<Uint8List?> getNotifier(VideoItem video) {
    final path = video.path;
    if (!_notifiers.containsKey(path)) {
      _notifiers[path] = ValueNotifier(null);
      _enqueue(video);
    }
    return _notifiers[path]!;
  }

  void _enqueue(VideoItem video) {
    _queue.add(() => _generate(video));
    _drain();
  }

  void _drain() {
    while (_active < _maxConcurrent && _queue.isNotEmpty) {
      final task = _queue.removeAt(0);
      _active++;
      task().whenComplete(() {
        _active--;
        _drain();
      });
    }
  }

  Future<void> _generate(VideoItem video) async {
    final path = video.path;
    if (_pending.contains(path)) return;
    _pending.add(path);

    try {
      // 1. ذاكرة التخزين المؤقت
      final cacheFile = await _cacheFile(path);
      if (await cacheFile.exists()) {
        final bytes = await cacheFile.readAsBytes();
        if (bytes.isNotEmpty) {
          _notifiers[path]?.value = bytes;
          return;
        }
      }

      Uint8List? bytes;

      // 2. photo_manager — سريع للـ MP4/WebM (لها AssetEntity حقيقي)
      if (video.id != path) {
        bytes = await _fromPhotoManager(video.id);
      }

      // 3. video_thumbnail_gen — يدعم MKV/HEVC وأي صيغة
      bytes ??= await _fromVideoThumbnailGen(path, cacheFile.path);

      if (bytes != null && bytes.isNotEmpty) {
        if (!await cacheFile.exists()) {
          await cacheFile.writeAsBytes(bytes);
        }
        _notifiers[path]?.value = bytes;
      }
    } catch (e) {
      debugPrint('ThumbnailService: $e');
    } finally {
      _pending.remove(path);
    }
  }

  Future<Uint8List?> _fromPhotoManager(String assetId) async {
    try {
      final asset = await AssetEntity.fromId(assetId);
      if (asset == null) return null;
      return await asset.thumbnailDataWithSize(
        const ThumbnailSize(360, 240),
        quality: 85,
      );
    } catch (e) {
      debugPrint('ThumbnailService/photo_manager: $e');
      return null;
    }
  }

  Future<Uint8List?> _fromVideoThumbnailGen(String videoPath, String savePath) async {
    try {
      // ✅ استخدام الوظيفة الصحيحة من المكتبة حسب التوثيق
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: savePath, // يمكن أن يكون مسار ملف كامل أو مجلد
        imageFormat: ImageFormat.JPEG,
        maxWidth: 360,
        quality: 85,
        timeMs: 5000,
      );
      if (thumbPath == null) return null;
      final file = File(thumbPath);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('ThumbnailService/video_thumbnail_gen: $e');
      return null;
    }
  }

  Future<File> _cacheFile(String videoPath) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/thumb_${videoPath.hashCode}.jpg');
  }

  Future<void> clearCache() async {
    final dir = await getTemporaryDirectory();
    final files = dir.listSync().where((f) => f.path.contains('thumb_'));
    for (final f in files) {
      try { f.deleteSync(); } catch (_) {}
    }
    _notifiers.forEach((_, n) => n.value = null);
    _notifiers.clear();
  }
}