import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_thumbnail_gen/video_thumbnail_gen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:media_kit/media_kit.dart';

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

  static final Map<String, Uint8List?> _memCache = {};
  static final Map<String, Future<Uint8List?>> _pending = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final key = widget.videoPath;

    if (_memCache.containsKey(key)) {
      if (mounted) setState(() { _bytes = _memCache[key]; _loading = false; });
      return;
    }

    if (_pending.containsKey(key)) {
      final result = await _pending[key];
      if (mounted) setState(() { _bytes = result; _loading = false; });
      return;
    }

    final future = _generate(key);
    _pending[key] = future;
    final result = await future;
    _pending.remove(key);
    _memCache[key] = result;

    if (mounted) setState(() { _bytes = result; _loading = false; });
  }

  static Future<Uint8List?> _generate(String videoPath) async {
    try {
      final dir = await getTemporaryDirectory();
      final cacheFile = File('${dir.path}/thumb_${videoPath.hashCode}.jpg');
      if (await cacheFile.exists()) {
        return await cacheFile.readAsBytes();
      }

      try {
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: videoPath,
          thumbnailPath: dir.path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 200,
          quality: 75,
        );

        if (thumbnail != null) {
          final bytes = await File(thumbnail).readAsBytes();
          await cacheFile.writeAsBytes(bytes);
          return bytes;
        }
      } catch (_) {}

      final player = Player();
      await player.open(Media(videoPath), play: false);
      await Future.delayed(const Duration(milliseconds: 500));
      final screenshot = await player.screenshot(format: 'image/jpeg');
      await player.dispose();

      if (screenshot != null && screenshot.isNotEmpty) {
        await cacheFile.writeAsBytes(screenshot);
        return screenshot;
      }

      return null;
    } catch (e) {
      debugPrint('Thumbnail error: $e');
      return null;
    }
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
                ? Image.memory(_bytes!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
      ),
    );
  }

  Widget _shimmer() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 0.9),
      duration: const Duration(milliseconds: 900),
      builder: (_, v, __) => Container(color: Colors.grey[900]!.withValues(alpha: v)),
      onEnd: () => setState(() {}),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[900],
      child: const Icon(Icons.video_file_rounded, color: Colors.white30, size: 36),
    );
  }
}