import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/video_item.dart';

/// يولّد ويخزّن الصور المصغّرة لفيديوهات المكتبة.
///
/// المصدر الأساسي هو [AssetEntity.thumbnailDataWithSize] من photo_manager:
/// استخراج native سريع لا يفتح أي مشغل فيديو ولا ينتظر أي مهلة يدوية.
/// يُستخدم video_thumbnail كحل ثانٍ للملفات اليدوية أو صيغ MKV/HEVC.
/// يُستخدم استخراج لقطة عبر media_kit فقط كحل بديل أخير.
class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final Map<String, ValueNotifier<Uint8List?>> _notifiers = {};
  final Set<String> _pendingPaths = {};

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
    if (_pendingPaths.contains(path)) return;
    _pendingPaths.add(path);

    try {
      final cacheFile = await _cacheFile(path);
      if (await cacheFile.exists()) {
        _notifiers[path]?.value = await cacheFile.readAsBytes();
        return;
      }

      Uint8List? bytes;

      // 1. للفيديوهات من المكتبة، نجرب AssetEntity أولاً
      if (video.id != path) {
        bytes = await _fromAssetEntity(video.id);
      }

      // 2. نجرب video_thumbnail (أسرع ويدعم MKV/HEVC)
      if (bytes == null) {
        bytes = await _fromVideoThumbnail(path);
      }

      // 3. كحل أخير، media_kit
      if (bytes == null) {
        bytes = await _fromMediaKitScreenshot(path);
      }

      if (bytes != null) {
        await cacheFile.writeAsBytes(bytes);
        _notifiers[path]?.value = bytes;
      }
    } catch (e) {
      debugPrint('تعذّر توليد الصورة المصغّرة لـ $path: $e');
    } finally {
      _pendingPaths.remove(path);
    }
  }

  Future<Uint8List?> _fromAssetEntity(String assetId) async {
    try {
      final asset = await AssetEntity.fromId(assetId);
      if (asset == null) return null;
      return await asset.thumbnailDataWithSize(
        const ThumbnailSize(360, 240),
        quality: 80,
      );
    } catch (e) {
      debugPrint('فشل استخراج صورة مصغّرة عبر photo_manager: $e');
      return null;
    }
  }

  /// استخدام مكتبة video_thumbnail لاستخراج الصورة المصغرة (يدعم MKV/HEVC)
  Future<Uint8List?> _fromVideoThumbnail(String path) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 360,
        quality: 80,
      );
      return thumbnail;
    } catch (e) {
      debugPrint('فشل استخراج الصورة المصغرة عبر video_thumbnail: $e');
      return null;
    }
  }

  /// حل بديل فقط لملف فُتح يدوياً وليس جزءاً من مكتبة الوسائط الممسوحة.
  Future<Uint8List?> _fromMediaKitScreenshot(String path) async {
    Player? player;
    try {
      player = Player();
      await player.open(Media(path), play: false);
      await Future.delayed(const Duration(milliseconds: 400));
      final shot = await player.screenshot(format: 'image/jpeg');
      return (shot != null && shot.isNotEmpty) ? shot : null;
    } catch (e) {
      debugPrint('فشل استخراج لقطة عبر media_kit: $e');
      return null;
    } finally {
      await player?.dispose();
    }
  }

  Future<File> _cacheFile(String videoPath) async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/thumb_${videoPath.hashCode}.jpg');
  }
}