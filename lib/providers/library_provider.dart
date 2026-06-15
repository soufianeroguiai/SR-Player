import 'dart:typed_data';
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

  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth;
  }

  Future<void> scan() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final granted = await requestPermission();
      if (!granted) {
        _error = 'لم يتم منح الإذن للوصول إلى الوسائط';
        _loading = false;
        notifyListeners();
        return;
      }

      // Get all video albums
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        onlyAll: false,
      );

      final Set<String> seen = {};
      final List<VideoItem> result = [];

      for (final album in albums) {
        final assets = await album.getAssetListRange(
          start: 0,
          end: await album.assetCountAsync,
        );
        for (final asset in assets) {
          if (seen.contains(asset.id)) continue;
          seen.add(asset.id);
          final file = await asset.file;
          if (file == null) continue;

          result.add(VideoItem(
            id: asset.id,
            path: file.path,
            name: asset.title ?? file.path.split('/').last,
            size: asset.size.isNaN ? 0 : (asset.orientatedSize.width * asset.orientatedSize.height).toInt(),
            modified: asset.modifiedDateTime,
            folder: album.name,
            duration: asset.videoDuration,
          ));
        }
      }

      // Sort by date desc
      result.sort((a, b) => b.modified.compareTo(a.modified));
      _videos = result;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();

    // Load thumbnails in background
    _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.video,
      onlyAll: true,
    );
    if (albums.isEmpty) return;

    final allAssets = await albums.first.getAssetListRange(
      start: 0,
      end: await albums.first.assetCountAsync,
    );

    final assetMap = {for (final a in allAssets) a.id: a};

    for (final video in _videos) {
      final asset = assetMap[video.id];
      if (asset == null) continue;
      try {
        final thumb = await asset.thumbnailDataWithSize(
          const ThumbnailSize(200, 140),
          quality: 80,
        );
        if (thumb != null) {
          video.thumbnail = thumb;
          notifyListeners();
        }
      } catch (_) {}
    }
  }

  // Recent files
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

  // Playback position
  Future<void> savePosition(String path, Duration position) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('pos_${path.hashCode}', position.inMilliseconds);
  }

  Future<Duration?> getPosition(String path) async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt('pos_${path.hashCode}');
    if (ms == null || ms == 0) return null;
    return Duration(milliseconds: ms);
  }
}
