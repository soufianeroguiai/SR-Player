import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/playlist.dart';
import '../providers/library_provider.dart';
import '../l10n/app_localizations.dart';
import 'playlist_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  void _createPlaylistDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.createPlaylistTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: t.newPlaylistNameHint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await context.read<LibraryProvider>().createPlaylist(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(t.okButton),
          ),
        ],
      ),
    );
  }

  void _renamePlaylistDialog(BuildContext context, Playlist playlist) {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.renamePlaylistTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: t.newPlaylistNameHint),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              await context.read<LibraryProvider>().renamePlaylist(playlist.id, name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(t.okButton),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlaylist(BuildContext context, Playlist playlist) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deletePlaylistTitle),
        content: Text(t.deletePlaylistConfirmMessage(playlist.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () async {
              await context.read<LibraryProvider>().deletePlaylist(playlist.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(t.delete, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final playlists = context.watch<LibraryProvider>().playlists;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.playlistLabel),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPlaylistDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(t.createNewPlaylistOption),
      ),
      body: playlists.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Symbols.queue_music_rounded, size: 56, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(t.noPlaylistsYetMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: playlists.length,
              itemBuilder: (_, i) {
                final pl = playlists[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Symbols.queue_music_rounded, color: cs.onPrimaryContainer),
                  ),
                  title: Text(pl.name),
                  subtitle: Text(t.fileCount(pl.videoPaths.length)),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(Symbols.more_vert_rounded, color: cs.onSurfaceVariant),
                    onSelected: (value) {
                      if (value == 'rename') _renamePlaylistDialog(context, pl);
                      if (value == 'delete') _confirmDeletePlaylist(context, pl);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'rename', child: Text(t.renamePlaylistTitle)),
                      PopupMenuItem(value: 'delete', child: Text(t.delete)),
                    ],
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PlaylistScreen(playlistId: pl.id))),
                );
              },
            ),
    );
  }
}
