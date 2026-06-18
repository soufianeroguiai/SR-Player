import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';

/// ─────────────────────────────────────────────
///  VideoThumbnailLoader – نسخة محسّنة
///  يستخدم photo_manager (متاح بالفعل) بدل
///  video_thumbnail الذي يفشل على أجهزة كثيرة
/// ─────────────────────────────────────────────
class VideoThumbnailLoader extends StatefulWidget {
  final String videoPath;
  final double width;
  final double height;

  const VideoThumbnailLoader({
    super.key,
    required this.videoPath,
    this.width = 120,
    this.height = 80,
  });

  @override
  State<VideoThumbnailLoader> createState() => _VideoThumbnailLoaderState();
}

class _VideoThumbnailLoaderState extends State<VideoThumbnailLoader> {
  Uint8List? _bytes;
  bool _loading = true;

  // ─── Cache مشترك بين كل instances ───────────
  static final Map<String, Uint8List?> _memCache = {};
  static final Map<String, Future<Uint8List?>> _pending = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = widget.videoPath;

    // 1. من الذاكرة مباشرة
    if (_memCache.containsKey(key)) {
      if (mounted) {
        setState(() {
          _bytes = _memCache[key];
          _loading = false;
        });
      }
      return;
    }

    // 2. إذا طلب مسبق جارٍ، انتظره
    if (_pending.containsKey(key)) {
      final result = await _pending[key];
      if (mounted) setState(() { _bytes = result; _loading = false; });
      return;
    }

    // 3. ابدأ طلب جديد
    final future = _generate(key);
    _pending[key] = future;

    final result = await future;
    _pending.remove(key);
    _memCache[key] = result;

    if (mounted) setState(() { _bytes = result; _loading = false; });
  }

  /// الطريقة الرئيسية: القرص → photo_manager → null
  static Future<Uint8List?> _generate(String videoPath) async {
    // ─── أ. كاش على القرص ─────────────────────
    try {
      final dir = await getTemporaryDirectory();
      final cacheFile = File('${dir.path}/thumb_${videoPath.hashCode}.jpg');
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }
    } catch (_) {}

    // ─── ب. photo_manager (الأموثوق) ──────────
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );
      for (final album in albums) {
        final count = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: count);
        for (final asset in assets) {
          final file = await asset.file;
          if (file != null && file.path == videoPath) {
            final thumb = await asset.thumbnailDataWithSize(
              const ThumbnailSize(320, 200),
              quality: 80,
              format: ThumbnailFormat.jpeg,
            );
            if (thumb != null) {
              // احفظ على القرص
              try {
                final dir = await getTemporaryDirectory();
                final cacheFile = File('${dir.path}/thumb_${videoPath.hashCode}.jpg');
                await cacheFile.writeAsBytes(thumb);
              } catch (_) {}
              return thumb;
            }
          }
        }
      }
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _loading
            ? _shimmer()
            : _bytes != null
                ? Image.memory(
                    _bytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
      ),
    );
  }

  Widget _shimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.9),
      duration: const Duration(milliseconds: 900),
      builder: (_, v, __) => Container(color: Colors.grey[900]!.withValues(alpha: v)),
      onEnd: () => setState(() {}), // يكرر الأنيميشن
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[900],
      child: const Icon(Icons.video_file_rounded, color: Colors.white30, size: 36),
    );
  }
}
