import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../l10n/app_localizations.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/video_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lib = context.watch<LibraryProvider>();
    final currentVideoPath = context.watch<PlayerProvider>().currentVideo?.path;
    final videos = lib.allVideos
        .where((v) => lib.favoritePaths.contains(v.path))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.favoritesTitle),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: videos.isEmpty
          ? Center(child: Text(t.noFavoriteVideos))
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