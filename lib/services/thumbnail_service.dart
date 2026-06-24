import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_item.dart';

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final Map<String, ValueNotifier<Uint8List?>> _notifiers = {};
  final Map<String, ValueNotifier<String?>> _errors = {};
  final Set<String> _pending = {};
  int _active = 0;
  static const _maxConcurrent = 2;
  final List<Future<void> Function()> _queue = [];

  ValueNotifier<Uint8List?> getNotifier(VideoItem video) {
    final path = video.path;
    if (!_notifiers.containsKey(path)) {
      _notifiers[path] = ValueNotifier(null);
      _errors[path] = ValueNotifier(null);
      _enqueue(video);
    }
    return _notifiers[path]!;
  }

  ValueNotifier<String?> getErrorNotifier(VideoItem video) {
    final path = video.path;
    if (!_errors.containsKey(path)) {
      _errors[path] = ValueNotifier(null);
    }
    return _errors[path]!;
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
    _errors[path]?.value = null; // نبدأ بدون أخطاء

    try {
      final cacheFile = await _cacheFile(path);
      if (await cacheFile.exists()) {
        final bytes = await cacheFile.readAsBytes();
        if (bytes.isNotEmpty) {
          _notifiers[path]?.value = bytes;
          _errors[path]?.value = null; // ✅ تأكيد عدم وجود خطأ
          return;
        }
      }

      Uint8List? bytes;

      // 1. photo_manager (أسرع)
      if (video.id != path) {
        try {
          bytes = await _fromPhotoManager(video.id);
        } catch (e) {
          // نترك الخطأ مؤقتاً فقط، وسنمسحه إذا نجح media_kit
          _errors[path]?.value = null; // لا نعرض خطأ photo_manager الآن
        }
      }

      // 2. media_kit (لجميع الصيغ)
      if (bytes == null) {
        try {
          bytes = await _fromMediaKit(video.path, cacheFile.path);
          _errors[path]?.value = null; // ✅ نجحنا → لا خطأ
        } catch (e) {
          _errors[path]?.value = 'media_kit: $e';
        }
      }

      if (bytes != null && bytes.isNotEmpty) {
        if (!await cacheFile.exists()) {
          await cacheFile.writeAsBytes(bytes);
        }
        _notifiers[path]?.value = bytes;
      } else {
        // إذا لم يكن هناك خطأ مُسجَّل، نضع خطأً عاماً
        _errors[path]?.value ??= 'تعذر إنشاء صورة مصغرة';
      }
    } catch (e) {
      _errors[path]?.value = 'خطأ: $e';
    } finally {
      _pending.remove(path);
    }
  }

  Future<Uint8List?> _fromPhotoManager(String assetId) async {
    final asset = await AssetEntity.fromId(assetId);
    if (asset == null) return null;
    return await asset.thumbnailDataWithSize(
      const ThumbnailSize(360, 240),
      quality: 85,
    );
  }

  Future<Uint8List?> _fromMediaKit(String videoPath, String savePath) async {
    final player = Player();
    try {
      await player.open(Media(videoPath), play: false);
      final duration = player.state.duration;
      final seekPos = duration.inSeconds > 10
          ? const Duration(seconds: 5)
          : duration * 0.3;
      await player.seek(seekPos);
      await Future.delayed(const Duration(milliseconds: 500));
      final Uint8List? screenshotBytes = await player.screenshot(
        format: 'image/jpeg',
      );
      if (screenshotBytes != null) {
        final file = File(savePath);
        await file.writeAsBytes(screenshotBytes);
        return screenshotBytes;
      }
      return null;
    } finally {
      player.dispose();
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
    _errors.clear();
  }
}