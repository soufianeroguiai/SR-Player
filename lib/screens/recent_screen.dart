import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/video_card.dart';
import '../l10n/app_localizations.dart';

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  List<VideoItem> _resolve(LibraryProvider lib) {
    final map = {for (final v in lib.allVideos) v.path: v};
    return lib.recentPaths
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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final lib = context.watch<LibraryProvider>();
    final currentVideoPath = context.watch<PlayerProvider>().currentVideo?.path;
    final videos = _resolve(lib);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.queueLabel),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (videos.isNotEmpty)
            IconButton(
              icon: Icon(Symbols.delete_sweep_rounded, color: cs.error),
              tooltip: t.clear,
              onPressed: () => context.read<LibraryProvider>().clearRecent(),
            ),
        ],
      ),
      body: videos.isEmpty
          ? Center(child: Text(t.noRecentVideos))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: videos.length,
              itemBuilder: (_, i) => VideoCard(
                video: videos[i],
                isPlaying: videos[i].path == currentVideoPath,
                onTap: () {
                  context.read<PlayerProvider>().openVideo(videos[i]);
                  Navigator.pop(context);
                },
                onMoreTap: null,
              ),
            ),
    );
  }
}
