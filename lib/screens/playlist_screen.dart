import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/video_card.dart';
import '../l10n/app_localizations.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lib = context.watch<LibraryProvider>();
    final currentVideoPath = context.watch<PlayerProvider>().currentVideo?.path;
    final playlist = lib.playlistById(playlistId);

    // القائمة قد تكون حُذفت (من شاشة أخرى مثلاً) بينما هاذي الشاشة مفتوحة.
    if (playlist == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: Text(t.emptyPlaylist)),
      );
    }

    final videos = playlist.videoPaths
        .map((path) => lib.allVideos.where((v) => v.path == path).firstOrNull)
        .whereType<VideoItem>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: videos.isEmpty
          ? Center(child: Text(t.emptyPlaylist))
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: videos.length,
              onReorder: (oldIndex, newIndex) {
                context.read<LibraryProvider>().reorderPlaylistItems(playlistId, oldIndex, newIndex);
              },
              itemBuilder: (context, i) => VideoCard(
                key: ValueKey(videos[i].path),
                video: videos[i],
                isPlaying: videos[i].path == currentVideoPath,
                onTap: () {
                  context.read<PlayerProvider>().openVideo(videos[i]);
                  Navigator.pop(context);
                },
                onMoreTap: () => _showItemOptions(context, videos[i]),
              ),
            ),
    );
  }

  void _showItemOptions(BuildContext context, VideoItem video) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Symbols.playlist_remove_rounded, color: Colors.red),
              title: Text(t.removeFromPlaylist, style: const TextStyle(color: Colors.red)),
              onTap: () {
                context.read<LibraryProvider>().removeFromPlaylist(playlistId, video.path);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
