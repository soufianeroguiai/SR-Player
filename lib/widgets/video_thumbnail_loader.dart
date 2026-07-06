import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/video_item.dart';
import '../services/thumbnail_service.dart';
import '../l10n/app_localizations.dart';

class VideoThumbnailLoader extends StatelessWidget {
  final VideoItem video;
  final double width;
  final double height;

  const VideoThumbnailLoader({
    super.key,
    required this.video,
    this.width = 120,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final thumbnailService = ThumbnailService();
    thumbnailService.prioritize(video);
    final thumbnailNotifier = thumbnailService.getNotifier(video);
    final errorNotifier = thumbnailService.getErrorNotifier(video);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ValueListenableBuilder<Uint8List?>(
          valueListenable: thumbnailNotifier,
          builder: (context, bytes, child) {
            if (bytes != null) {
              return Image.memory(
                bytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) =>
                    _buildPlaceholder(t.thumbnailError),
              );
            }
            return ValueListenableBuilder<String?>(
              valueListenable: errorNotifier,
              builder: (context, errorCode, _) =>
                  _buildPlaceholder(_localizedThumbnailError(t, errorCode)),
            );
          },
        ),
      ),
    );
  }

  // ThumbnailService كيخزّن كود خطأ ثابت (بلا لغة) بدل نص جاهز، حتى
  // الواجهة هي اللي تقرر الترجمة المناسبة حسب لغة التطبيق الحالية.
  String _localizedThumbnailError(AppLocalizations t, String? code) {
    switch (code) {
      case 'extract_failed':
        return t.thumbnailExtractFailed;
      case 'file_not_found':
        return t.fileNotFoundMessage;
      case 'empty_output':
        return t.outputFileEmptyMessage;
      case 'ffmpeg_failed':
        return t.ffmpegFailedMessage;
      case 'timeout':
        return t.timeoutMessage;
      case 'exception':
      default:
        return t.thumbnailError;
    }
  }

  Widget _buildPlaceholder(String errorText) {
    if (errorText.isNotEmpty) {
      return Container(
        color: const Color(0xFF1A1A1A),
        padding: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Text(
          errorText,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 8,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.video_file_rounded,
            color: Colors.white30, size: 36),
      ),
    );
  }
}