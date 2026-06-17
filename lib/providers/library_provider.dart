import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import '../models/video_item.dart';

class LibraryProvider extends ChangeNotifier {
  List<VideoItem> _videos = [];
  List<String> _recentPaths = [];
  bool _loading = false;
  String? _error;

  List<VideoItem> get videos => _videos;
  List<String> get recentPaths => _recentPaths;
  bool get loading => _loading;
  String? get error => _error;

  Map<String, List<VideoItem>> get byFolder {
    final map = <String, List<VideoItem>>{};
    for (final v in _videos) {
      map.putIfAbsent(v.folder, () => []).add(v);
    }
    return map;
  }

  Future<VideoItem?> _buildVideoItem(AssetEntity asset, String albumName) async {
    try {
      final mediaUrl = await asset.getMediaUrl();
      if (mediaUrl == null) return null;

      int fileSize = 0;
      try {
        final file = await asset.file;
        if (file != null) fileSize = file.lengthSync();
      } catch (_) {
        fileSize = 0;
      }

      return VideoItem(
        id: asset.id,
        path: mediaUrl,
        name: asset.title ?? 'فيديو ${asset.id}',
        size: fileSize,
        modified: asset.modifiedDateTime,
        folder: albumName,
        duration: asset.videoDuration,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> scan() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) {
        _error = 'لم يتم منح الإذن للوصول إلى الوسائط.\nالرجاء منح الصلاحية من إعدادات التطبيق.';
        _loading = false;
        notifyListeners();
        return;
      }

      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      final List<VideoItem> result = [];

      const batchSize = 12;
      for (final album in albums) {
        final count = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: count);

        for (var i = 0; i < assets.length; i += batchSize) {
          final batch = assets.skip(i).take(batchSize);
          final items = await Future.wait(
            batch.map((asset) => _buildVideoItem(asset, album.name)),
          );
          result.addAll(items.whereType<VideoItem>());
        }
      }

      result.sort((a, b) => b.modified.compareTo(a.modified));
      _videos = result;
    } catch (e) {
      _error = 'فشل المسح: $e';
    }

    _loading = false;
    notifyListeners();
    _loadThumbnails(); // تحميل الصور المصغرة
  }

  Future<void> _loadThumbnails() async {
    final videosToProcess = List<VideoItem>.from(_videos);
    if (videosToProcess.isEmpty) return;

    try {
      // نحصل على أصول الفيديوهات مرة واحدة فقط
      final assetMap = <String, AssetEntity>{};
      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      for (final album in albums) {
        final count = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: count);
        for (final asset in assets) {
          assetMap[asset.id] = asset;
        }
      }

      // نعالج كل فيديو على حدة
      for (final video in videosToProcess) {
        if (!_videos.contains(video)) continue;

        final asset = assetMap[video.id];
        if (asset == null) {
          // إذا لم نجد الأصل، نستخدم MediaKit كخطة بديلة
          await _generateThumbnailFromVideo(video);
          continue;
        }

        try {
          // محاولة جلب صورة مصغرة من photo_manager
          final thumb = await asset.thumbnailDataWithSize(
            const ThumbnailSize(180, 120),
            quality: 75,
          );
          if (thumb != null && thumb.isNotEmpty) {
            video.thumbnail = thumb.toList();
            notifyListeners();
            continue;
          }
        } catch (_) {
          // فشل photo_manager، نجرب MediaKit
        }

        // Fallback: استخراج صورة من الفيديو مباشرة
        await _generateThumbnailFromVideo(video);
      }
    } catch (_) {}
  }

  /// يستخدم MediaKit لالتقاط إطار من الفيديو كصورة مصغرة
  Future<void> _generateThumbnailFromVideo(VideoItem video) async {
    try {
      final player = Player();
      await player.open(Media(video.path), play: false);

      // ننتظر قليلاً حتى يتم تحميل الفيديو
      await Future.delayed(const Duration(milliseconds: 500));

      // نلتقط لقطة شاشة
      final screenshot = await player.screenshot(format: 'image/jpeg');
      if (screenshot != null && screenshot.isNotEmpty) {
        video.thumbnail = screenshot.toList();
        notifyListeners();
      }

      await player.dispose();
    } catch (e) {
      debugPrint('فشل استخراج صورة مصغرة بالفيديو: $e');
    }
  }

  Future<void> loadRecent() async {
    final p = await SharedPreferences.getInstance();
    _recentPaths = p.getStringList('recent_paths') ?? [];
    notifyListeners();
  }

  Future<void> addRecent(String path) async {
    _recentPaths.remove(path);
    _recentPaths.insert(0, path);
    if (_recentPaths.length > 30) _recentPaths.removeLast();
    final p = await SharedPreferences.getInstance();
    await p.setStringList('recent_paths', _recentPaths);
    notifyListeners();
  }

  Future<void> clearRecent() async {
    _recentPaths.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove('recent_paths');
    notifyListeners();
  }

  Future<void> savePosition(String path, Duration pos) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('pos_${path.hashCode}', pos.inMilliseconds);
  }

  Future<Duration?> getPosition(String path) async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt('pos_${path.hashCode}');
    if (ms == null || ms == 0) return null;
    return Duration(milliseconds: ms);
  }
}