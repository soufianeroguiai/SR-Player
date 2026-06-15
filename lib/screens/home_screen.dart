import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/video_file.dart';
import '../services/media_scanner.dart';
import '../services/recent_files_service.dart';
import '../theme/app_theme.dart';
import '../widgets/video_card.dart';
import 'player_screen.dart';
import 'info_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<VideoFile> _allVideos = [];
  List<String> _recentPaths = [];
  bool _loading = true;
  String? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final videos = await MediaScanner.scan();
    final recent = await RecentFilesService.get();
    setState(() {
      _allVideos = videos;
      _recentPaths = recent;
      _loading = false;
    });
  }

  List<VideoFile> get _filtered {
    if (_selectedFolder == null) return _allVideos;
    return _allVideos.where((v) => v.folder == _selectedFolder).toList();
  }

  List<VideoFile> get _recent {
    return _recentPaths.map((p) {
      try {
        if (!File(p).existsSync()) return null;
        final stat = File(p).statSync();
        final parts = p.split('/');
        return VideoFile(
          path: p,
          name: parts.last,
          size: stat.size,
          modified: stat.modified,
          folder: parts.length > 1 ? parts[parts.length - 2] : '',
        );
      } catch (_) {
        return null;
      }
    }).whereType<VideoFile>().toList();
  }

  Map<String, List<VideoFile>> get _byFolder {
    final map = <String, List<VideoFile>>{};
    for (final v in _allVideos) {
      map.putIfAbsent(v.folder, () => []).add(v);
    }
    return map;
  }

  Set<String> get _folders => _allVideos.map((v) => v.folder).toSet();

  void _openPlayer(String path) async {
    await RecentFilesService.add(path);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerScreen(filePath: path)),
    );
    final recent = await RecentFilesService.get();
    if (mounted) setState(() => _recentPaths = recent);
  }

  void _openInfo(VideoFile video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InfoScreen(video: video)),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result?.files.single.path != null) {
      _openPlayer(result!.files.single.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'الأخيرة'),
            Tab(text: 'المجلدات'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: _VideoSearchDelegate(_allVideos, _openPlayer),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.orange))
          : TabBarView(
              controller: _tabs,
              children: [
                _buildAllTab(),
                _buildRecentTab(),
                _buildFoldersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickFile,
        backgroundColor: AppTheme.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.folder_open),
        label: const Text('فتح ملف'),
      ),
    );
  }

  // ── All Videos Tab ──────────────────────────────────────────────
  Widget _buildAllTab() {
    final list = _filtered;
    return Column(
      children: [
        if (_folders.isNotEmpty) _buildFolderFilter(),
        Expanded(
          child: list.isEmpty
              ? _buildEmpty('ما لقينا فيديوهات')
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => VideoCard(
                    video: list[i],
                    onTap: () => _openPlayer(list[i].path),
                    onMoreTap: () => _showVideoMenu(list[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFolderFilter() {
    final folders = _folders.toList()..sort();
    return Container(
      height: 44,
      color: AppTheme.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _chip('الكل', _selectedFolder == null,
              () => setState(() => _selectedFolder = null)),
          ...folders.map((f) => _chip(
                f,
                _selectedFolder == f,
                () => setState(() =>
                    _selectedFolder = _selectedFolder == f ? null : f),
              )),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.orange : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Recent Tab ──────────────────────────────────────────────────
  Widget _buildRecentTab() {
    final list = _recent;
    if (list.isEmpty) return _buildEmpty('ما شفتي فيديو بعد');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${list.length} ملف حديث',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              TextButton(
                onPressed: () async {
                  await RecentFilesService.clear();
                  setState(() => _recentPaths = []);
                },
                child: const Text('مسح الكل',
                    style: TextStyle(color: AppTheme.orange, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) => VideoCard(
              video: list[i],
              onTap: () => _openPlayer(list[i].path),
              onMoreTap: () => _showVideoMenu(list[i]),
            ),
          ),
        ),
      ],
    );
  }

  // ── Folders Tab ─────────────────────────────────────────────────
  Widget _buildFoldersTab() {
    final byFolder = _byFolder;
    final keys = byFolder.keys.toList()..sort();
    if (keys.isEmpty) return _buildEmpty('ما لقينا مجلدات');

    return ListView.builder(
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final folder = keys[i];
        final videos = byFolder[folder]!;
        final totalSize = videos.fold<int>(0, (sum, v) => sum + v.size);
        final sizeStr = totalSize < 1024 * 1024 * 1024
            ? '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.folder_rounded,
                color: AppTheme.orange, size: 28),
          ),
          title: Text(folder,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          subtitle: Text(
            '${videos.length} فيديو  •  $sizeStr',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          trailing:
              const Icon(Icons.chevron_right, color: Colors.white24),
          onTap: () {
            setState(() => _selectedFolder = folder);
            _tabs.animateTo(0);
          },
        );
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────
  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined,
              size: 80, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 16),
          Text(msg,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.35), fontSize: 17)),
          const SizedBox(height: 8),
          Text('اضغط "فتح ملف" لاختيار فيديو',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.2), fontSize: 13)),
        ],
      ),
    );
  }

  void _showVideoMenu(VideoFile video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              video.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.play_arrow, color: AppTheme.orange),
            title: const Text('تشغيل', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _openPlayer(video.path);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.info_outline, color: Colors.white54),
            title:
                const Text('معلومات', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _openInfo(video);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Search Delegate ─────────────────────────────────────────────────
class _VideoSearchDelegate extends SearchDelegate<String> {
  final List<VideoFile> videos;
  final void Function(String) onOpen;

  _VideoSearchDelegate(this.videos, this.onOpen);

  @override
  String get searchFieldLabel => 'ابحث عن فيديو...';

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final results = query.isEmpty
        ? videos
        : videos
            .where((v) =>
                v.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (results.isEmpty) {
      return Center(
        child: Text('ما لقينا نتائج لـ "$query"',
            style: const TextStyle(color: Colors.white38)),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => VideoCard(
        video: results[i],
        onTap: () {
          close(context, results[i].path);
          onOpen(results[i].path);
        },
      ),
    );
  }
}
