import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> scan() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // طلب الصلاحية
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && !ps.hasAccess) {
        _error = 'لم يتم منح الإذن للوصول إلى الوسائط.\nالرجاء منح الصلاحية من إعدادات التطبيق.';
        _loading = false;
        notifyListeners();
        return;
      }

      // جلب ألبومات الفيديو
      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      final List<VideoItem> result = [];

      for (final album in albums) {
        final count = await album.assetCountAsync;
        // استخدام getAssetListRange (مضمون)
        final assets = await album.getAssetListRange(start: 0, end: count);
        for (final asset in assets) {
          // استخدام getMediaUrl للحصول على رابط المحتوى
          final mediaUrl = await asset.getMediaUrl();
          if (mediaUrl == null) continue;

          // الحصول على الحجم الحقيقي (بالبايت)
          int fileSize = 0;
          try {
            final file = await asset.file;
            if (file != null) {
              fileSize = file.lengthSync();
            }
          } catch (_) {
            fileSize = 0;
          }

          result.add(VideoItem(
            id: asset.id,
            path: mediaUrl,
            name: asset.title ?? 'فيديو ${asset.id}',
            size: fileSize,
            modified: asset.modifiedDateTime,
            folder: album.name,
            duration: asset.videoDuration,
          ));
        }
      }

      result.sort((a, b) => b.modified.compareTo(a.modified));
      _videos = result;
    } catch (e) {
      _error = 'فشل المسح: $e';
    }

    _loading = false;
    notifyListeners();
    _loadThumbnails(); // تحميل الصور المصغرة بعد نجاح المسح
  }

  Future<void> _loadThumbnails() async {
    // نعمل على نسخة من القائمة الحالية
    final videosToProcess = List<VideoItem>.from(_videos);
    try {
      // نعيد استخدام getAssetPathList لجلب الأصول مرة واحدة
      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      for (final album in albums) {
        final count = await album.assetCountAsync;
        // نستخدم getAssetListRange (نفس الطريقة الموثوقة)
        final assets = await album.getAssetListRange(start: 0, end: count);

        for (final video in videosToProcess) {
          if (!_videos.contains(video)) continue; // الفيديو أُزيل أثناء التحميل

          try {
            final asset = assets.firstWhere(
              (a) => a.id == video.id,
              orElse: () => assets.isNotEmpty ? assets.first : null as dynamic,
            );
            if (asset == null) continue;

            final thumb = await asset.thumbnailDataWithSize(
              const ThumbnailSize(180, 120),
              quality: 75,
            );
            if (thumb != null) {
              video.thumbnail = thumb.toList();
              notifyListeners();
            }
          } catch (_) {
            // فشل تحميل هذه الصورة – تجاهل وتابع
          }
        }
      }
    } catch (_) {}
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