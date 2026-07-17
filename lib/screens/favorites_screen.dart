import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';  // تم التصحيح إلى l10n
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/video_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final p = await SharedPreferences.getInstance();
    final favs = p.getStringList('favorite_paths') ?? [];
    if (!mounted) return;
    setState(() => _favorites = favs);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lib = context.watch<LibraryProvider>();
    final currentVideoPath = context.watch<PlayerProvider>().currentVideo?.path;
    final videos = lib.allVideos.where((v) => _favorites.contains(v.path)).toList();

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
                  // نفتح الفيديو عبر PlayerProvider بدل Navigator.push حتى يُعرض
                  // المشغّل داخل نفس Stack الخاص بـ RootScreen (وليس كـ Route منفصل).
                  // هذا ضروري لكي تعمل ميزة التصغير/PiP وزر الرجوع بشكل صحيح،
                  // لأن منطق التصغير في PlayerScreen يفترض عدم وجود Route مضغوط فوقه.
                  context.read<PlayerProvider>().openVideo(videos[i]);
                  Navigator.pop(context);
                },
                onMoreTap: null,
              ),
            ),
    );
  }
}