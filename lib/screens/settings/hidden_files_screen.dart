import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/library_provider.dart';
import '../../models/video_item.dart';
import '../../l10n/app_localizations.dart';

class HiddenFilesScreen extends StatelessWidget {
  const HiddenFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lib = context.watch<LibraryProvider>();
    final hiddenPaths = lib.hiddenPaths;
    final hiddenVideos = lib.allVideos
        .where((v) => hiddenPaths.contains(v.path))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.hiddenFilesTitle),
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (hiddenVideos.isNotEmpty)
            TextButton(
              onPressed: () => _confirmUnhideAll(context, lib, t),
              child: Text(t.showAll, style: TextStyle(color: cs.primary)),
            ),
        ],
      ),
      body: hiddenVideos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.visibility_off_rounded, size: 48, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(t.noHiddenFiles, style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: hiddenVideos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final VideoItem v = hiddenVideos[index];
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Symbols.video_file_rounded, color: cs.onSurfaceVariant, size: 22),
                    ),
                    title: Text(v.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(v.folder, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: TextButton(
                      onPressed: () => lib.unhideVideo(v.path),
                      child: Text(t.show),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmUnhideAll(BuildContext context, LibraryProvider lib, AppLocalizations t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.unhideAllConfirmTitle),
        content: Text(t.unhideAllConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          TextButton(
            onPressed: () {
              lib.clearHidden();
              Navigator.pop(ctx);
            },
            child: Text(t.showAll),
          ),
        ],
      ),
    );
  }
}