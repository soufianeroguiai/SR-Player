// FILE: lib/providers/library_provider.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_extended_flutter/ffmpeg_kit_extended_flutter.dart';
import '../models/video_item.dart';

class LibraryProvider extends ChangeNotifier {
  List<VideoItem> _videos = [];
  List<String> _recentPaths = [];
  Set<String> _hiddenPaths = {};
  Set<String> _favoritePaths = {};
  List<String> _playlistPaths = [];
  bool _loading = false;
  String? _error;

  final Map<String, int> _positions = {};
  Map<String, List<int>> _bookmarks = {};

  List<VideoItem>? _visibleVideosCache;

  List<VideoItem> get videos {
    return _visibleVideosCache ??=
        _videos.where((v) => !_hiddenPaths.contains(v.path)).toList();
  }

  List<VideoItem> get allVideos => _videos;
  List<String> get recentPaths => _recentPaths;
  Set<String> get hiddenPaths => _hiddenPaths;
  Set<String> get favoritePaths => _favoritePaths;
  List<String> get playlistPaths => _playlistPaths;
  bool get loading => _loading;
  String? get error => _error;

  // كل تغيير فالحالة كيلغي الكاش، باش "videos" ما يعاودش يبني اللائحة
  // غير إلا تغير شيء فعلاً (بدل ما كان كيبنيها من جديد فكل استدعاء).
  @override
  void notifyListeners() {
    _visibleVideosCache = null;
    super.notifyListeners();
  }

  Map<String, List<VideoItem>> get byFolder {
    final map = <String, List<VideoItem>>{};
    for (final v in videos) {
      map.putIfAbsent(v.folder, () => []).add(v);
    }
    return map;
  }

  Duration? getCachedPosition(String path) {
    final ms = _positions[path];
    if (ms == null || ms <= 0) return null;
    return Duration(milliseconds: ms);
  }

  Future<Duration?> getPosition(String path) async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt('pos_$path');
    if (ms != null && ms > 0) {
      _positions[path] = ms;
      return Duration(milliseconds: ms);
    }
    return null;
  }

  Future<void> savePosition(String path, Duration position) async {
    _positions[path] = position.inMilliseconds;
    final p = await SharedPreferences.getInstance();
    await p.setInt('pos_$path', position.inMilliseconds);
    notifyListeners();
  }

  Future<void> clearPosition(String path) async {
    _positions.remove(path);
    final p = await SharedPreferences.getInstance();
    await p.remove('pos_$path');
    notifyListeners();
  }

  // 🔖 إشارات مرجعية متعددة داخل نفس الفيديو (بخلاف "استئناف التشغيل"
  // اللي كيحتفظ بنقطة وحدة فقط)
  List<Duration> getBookmarks(String path) {
    final list = _bookmarks[path] ?? const <int>[];
    return list.map((ms) => Duration(milliseconds: ms)).toList();
  }

  Future<void> loadBookmarks() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('bookmarks_json');
    if (raw != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(raw);
        _bookmarks = decoded.map((k, v) => MapEntry(k, List<int>.from(v as List)));
      } catch (_) {
        _bookmarks = {};
      }
    }
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('bookmarks_json', json.encode(_bookmarks));
  }

  Future<void> addBookmark(String path, Duration position) async {
    final list = _bookmarks.putIfAbsent(path, () => []);
    final ms = position.inMilliseconds;
    // تجنب إضافة إشارتين قريبتين بزاف من بعضهم (أقل من ثانيتين)
    if (list.any((e) => (e - ms).abs() < 2000)) return;
    list.add(ms);
    list.sort();
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> removeBookmark(String path, Duration position) async {
    final list = _bookmarks[path];
    if (list == null) return;
    list.remove(position.inMilliseconds);
    if (list.isEmpty) _bookmarks.remove(path);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> clearBookmarks(String path) async {
    _bookmarks.remove(path);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> loadHidden() async {
    final p = await SharedPreferences.getInstance();
    _hiddenPaths = Set<String>.from(p.getStringList('hidden_paths') ?? []);
    notifyListeners();
  }

  Future<void> hideVideo(String path) async {
    _hiddenPaths.add(path);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('hidden_paths', _hiddenPaths.toList());
    notifyListeners();
  }

  Future<void> unhideVideo(String path) async {
    _hiddenPaths.remove(path);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('hidden_paths', _hiddenPaths.toList());
    notifyListeners();
  }

  Future<void> clearHidden() async {
    _hiddenPaths.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove('hidden_paths');
    notifyListeners();
  }

  bool isFavorite(String path) => _favoritePaths.contains(path);

  Future<void> loadFavorites() async {
    final p = await SharedPreferences.getInstance();
    _favoritePaths = Set<String>.from(p.getStringList('favorite_paths') ?? []);
    notifyListeners();
  }

  Future<void> toggleFavorite(String path) async {
    if (_favoritePaths.contains(path)) {
      _favoritePaths.remove(path);
    } else {
      _favoritePaths.add(path);
    }
    final p = await SharedPreferences.getInstance();
    await p.setStringList('favorite_paths', _favoritePaths.toList());
    notifyListeners();
  }

  bool isInPlaylist(String path) => _playlistPaths.contains(path);

  Future<void> loadPlaylist() async {
    final p = await SharedPreferences.getInstance();
    _playlistPaths = p.getStringList('playlist_paths') ?? [];
    notifyListeners();
  }

  Future<bool> addToPlaylist(String path) async {
    if (_playlistPaths.contains(path)) return false;
    _playlistPaths.add(path);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('playlist_paths', _playlistPaths);
    notifyListeners();
    return true;
  }

  Future<void> removeFromPlaylist(String path) async {
    _playlistPaths.remove(path);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('playlist_paths', _playlistPaths);
    notifyListeners();
  }

  Future<void> clearPlaylist() async {
    _playlistPaths.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove('playlist_paths');
    notifyListeners();
  }

  void reorderPlaylist(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final path = _playlistPaths.removeAt(oldIndex);
    _playlistPaths.insert(newIndex, path);
    notifyListeners();
    SharedPreferences.getInstance().then((p) => p.setStringList('playlist_paths', _playlistPaths));
  }

  Future<void> loadCachedVideos() async {
    try {
      await _loadAllSavedPositions();
      await loadHidden();
      await loadFavorites();
      await loadPlaylist();
      await loadRecent();
      await loadBookmarks();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/video_cache.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _videos = jsonList
            .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
            .where((v) => File(v.path).existsSync())
            .toList();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('فشل تحميل الذاكرة المؤقتة: $e');
    }
  }

  Future<void> _loadAllSavedPositions() async {
    final p = await SharedPreferences.getInstance();
    final keys = p.getKeys();
    for (final key in keys) {
      if (key.startsWith('pos_')) {
        final path = key.substring(4);
        final ms = p.getInt(key);
        if (ms != null && ms > 0) {
          _positions[path] = ms;
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveVideosToCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/video_cache.json');
      final jsonList = _videos.map((v) => v.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('فشل حفظ الذاكرة المؤقتة: $e');
    }
  }

  Future<Duration> _getDurationWithFFprobe(String path) async {
    try {
      final session = await FFprobeKit.getMediaInformationAsync(
        path,
        onComplete: (_) {},
      );
      final info = session.getMediaInformation();
      if (info != null) {
        final durationStr = info.duration;
        final seconds = double.tryParse(durationStr ?? '') ?? 0.0;
        return Duration(milliseconds: (seconds * 1000).round());
      }
    } catch (_) {}
    return Duration.zero;
  }

  Future<VideoItem?> _buildVideoItem(AssetEntity asset, String albumName) async {
    try {
      final file = await asset.file;
      if (file == null) return null;

      String name = asset.title ?? '';
      if (name.isEmpty || name.length < 2) {
        name = file.path.split('/').last;
        final dotIndex = name.lastIndexOf('.');
        if (dotIndex != -1) {
          name = name.substring(0, dotIndex);
        }
        if (name.length < 2) {
          name = '$albumName ${asset.id}';
        }
      }

      Duration videoDuration = asset.videoDuration;
      if (videoDuration == Duration.zero) {
        videoDuration = await _getDurationWithFFprobe(file.path);
      }

      return VideoItem(
        id: asset.id,
        path: file.path,
        name: name,
        size: file.lengthSync(),
        modified: asset.modifiedDateTime,
        folder: albumName,
        duration: videoDuration,
        subtitleTypes: const [],
      );
    } catch (e) {
      debugPrint('خطأ في بناء عنصر الفيديو: $e');
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
        _error = 'لم يتم منح الإذن للوصول إلى الوسائط.';
        _loading = false;
        notifyListeners();
        return;
      }

      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      final List<VideoItem> result = [];

      const batchSize = 12;
      for (final album in albums) {
        if (album.name == 'Recent') continue;

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

      // إزالة التكرار: نفس الفيديو قد يظهر في أكثر من ألبوم واحد
      // (مثلاً "All videos" مع مجلده الأصلي)، فنعتمد المسار كمفتاح فريد.
      final Map<String, VideoItem> deduped = {};
      for (final v in result) {
        deduped[v.path] = v;
      }
      final uniqueResult = deduped.values.toList();

      uniqueResult.sort((a, b) => b.modified.compareTo(a.modified));
      _videos = uniqueResult;
      await _saveVideosToCache();
      await _loadAllSavedPositions();
    } catch (e) {
      _error = 'فشل المسح: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadRecent() async {
    final p = await SharedPreferences.getInstance();
    _recentPaths = p.getStringList('recent_paths') ?? [];
    notifyListeners();
  }

  Future<void> addRecent(String path) async {
    _recentPaths.remove(path);
    _recentPaths.insert(0, path);
    if (_recentPaths.length > 30) {
      _recentPaths = _recentPaths.sublist(0, 30);
    }
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
}