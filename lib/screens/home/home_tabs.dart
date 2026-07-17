import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../l10n/app_localizations.dart';
import '../../models/video_item.dart';
import '../../providers/library_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/video_card.dart';

class LibraryTab extends StatelessWidget {
  final List<VideoItem> videos;
  final bool gridView;
  final void Function(VideoItem) onOpen;
  final void Function(VideoItem) onMore;
  final bool loading;
  final Set<VideoItem> selectedVideos;
  final void Function(VideoItem) onSelectionToggle;
  final AppLocalizations t;
  final LibraryError errorType;
  final VoidCallback? onRetry;

  const LibraryTab({
    super.key,
    required this.videos,
    required this.gridView,
    required this.onOpen,
    required this.onMore,
    this.loading = false,
    this.selectedVideos = const {},
    required this.onSelectionToggle,
    required this.t,
    this.errorType = LibraryError.none,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && videos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    // نعرض رسالة الخطأ الفعلي (إذن مرفوض أو فشل المسح) بدل الرسالة العامة
    // "ماكايناش فيديوهات" التي كانت تظهر فهاذ الحالات وتُخفي السبب الحقيقي.
    if (videos.isEmpty && errorType != LibraryError.none) {
      final isPermission = errorType == LibraryError.permissionDenied;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPermission ? Symbols.no_photography_rounded : Symbols.error_outline_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                isPermission ? t.permissionsRequiredBody : t.scanFailedMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Symbols.refresh_rounded),
                label: Text(isPermission ? t.grantPermissionsButton : t.retryButton),
              ),
            ],
          ),
        ),
      );
    }
    if (videos.isEmpty) {
      return EmptyState(t.noVideosFound, Symbols.video_library_rounded, t);
    }

    final bool selectionMode = selectedVideos.isNotEmpty;
    final currentVideoPath = context.watch<PlayerProvider>().currentVideo?.path;

    return gridView
        ? GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: videos.length,
            itemBuilder: (_, i) {
              final v = videos[i];
              return VideoGridCard(
                video: v,
                isSelected: selectedVideos.contains(v),
                isPlaying: v.path == currentVideoPath,
                onTap: selectionMode ? () => onSelectionToggle(v) : () => onOpen(v),
                onMoreTap: () => onMore(v),
                onLongPress: () => onSelectionToggle(v),
              );
            })
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 90),
            itemCount: videos.length,
            itemBuilder: (_, i) {
              final v = videos[i];
              return VideoCard(
                video: v,
                isSelected: selectedVideos.contains(v),
                isPlaying: v.path == currentVideoPath,
                onTap: selectionMode ? () => onSelectionToggle(v) : () => onOpen(v),
                onMoreTap: () => onMore(v),
                onLongPress: () => onSelectionToggle(v),
              );
            });
  }
}

class RecentTab extends StatelessWidget {
  final List<String> paths;
  final List<VideoItem> all;
  final bool gridView;
  final void Function(String) onOpen;
  final VoidCallback onClear;
  final Set<VideoItem> selectedVideos;
  final void Function(VideoItem) onSelectionToggle;
  final AppLocalizations t;

  const RecentTab({
    super.key,
    required this.paths,
    required this.all,
    required this.gridView,
    required this.onOpen,
    required this.onClear,
    this.selectedVideos = const {},
    required this.onSelectionToggle,
    required this.t,
  });

  List<VideoItem> get list {
    final map = {for (final v in all) v.path: v};
    return paths
        .map((p) {
          if (map.containsKey(p)) return map[p]!;
          try {
            if (!File(p).existsSync()) return null;
            final stat = File(p).statSync();
            return VideoItem.fromPath(path: p, size: stat.size, modified: stat.modified);
          } catch (_) {
            return null;
          }
        })
        .whereType<VideoItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = list;
    if (items.isEmpty) return EmptyState(t.noRecentVideos, Symbols.history_rounded, t);

    final bool selectionMode = selectedVideos.isNotEmpty;
    final currentVideoPath = context.watch<PlayerProvider>().currentVideo?.path;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 4),
        child: Row(children: [
          Icon(Symbols.history_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(t.fileCount(items.length), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const Spacer(),
          TextButton.icon(
              onPressed: onClear,
              icon: Icon(Symbols.delete_sweep_rounded, size: 16, color: cs.error),
              label: Text(t.clear, style: const TextStyle(color: Colors.red, fontSize: 12)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10))),
        ]),
      ),
      Expanded(
        child: gridView
            ? GridView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.78, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final v = items[i];
                  return VideoGridCard(
                    video: v,
                    isSelected: selectedVideos.contains(v),
                    isPlaying: v.path == currentVideoPath,
                    onTap: selectionMode ? () => onSelectionToggle(v) : () => onOpen(v.path),
                    onLongPress: () => onSelectionToggle(v),
                  );
                })
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final v = items[i];
                  return VideoCard(
                    video: v,
                    isSelected: selectedVideos.contains(v),
                    isPlaying: v.path == currentVideoPath,
                    onTap: selectionMode ? () => onSelectionToggle(v) : () => onOpen(v.path),
                    onLongPress: () => onSelectionToggle(v),
                  );
                }),
      ),
    ]);
  }
}

class FoldersTab extends StatelessWidget {
  final Map<String, List<VideoItem>> byFolder;
  final void Function(String) onTap;
  final void Function(String folderName, List<VideoItem> videos)? onMore;
  final bool gridView;
  final AppLocalizations t;

  const FoldersTab({
    super.key,
    required this.byFolder,
    required this.onTap,
    this.onMore,
    this.gridView = false,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keys = byFolder.keys.toList()..sort();
    if (keys.isEmpty) return EmptyState(t.noFoldersFound, Symbols.folder_off_rounded, t);

    final children = keys.map((folder) {
      final videos = byFolder[folder]!;
      final total = videos.fold<int>(0, (s, v) => s + v.size);
      final size = total < 1024 * 1024 * 1024
          ? '${(total / (1024 * 1024)).toStringAsFixed(0)} MB'
          : '${(total / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';

      if (gridView) {
        return GestureDetector(
          onTap: () => onTap(folder),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onMore != null)
                        GestureDetector(
                          onTap: () => onMore!(folder, videos),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Symbols.more_vert_rounded, color: cs.onSurfaceVariant, size: 18),
                          ),
                        ),
                    ],
                  ),
                  Icon(Symbols.folder_rounded, color: cs.onSecondaryContainer, size: 48),
                  const SizedBox(height: 8),
                  Text(folder, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(t.folderVideoCount(videos.length, size), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                ],
              ),
            ),
          ),
        );
      } else {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(14)),
              child: Icon(Symbols.folder_rounded, color: cs.onSecondaryContainer, size: 28)),
          title: Text(folder, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 15)),
          subtitle: Text(t.folderVideoCount(videos.length, size), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          trailing: onMore != null
              ? IconButton(
                  icon: Icon(Symbols.more_vert_rounded, color: cs.onSurfaceVariant, size: 20),
                  onPressed: () => onMore!(folder, videos),
                )
              : null,
          onTap: () => onTap(folder),
        );
      }
    }).toList();

    if (gridView) {
      return GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        childAspectRatio: 1.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: children,
      );
    } else {
      return ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
        children: children,
      );
    }
  }
}

class EmptyState extends StatelessWidget {
  final String msg;
  final IconData icon;
  final AppLocalizations t;
  const EmptyState(this.msg, this.icon, this.t, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
            child: Icon(icon, size: 48, color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),
        Text(msg, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(t.openFileHint, style: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.6), fontSize: 13)),
      ]),
    );
  }
}