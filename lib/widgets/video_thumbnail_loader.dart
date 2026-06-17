import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

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
  String? _thumbnailPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.videoPath.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final targetPath = '${tempDir.path}/$fileName.png';
      final file = File(targetPath);

      if (await file.exists()) {
        if (mounted) {
          setState(() {
            _thumbnailPath = targetPath;
            _isLoading = false;
          });
        }
        return;
      }

      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: widget.videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        maxHeight: 250,
        quality: 50,
      );

      if (mounted) {
        setState(() {
          _thumbnailPath = thumbnail;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("خطأ في استخراج الصورة المصغرة: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام SizedBox لتمكين التمدد مع width/height = double.infinity
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _isLoading
            ? Container(
                color: Colors.grey[900],
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                  ),
                ),
              )
            : _thumbnailPath != null
                ? Image.file(
                    File(_thumbnailPath!),
                    fit: BoxFit.cover, // يملأ المساحة بالكامل
                    width: widget.width,
                    height: widget.height,
                    errorBuilder: (ctx, err, stack) => const Icon(Icons.video_file, color: Colors.white54, size: 40),
                  )
                : Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
                  ),
      ),
    );
  }
}