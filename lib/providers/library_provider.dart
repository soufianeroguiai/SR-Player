import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';  // ✅ أضفنا الاستيراد
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
      // ✅ طلب الصلاحيات المناسبة حسب إصدار أندرويد
      bool granted = false;
      if (await _requestMediaPermissions()) {
        // نطلب صلاحية photo_manager (للكشف عن الفيديوهات)
        final pmResult = await PhotoManager.requestPermissionExtend();
        granted = pmResult.isAuth;
      }

      if (!granted) {
        _error = 'لم يتم منح الإذن للوصول إلى الوسائط.\nالرجاء منح الصلاحية من إعدادات التطبيق.';
        _loading = false;
        notifyListeners();
        return;
      }

      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      final Set<String> seen = {};
      final List<VideoItem> result2 = [];

      for (final album in albums) {
        final count = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: count);
        for (final asset in assets) {
          if (seen.contains(asset.id)) continue;
          seen.add(asset.id);
          final file = await asset.file;
          if (file == null) continue;
          result2.add(VideoItem(
            id: asset.id,
            path: file.path,
            name: asset.title ?? file.path.split('/').last,
            size: file.lengthSync(),
            modified: asset.modifiedDateTime,
            folder: album.name,
            duration: asset.videoDuration,
          ));
        }
      }

      result2.sort((a, b) => b.modified.compareTo(a.modified));
      _videos = result2;
    } catch (e) {
      _error = 'فشل المسح: ${e.toString()}';
    }

    _loading = false;
    notifyListeners();
    _loadThumbnails();
  }

  /// طلب الصلاحيات المطلوبة حسب إصدار أندرويد
  Future<bool> _requestMediaPermissions() async {
    // Android 13+ (API 33) يحتاج صلاحيات وسائط مفصلة
    if (await Permission.videos.isGranted) return true;

    // طلب الصلاحية مع إظهار مربع الحوار
    final status = await Permission.videos.request();
    if (status.isGranted) return true;

    // إذا رفض المستخدم، نظهر تنبيهًا
    if (status.isPermanentlyDenied) {
      // يمكن توجيه المستخدم للإعدادات
      // openAppSettings();
      return false;
    }
    return false;
  }

  Future<void> _loadThumbnails() async {
    final videosToProcess = List<VideoItem>.from(_videos);
    try {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      if (albums.isEmpty) return;

      for (final album in albums) {
        final count = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: count);

        for (final video in videosToProcess) {
          if (!_videos.contains(video)) continue;
          try {
            final asset = assets.firstWhere((a) => a.id == video.id,
                orElse: () => assets.isNotEmpty ? assets.first : null as dynamic);
            if (asset == null) continue;

            final thumb = await asset.thumbnailDataWithSize(
              const ThumbnailSize(180, 120),
              quality: 75,
            );
            if (thumb != null) {
              video.thumbnail = thumb.toList();
              notifyListeners();
            }
          } catch (_) {}
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