import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/video_item.dart';
import '../../providers/library_provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../player/player_screen.dart';
import '../settings/settings_screen.dart';
import '../info_screen.dart';
import '../favorites_screen.dart';
import '../playlist_screen.dart';
import 'home_tabs.dart';
import 'home_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  String? _browsingFolder;

  late AnimationController _tuneController;
  late Animation<double> _tuneAnimation;

  late AnimationController _collectionsController;
  late Animation<double> _collectionsAnimation;

  late AnimationController _searchController;
  late Animation<double> _searchAnimation;

  bool _collectionsOpen = false;
  OverlayEntry? _collectionsOverlay;
  final GlobalKey _collectionsKey = GlobalKey();

  bool _isFabVisible = true;
  Timer? _showFabTimer;
  final Set<VideoItem> _selectedVideos = {};

  List<({String label, IconData active, IconData inactive})> _tabData(AppLocalizations t) => [
    (label: t.libraryTab, active: Icons.video_library_rounded, inactive: Icons.video_library_outlined),
    (label: t.myFilesTab, active: Icons.folder_rounded, inactive: Icons.folder_outlined),
    (label: t.recentTab, active: Icons.history_rounded, inactive: Icons.history_rounded),
    (label: t.personalTab, active: Icons.person_rounded, inactive: Icons.person_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();

    _tuneController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _tuneAnimation = Tween<double>(begin: 0, end: 0.25)
        .animate(CurvedAnimation(parent: _tuneController, curve: Curves.easeInOut));

    _collectionsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _collectionsAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _collectionsController, curve: Curves.easeInOut));

    _searchController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _searchAnimation = Tween<double>(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _searchController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _initLibrary());
  }

  @override
  void dispose() {
    _tuneController.dispose();
    _collectionsController.dispose();
    _searchController.dispose();
    _showFabTimer?.cancel();
    _collectionsOverlay?.remove();
    super.dispose();
  }

  Future<void> _initLibrary() async {
    final lib = context.read<LibraryProvider>();
    await lib.loadCachedVideos();
    if (!mounted) return;
    await lib.scan();
    await lib.loadRecent();
  }

  Future<void> _refreshLibrary() async {
    await context.read<LibraryProvider>().scan();
    await context.read<LibraryProvider>().loadRecent();
  }

  Future<void> _openPlayer(VideoItem video) async {
    await context.read<LibraryProvider>().addRecent(video.path);
    if (!mounted) return;
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => PlayerScreen(video: video)));
  }

  Future<void> _openByPath(String path) async {
    if (!File(path).existsSync()) return;
    final stat = File(path).statSync();
    await _openPlayer(
        VideoItem.fromPath(path: path, size: stat.size, modified: stat.modified));
  }

  void _playLastVideo() {
    final t = AppLocalizations.of(context)!;
    final lib = context.read<LibraryProvider>();
    if (lib.recentPaths.isNotEmpty) {
      _openByPath(lib.recentPaths.first);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.noPreviousVideo)));
    }
  }

  List<VideoItem> _sorted(List<VideoItem> list) {
    final s = context.read<SettingsProvider>();
    final sorted = List<VideoItem>.from(list);
    switch (s.sortBy) {
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case 'size':
        sorted.sort((a, b) => a.size.compareTo(b.size));
      case 'duration':
        sorted.sort((a, b) => a.duration.compareTo(b.duration));
      default:
        sorted.sort((a, b) => a.modified.compareTo(b.modified));
    }
    return s.sortDesc ? sorted.reversed.toList() : sorted;
  }

  void _onTunePressed() {
    if (_tuneController.isCompleted) {
      _tuneController.reverse();
    } else {
      _tuneController.forward();
    }
    _showViewOptionsPopup();
  }

  void _onCollectionsPressed() {
    if (_collectionsOpen) {
      _closeCollections();
    } else {
      _openCollections();
    }
  }

  void _openCollections() {
    _collectionsController.forward();
    setState(() => _collectionsOpen = true);
    _showCollectionsDropdown();
  }

  void _closeCollections() {
    _collectionsController.reverse();
    setState(() => _collectionsOpen = false);
    _collectionsOverlay?.remove();
    _collectionsOverlay = null;
  }

  void _showCollectionsDropdown() {
    final t = AppLocalizations.of(context)!;
    final RenderBox? box =
        _collectionsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final cs = Theme.of(context).colorScheme;
    final lib = context.read<LibraryProvider>();
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final screenWidth = MediaQuery.of(context).size.width;

    _collectionsOverlay = OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeCollections,
        child: Stack(
          children: [
            Positioned.directional(
              textDirection: Directionality.of(context),
              top: pos.dy + size.height + 8,
              start: isRtl ? pos.dx : screenWidth - pos.dx - size.width,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: cs.surface,
                child: Container(
                  width: 230,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dropItem(
                        icon: Icons.favorite_rounded,
                        iconOut: Icons.favorite_border_rounded,
                        label: t.favoritesLabel,
                        count: lib.favoritePaths.length,
                        color: Colors.redAccent,
                        cs: cs,
                        onTap: () {
                          _closeCollections();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const FavoritesScreen()));
                        },
                      ),
                      Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
                      _dropItem(
                        icon: Icons.queue_music_rounded,
                        iconOut: Icons.queue_music_rounded,
                        label: t.playlistLabel,
                        count: lib.playlistPaths.length,
                        color: cs.primary,
                        cs: cs,
                        onTap: () {
                          _closeCollections();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PlaylistScreen(
                                      playlist: lib.playlistPaths)));
                        },
                      ),
                      Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
                      _dropItem(
                        icon: Icons.playlist_play_rounded,
                        iconOut: Icons.playlist_play_rounded,
                        label: t.queueLabel,
                        count: lib.recentPaths.length,
                        color: Colors.orange,
                        cs: cs,
                        onTap: () {
                          _closeCollections();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PlaylistScreen(
                                      playlist: lib.recentPaths)));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_collectionsOverlay!);
  }

  Widget _dropItem({
    required IconData icon,
    required IconData iconOut,
    required String label,
    required int count,
    required Color color,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(count > 0 ? icon : iconOut, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      ),
    );
  }

  void _showViewOptionsPopup() {
    final t = AppLocalizations.of(context)!;
    final settings = context.read<SettingsProvider>();
    final cs = Theme.of(context).colorScheme;

    bool currentGrid = _currentIndex == 0
        ? settings.libraryGridView
        : _currentIndex == 1
            ? settings.foldersGridView
            : settings.recentGridView;

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final position = isRtl
        ? RelativeRect.fromLTRB(0, 80, 60, 0)
        : RelativeRect.fromLTRB(MediaQuery.of(context).size.width - 60, 80,
            MediaQuery.of(context).size.width, 0);

    showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'grid',
          child: Row(children: [
            Icon(Icons.grid_view_rounded,
                color: currentGrid ? cs.primary : null),
            const SizedBox(width: 12),
            Text(t.gridView,
                style: TextStyle(
                    fontWeight:
                        currentGrid ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
        PopupMenuItem(
          value: 'list',
          child: Row(children: [
            Icon(Icons.view_list_rounded,
                color: !currentGrid ? cs.primary : null),
            const SizedBox(width: 12),
            Text(t.listView,
                style: TextStyle(
                    fontWeight:
                        !currentGrid ? FontWeight.bold : FontWeight.normal)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'date',
          child: Row(children: [
            Icon(Icons.calendar_today_rounded,
                color: settings.sortBy == 'date' ? cs.primary : null),
            const SizedBox(width: 12),
            Text(t.sortByDate,
                style: TextStyle(
                    fontWeight: settings.sortBy == 'date'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ]),
        ),
        PopupMenuItem(
          value: 'name',
          child: Row(children: [
            Icon(Icons.sort_by_alpha_rounded,
                color: settings.sortBy == 'name' ? cs.primary : null),
            const SizedBox(width: 12),
            Text(t.sortByName,
                style: TextStyle(
                    fontWeight: settings.sortBy == 'name'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ]),
        ),
        PopupMenuItem(
          value: 'size',
          child: Row(children: [
            Icon(Icons.data_usage_rounded,
                color: settings.sortBy == 'size' ? cs.primary : null),
            const SizedBox(width: 12),
            Text(t.sortBySize,
                style: TextStyle(
                    fontWeight: settings.sortBy == 'size'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ]),
        ),
        PopupMenuItem(
          value: 'duration',
          child: Row(children: [
            Icon(Icons.timer_rounded,
                color: settings.sortBy == 'duration' ? cs.primary : null),
            const SizedBox(width: 12),
            Text(t.sortByDuration,
                style: TextStyle(
                    fontWeight: settings.sortBy == 'duration'
                        ? FontWeight.bold
                        : FontWeight.normal)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'toggle_order',
          child: Row(children: [
            Icon(settings.sortDesc
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded),
            const SizedBox(width: 12),
            Text(settings.sortDesc ? t.descending : t.ascending),
          ]),
        ),
      ],
    ).then((value) {
      _tuneController.reverse();
      if (value == null) return;
      if (value == 'grid') {
        if (_currentIndex == 0) settings.setLibraryGridView(true);
        else if (_currentIndex == 1) settings.setFoldersGridView(true);
        else settings.setRecentGridView(true);
      } else if (value == 'list') {
        if (_currentIndex == 0) settings.setLibraryGridView(false);
        else if (_currentIndex == 1) settings.setFoldersGridView(false);
        else settings.setRecentGridView(false);
      } else if (value == 'toggle_order') {
        settings.setSortDesc(!settings.sortDesc);
      } else {
        settings.setSortBy(value!);
      }
    });
  }

  void _toggleSelection(VideoItem video) {
    setState(() {
      if (_selectedVideos.contains(video)) {
        _selectedVideos.remove(video);
      } else {
        _selectedVideos.add(video);
      }
    });
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final lib = context.read<LibraryProvider>();
    final totalCount = lib.videos.length;
    final selectedCount = _selectedVideos.length;
    final isSingle = selectedCount == 1;
    final firstVideo = _selectedVideos.first;

    return AppBar(
      backgroundColor: cs.primaryContainer,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: cs.onPrimaryContainer),
        onPressed: () => setState(() => _selectedVideos.clear()),
      ),
      title: Text(t.selectedCount(selectedCount, totalCount),
          style: TextStyle(
              color: cs.onPrimaryContainer,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(Icons.play_arrow_rounded, color: cs.onPrimaryContainer),
          onPressed: () {
            if (_selectedVideos.isNotEmpty) {
              _openPlayer(firstVideo);
              setState(() => _selectedVideos.clear());
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.share_rounded, color: cs.onPrimaryContainer),
          onPressed: () {
            Share.shareXFiles(
                _selectedVideos.map((v) => XFile(v.path)).toList(),
                subject: t.shareFiles);
            setState(() => _selectedVideos.clear());
          },
        ),
        IconButton(
          icon: Icon(Icons.delete_rounded, color: cs.onPrimaryContainer),
          onPressed: () {
            _confirmDeleteMultiple(_selectedVideos.toList());
            setState(() => _selectedVideos.clear());
          },
        ),
        if (isSingle)
          IconButton(
            icon: Icon(Icons.info_rounded, color: cs.onPrimaryContainer),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => InfoScreen(video: firstVideo)));
              setState(() => _selectedVideos.clear());
            },
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: cs.onPrimaryContainer),
          onSelected: (value) {
            if (value == 'rename') {
              if (isSingle) _renameFile(firstVideo);
            } else if (value == 'hide') {
              for (final v in _selectedVideos) {
                context.read<LibraryProvider>().hideVideo(v.path);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.hideFilesToast(_selectedVideos.length))));
            }
            setState(() => _selectedVideos.clear());
          },
          itemBuilder: (context) => [
            if (isSingle) PopupMenuItem(value: 'rename', child: Text(t.renameFile)),
            PopupMenuItem(value: 'hide', child: Text(t.hide)),
          ],
        ),
      ],
    );
  }

  void _confirmDeleteMultiple(List<VideoItem> videos) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteFilesTitle),
        content: Text(t.deleteFilesConfirm(videos.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              for (final v in videos) {
                if (File(v.path).existsSync()) File(v.path).deleteSync();
              }
              context.read<LibraryProvider>().scan();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.filesDeletedToast(videos.length))));
            },
            child: Text(t.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    final t = AppLocalizations.of(context)!;
    final tabs = _tabData(t);
    final cs = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;
    final totalWidth = width - 32;
    final tabWidth = totalWidth / tabs.length;
    final textDir = Directionality.of(context);

    final double indicatorStart = textDir == TextDirection.rtl
        ? (tabs.length - 1 - _currentIndex) * tabWidth + 6
        : _currentIndex * tabWidth + 6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                left: indicatorStart,
                top: 8,
                bottom: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOutCubic,
                  width: tabWidth - 12,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final offset = details.localPosition.dx;
                  final newIndex = textDir == TextDirection.rtl
                      ? ((totalWidth - offset) / tabWidth).floor().clamp(0, tabs.length - 1)
                      : (offset / tabWidth).floor().clamp(0, tabs.length - 1);
                  if (newIndex != _currentIndex && newIndex != 3) {
                    setState(() => _currentIndex = newIndex);
                  }
                },
                onHorizontalDragEnd: (details) {
                  final offset = details.localPosition.dx;
                  final finalIndex = textDir == TextDirection.rtl
                      ? ((totalWidth - offset) / tabWidth).floor().clamp(0, tabs.length - 1)
                      : (offset / tabWidth).floor().clamp(0, tabs.length - 1);
                  if (finalIndex == 3) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()));
                  }
                },
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final tab = tabs[index];
                    final isActive = _currentIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (index == 3) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SettingsScreen()));
                            return;
                          }
                          setState(() => _currentIndex = index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isActive ? 1.18 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  isActive ? tab.active : tab.inactive,
                                  key: ValueKey('icon_${index}_$isActive'),
                                  color: isActive ? cs.primary : cs.onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                                color: isActive ? cs.primary : cs.onSurfaceVariant,
                              ),
                              child: Text(tab.label),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onScrollUpdate(double delta) {
    if (delta < -3) {
      if (_isFabVisible) setState(() => _isFabVisible = false);
    } else if (delta > 3) {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsProvider>();
    final lib = context.watch<LibraryProvider>();
    final bool isSelectionMode = _selectedVideos.isNotEmpty;

    return Scaffold(
      extendBody: true,
      appBar: isSelectionMode
          ? _buildSelectionAppBar()
          : AppBar(
              title: Text(t.appTitle),
              centerTitle: false,
              titleTextStyle: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 22),
              actions: [
                AnimatedBuilder(
                  animation: _collectionsAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_collectionsAnimation.value * 0.12),
                      child: IconButton(
                        key: _collectionsKey,
                        icon: Icon(
                          _collectionsOpen
                              ? Icons.collections_bookmark
                              : Icons.collections_bookmark_outlined,
                          color: _collectionsOpen ? cs.primary : null,
                        ),
                        onPressed: _onCollectionsPressed,
                        tooltip: t.collectionsTooltip,
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _tuneAnimation,
                  builder: (context, child) => Transform.rotate(
                    angle: _tuneAnimation.value * 2 * 3.14159,
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: _onTunePressed,
                      tooltip: t.viewOptionsTooltip,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _searchAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _searchAnimation.value,
                    child: child,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search_rounded),
                    onPressed: () async {
                      await _searchController.forward();
                      await _searchController.reverse();
                      if (!mounted) return;
                      showSearch(
                          context: context,
                          delegate: VideoSearchDelegate(lib.videos, _openPlayer, t));
                    },
                    tooltip: t.searchTooltip,
                  ),
                ),
              ],
            ),
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          if (notification.dragDetails != null) {
            _onScrollUpdate(notification.dragDetails!.delta.dy);
          }
          return false;
        },
        child: GestureDetector(
          onTap: () {
            if (isSelectionMode) setState(() => _selectedVideos.clear());
            if (_collectionsOpen) _closeCollections();
          },
          child: IndexedStack(
            index: _currentIndex,
            children: [
              RefreshIndicator(
                onRefresh: _refreshLibrary,
                child: LibraryTab(
                  videos: _sorted(lib.videos),
                  gridView: settings.libraryGridView,
                  onOpen: _openPlayer,
                  onMore: _buildVideoOptionsSheet,
                  loading: lib.loading,
                  selectedVideos: _selectedVideos,
                  onSelectionToggle: _toggleSelection,
                  t: t,
                ),
              ),
              _buildFoldersTab(lib, settings, t),
              RefreshIndicator(
                onRefresh: _refreshLibrary,
                child: RecentTab(
                  paths: lib.recentPaths,
                  all: lib.videos,
                  gridView: settings.recentGridView,
                  onOpen: _openByPath,
                  onClear: lib.clearRecent,
                  selectedVideos: _selectedVideos,
                  onSelectionToggle: _toggleSelection,
                  t: t,
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
      floatingActionButton: !isSelectionMode
          ? AnimatedOpacity(
              opacity: _isFabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: AnimatedScale(
                scale: _isFabVisible ? 1.0 : 0.7,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: FloatingActionButton(
                  onPressed: _isFabVisible ? _playLastVideo : null,
                  backgroundColor: cs.primary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFoldersTab(LibraryProvider lib, SettingsProvider settings, AppLocalizations t) {
    if (_browsingFolder != null) {
      final folderVideos = _sorted(
          lib.videos.where((v) => v.folder == _browsingFolder).toList());
      return Column(children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(children: [
            IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _browsingFolder = null),
                tooltip: t.backToFolders),
            const SizedBox(width: 4),
            Text(_browsingFolder!,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            Text(t.videosCount(folderVideos.length),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13)),
            const SizedBox(width: 8),
          ]),
        ),
        const Divider(height: 1),
        Expanded(
            child: LibraryTab(
          videos: folderVideos,
          gridView: settings.foldersGridView,
          onOpen: _openPlayer,
          onMore: _buildVideoOptionsSheet,
          loading: false,
          selectedVideos: _selectedVideos,
          onSelectionToggle: _toggleSelection,
          t: t,
        )),
      ]);
    }
    return RefreshIndicator(
        onRefresh: _refreshLibrary,
        child: FoldersTab(
            byFolder: lib.byFolder,
            gridView: settings.foldersGridView,
            onTap: (folder) => setState(() => _browsingFolder = folder),
            onMore: _buildFolderOptionsSheet,
            t: t));
  }

  void _buildVideoOptionsSheet(VideoItem video) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final lib = context.read<LibraryProvider>();
    final isHidden = lib.hiddenPaths.contains(video.path);
    final isFav = lib.isFavorite(video.path);

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(video.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
              ),
              const Divider(height: 1),
              _sheetTile(
                  icon: Icons.play_arrow_rounded,
                  title: t.playVideo,
                  iconBg: cs.primaryContainer,
                  iconColor: cs.onPrimaryContainer,
                  onTap: () { Navigator.pop(context); _openPlayer(video); }),
              _sheetTile(
                  icon: Icons.info_rounded,
                  title: t.videoInfo,
                  iconBg: cs.secondaryContainer,
                  iconColor: cs.onSecondaryContainer,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => InfoScreen(video: video)));
                  }),
              const Divider(height: 1),
              _sheetTile(
                  icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  title: isFav ? t.removeFromFavorites : t.addToFavorites,
                  iconBg: cs.tertiaryContainer,
                  iconColor: cs.onTertiaryContainer,
                  onTap: () { Navigator.pop(context); lib.toggleFavorite(video.path); }),
              _sheetTile(
                  icon: lib.isInPlaylist(video.path)
                      ? Icons.playlist_add_check_rounded
                      : Icons.playlist_add_rounded,
                  title: lib.isInPlaylist(video.path) ? t.alreadyInPlaylist : t.addToPlaylist,
                  iconBg: cs.tertiaryContainer,
                  iconColor: cs.onTertiaryContainer,
                  onTap: () async {
                    Navigator.pop(context);
                    final added = await lib.addToPlaylist(video.path);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(added ? t.addedToPlaylist : t.alreadyInPlaylistToast)));
                    }
                  }),
              _sheetTile(
                  icon: Icons.drive_file_rename_outline_rounded,
                  title: t.renameFile,
                  iconBg: cs.surfaceContainerHighest,
                  iconColor: cs.onSurfaceVariant,
                  onTap: () { Navigator.pop(context); _renameFile(video); }),
              const Divider(height: 1),
              _sheetTile(
                  icon: Icons.share_rounded,
                  title: t.share,
                  iconBg: cs.tertiaryContainer,
                  iconColor: cs.onTertiaryContainer,
                  onTap: () {
                    Navigator.pop(context);
                    Share.shareXFiles([XFile(video.path)], subject: video.name);
                  }),
              _sheetTile(
                  icon: Icons.content_copy_rounded,
                  title: t.copyPath,
                  iconBg: cs.surfaceContainerHighest,
                  iconColor: cs.onSurfaceVariant,
                  onTap: () {
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: video.path));
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.pathCopiedToast)));
                  }),
              _sheetTile(
                  icon: Icons.folder_open_rounded,
                  title: t.openInFileManager,
                  iconBg: cs.surfaceContainerHighest,
                  iconColor: cs.onSurfaceVariant,
                  onTap: () { Navigator.pop(context); _openInFileManager(video); }),
              const Divider(height: 1),
              _sheetTile(
                  icon: isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  title: isHidden ? t.unhide : t.hide,
                  iconBg: isHidden ? cs.secondaryContainer : cs.errorContainer,
                  iconColor: isHidden ? cs.onSecondaryContainer : cs.onErrorContainer,
                  onTap: () {
                    Navigator.pop(context);
                    isHidden ? lib.unhideVideo(video.path) : lib.hideVideo(video.path);
                  }),
              _sheetTile(
                  icon: Icons.delete_rounded,
                  title: t.delete,
                  iconBg: cs.errorContainer,
                  iconColor: cs.onErrorContainer,
                  onTap: () { Navigator.pop(context); _confirmDeleteFile(video); }),
            ]),
          ),
        ),
      ),
    );
  }

  void _buildFolderOptionsSheet(String folderName, List<VideoItem> folderVideos) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final lib = context.read<LibraryProvider>();
    final totalSize = folderVideos.fold<int>(0, (s, v) => s + v.size);
    final sizeStr = totalSize < 1024 * 1024 * 1024
        ? '${(totalSize / (1024 * 1024)).toStringAsFixed(0)} MB'
        : '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    final allHidden = folderVideos.every((v) => lib.hiddenPaths.contains(v.path));
    final isFolderFav = lib.isFavorite(folderName);

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(children: [
                  Text(folderName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(t.folderVideosCount(folderVideos.length, sizeStr),
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
                ]),
              ),
              const Divider(height: 1),
              _sheetTile(
                  icon: Icons.play_arrow_rounded,
                  title: t.playAll,
                  iconBg: cs.primaryContainer,
                  iconColor: cs.onPrimaryContainer,
                  onTap: () {
                    Navigator.pop(context);
                    if (folderVideos.isNotEmpty) _openPlayer(folderVideos.first);
                  }),
              _sheetTile(
                  icon: Icons.shuffle_rounded,
                  title: t.shufflePlay,
                  iconBg: cs.tertiaryContainer,
                  iconColor: cs.onTertiaryContainer,
                  onTap: () {
                    Navigator.pop(context);
                    if (folderVideos.isNotEmpty) {
                      folderVideos.shuffle();
                      _openPlayer(folderVideos.first);
                    }
                  }),
              const Divider(height: 1),
              _sheetTile(
                  icon: isFolderFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  title: isFolderFav ? t.removeFromFavorites : t.addToFavorites,
                  iconBg: cs.tertiaryContainer,
                  iconColor: cs.onTertiaryContainer,
                  onTap: () { Navigator.pop(context); lib.toggleFavorite(folderName); }),
              const Divider(height: 1),
              _sheetTile(
                  icon: allHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  title: allHidden ? t.unhideAll : t.hideAll,
                  iconBg: cs.errorContainer,
                  iconColor: cs.onErrorContainer,
                  onTap: () {
                    Navigator.pop(context);
                    for (final v in folderVideos) {
                      allHidden ? lib.unhideVideo(v.path) : lib.hideVideo(v.path);
                    }
                  }),
              _sheetTile(
                  icon: Icons.delete_rounded,
                  title: t.deleteFolder,
                  iconBg: cs.errorContainer,
                  iconColor: cs.onErrorContainer,
                  onTap: () { Navigator.pop(context); _confirmDeleteFolder(folderVideos); }),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sheetTile({
    required IconData icon,
    required String title,
    Color? iconBg,
    Color? iconColor,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: iconBg ?? cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor ?? cs.onSurfaceVariant, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                color: enabled ? cs.onSurface : cs.onSurfaceVariant,
                fontSize: 14)),
        onTap: enabled
            ? onTap
            : () => ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(t.comingSoon))),
      ),
    );
  }

  void _renameFile(VideoItem video) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: video.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.renameDialogTitle),
        content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: t.newNameHint),
            autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != video.name) {
                try {
                  File(video.path).renameSync(
                      '${File(video.path).parent.path}/$newName.${video.extension}');
                  context.read<LibraryProvider>().scan();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.renameSuccess)));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.renameFailed(e.toString()))));
                }
              }
              Navigator.pop(ctx);
            },
            child: Text(t.okButton),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFile(VideoItem video) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteFileTitle),
        content: Text(t.deleteFileConfirm(video.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (File(video.path).existsSync()) {
                File(video.path).deleteSync();
                context.read<LibraryProvider>().scan();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.fileDeletedToast(video.name))));
              }
            },
            child: Text(t.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFolder(List<VideoItem> videos) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteFolderTitle),
        content: Text(t.deleteFolderConfirm(videos.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              for (final v in videos) {
                if (File(v.path).existsSync()) File(v.path).deleteSync();
              }
              context.read<LibraryProvider>().scan();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t.filesDeletedToast(videos.length))));
            },
            child: Text(t.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openInFileManager(VideoItem video) async {
    final t = AppLocalizations.of(context)!;
    final uri = Uri.parse('file://${File(video.path).parent.path}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.fileManagerError)));
    }
  }
}