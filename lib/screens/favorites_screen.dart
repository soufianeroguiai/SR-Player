import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/video_item.dart';
import '../providers/library_provider.dart';
import '../widgets/video_card.dart';
import 'player/player_screen.dart';

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
    // الودجت يمكن يكون تفك (unmounted) خلال انتظار SharedPreferences
    // (مثلاً المستخدم رجع للخلف بسرعة).
    if (!mounted) return;
    setState(() => _favorites = favs);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lib = context.watch<LibraryProvider>();
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
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => PlayerScreen(video: videos[i]))),
                onMoreTap: null,
              ),
            ),
    );
  }
}