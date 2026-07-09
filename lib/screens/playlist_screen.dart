import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/video_card.dart';
import '../l10n/app_localizations.dart';

class PlaylistScreen extends StatelessWidget {
  final List<String> playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lib = context.watch<LibraryProvider>();
    final videos = playlist
        .map((path) => lib.allVideos.where((v) => v.path == path).firstOrNull)
        .whereType<VideoItem>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.playlistTitle),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: videos.isEmpty
          ? Center(child: Text(t.emptyPlaylist))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: videos.length,
              itemBuilder: (_, i) => VideoCard(
                video: videos[i],
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