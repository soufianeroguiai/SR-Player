import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';
import 'player_fit_mode.dart';

class PlayerSettingsPanel extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onCaptureScreenshot;
  final VoidCallback onToggleFit;
  final void Function(VideoFitMode mode)? onSetFitMode;
  final VideoFitMode fitMode;
  final VoidCallback onEnterPip;
  final VoidCallback onShowInfo;
  final VoidCallback? onSleepTimer;
  final VoidCallback? onShowSpeedPicker;
  final VoidCallback? onToggleRememberPosition;
  final VoidCallback? onOpenPlaylistEditor;
  final bool rememberPosition;
  final double currentSpeed;
  final String currentFitMode;
  final VoidCallback onClose;

  final Duration? repeatPointA;
  final Duration? repeatPointB;
  final VoidCallback? onSetRepeatA;
  final VoidCallback? onSetRepeatB;
  final VoidCallback? onClearRepeat;

  final bool showStats;
  final VoidCallback? onToggleStats;

  final List<Duration> bookmarks;
  final VoidCallback? onAddBookmark;
  final void Function(Duration)? onJumpToBookmark;
  final void Function(Duration)? onRemoveBookmark;

  const PlayerSettingsPanel({
    super.key,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onCaptureScreenshot,
    required this.onToggleFit,
    this.onSetFitMode,
    this.fitMode = VideoFitMode.contain,
    required this.onEnterPip,
    required this.onShowInfo,
    this.onSleepTimer,
    this.onShowSpeedPicker,
    this.onToggleRememberPosition,
    this.onOpenPlaylistEditor,
    this.rememberPosition = false,
    this.currentSpeed = 1.0,
    this.currentFitMode = 'احتواء',
    required this.onClose,
    this.repeatPointA,
    this.repeatPointB,
    this.onSetRepeatA,
    this.onSetRepeatB,
    this.onClearRepeat,
    this.showStats = false,
    this.onToggleStats,
    this.bookmarks = const [],
    this.onAddBookmark,
    this.onJumpToBookmark,
    this.onRemoveBookmark,
  });

  @override
  State<PlayerSettingsPanel> createState() => _PlayerSettingsPanelState();
}

class _PlayerSettingsPanelState extends State<PlayerSettingsPanel> {
  int _openSection = -1;

  void _toggleSection(int index) {
    setState(() {
      _openSection = _openSection == index ? -1 : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = context.watch<SettingsProvider>();
    final t = AppLocalizations.of(context)!;

    String loopModeText() {
      switch (s.loopMode) {
        case 'video': return t.repeatVideo;
        case 'playlist': return t.repeatPlaylist;
        default: return t.repeatOff;
      }
    }
    String fitModeText() {
      switch (widget.fitMode) {
        case VideoFitMode.cover: return t.cover;
        case VideoFitMode.fill: return t.fill;
        case VideoFitMode.stretch: return t.stretch;
        case VideoFitMode.free: return t.free;
        default: return t.contain;
      }
    }
    String repeatABSubtitle() {
      if (widget.repeatPointA == null) return t.repeatABDisabled;
      if (widget.repeatPointB == null) return t.repeatABSetA;
      return t.repeatABActive;
    }

    return Directionality(
      // بقيت الواجهة بنفس الجهة دائماً (بلا مرآة)، مطابقة لباقي شاشة المشغل.
      textDirection: TextDirection.ltr,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (widget.onOpenPlaylistEditor != null) ...[
            _QuickActionTile(
              icon: Symbols.queue_music_rounded,
              title: t.playlistEditor,
              onTap: widget.onOpenPlaylistEditor!,
            ),
            const SizedBox(height: 4),
          ],
          _QuickActionTile(icon: Symbols.favorite_rounded, title: widget.isFavorite ? t.removeFromFavorites : t.addToFavorites, iconColor: widget.isFavorite ? Colors.amber : Colors.white70, onTap: widget.onToggleFavorite),
          const SizedBox(height: 4),
          _QuickActionTile(icon: Symbols.playlist_add_rounded, title: t.addToPlaylist, onTap: widget.onAddToPlaylist),
          const SizedBox(height: 4),
          _QuickActionTile(icon: Symbols.camera_rounded, title: t.screenshot, onTap: widget.onCaptureScreenshot),
          const SizedBox(height: 8),

          _QuickActionTile(
            icon: Symbols.repeat_rounded,
            title: loopModeText(),
            iconColor: s.loopMode != 'none' ? Colors.amber : Colors.white70,
            onTap: () {
              if (s.loopMode == 'none') {
                s.setLoopMode('video');
              } else if (s.loopMode == 'video') {
                s.setLoopMode('playlist');
              } else {
                s.setLoopMode('none');
              }
            },
          ),
          const SizedBox(height: 4),

          _QuickActionTile(
            icon: Symbols.screen_lock_landscape_rounded,
            title: s.preventScreenLock ? t.screenLockDisabled : t.screenLockEnabled,
            iconColor: s.preventScreenLock ? Colors.amber : Colors.white70,
            onTap: () => s.setPreventScreenLock(!s.preventScreenLock),
          ),
          const SizedBox(height: 4),

          if (widget.onToggleStats != null)
            _QuickActionTile(
              icon: Symbols.info_rounded,
              title: widget.showStats ? t.hideVideoInfo : t.showVideoInfo,
              iconColor: widget.showStats ? Colors.amber : Colors.white70,
              onTap: widget.onToggleStats!,
            ),

          const SizedBox(height: 8),

          _IntegratedSectionTile(
            icon: Symbols.aspect_ratio_rounded,
            title: t.aspectRatio,
            subtitle: fitModeText(),
            isOpen: _openSection == 1,
            onTap: () => _toggleSection(1),
            child: Column(children: [
              _SimpleTile(Icons.fit_screen_rounded, t.contain, widget.fitMode == VideoFitMode.contain, () => _pickFit(VideoFitMode.contain)),
              _SimpleTile(Icons.fullscreen_rounded, t.cover, widget.fitMode == VideoFitMode.cover, () => _pickFit(VideoFitMode.cover)),
              _SimpleTile(Icons.aspect_ratio_rounded, t.fill, widget.fitMode == VideoFitMode.fill, () => _pickFit(VideoFitMode.fill)),
              _SimpleTile(Icons.zoom_out_map_rounded, t.stretch, widget.fitMode == VideoFitMode.stretch, () => _pickFit(VideoFitMode.stretch)),
              _SimpleTile(Icons.open_with_rounded, t.free, widget.fitMode == VideoFitMode.free, () => _pickFit(VideoFitMode.free)),
            ]),
          ),
          const SizedBox(height: 4),

          _QuickActionTile(icon: Symbols.picture_in_picture_rounded, title: t.pip, onTap: widget.onEnterPip),
          const SizedBox(height: 4),
          if (widget.onSleepTimer != null) ...[
            _QuickActionTile(icon: Symbols.bedtime_rounded, title: t.sleepTimer, onTap: widget.onSleepTimer!),
            const SizedBox(height: 4),
          ],
          _QuickActionTile(icon: Symbols.info_rounded, title: t.videoInfo, onTap: widget.onShowInfo),
          const SizedBox(height: 8),

          if (widget.onSetRepeatA != null) ...[
            _IntegratedSectionTile(
              icon: Icons.repeat_rounded,
              title: t.repeatAB,
              subtitle: repeatABSubtitle(),
              isOpen: _openSection == 3,
              onTap: () => _toggleSection(3),
              child: Column(children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.flag_rounded, color: Colors.white70, size: 20),
                  title: Text(
                    widget.repeatPointA == null ? t.setPointA : t.resetPointA,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  onTap: widget.onSetRepeatA,
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.sports_score_rounded, color: Colors.white70, size: 20),
                  title: Text(t.setPointB, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  enabled: widget.repeatPointA != null,
                  onTap: widget.onSetRepeatB,
                ),
                if (widget.repeatPointA != null)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                    title: Text(t.cancelRepeat, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    onTap: widget.onClearRepeat,
                  ),
              ]),
            ),
            const SizedBox(height: 4),
          ],

          if (widget.onAddBookmark != null) ...[
            _IntegratedSectionTile(
              icon: Icons.bookmark_rounded,
              title: t.bookmarks,
              subtitle: widget.bookmarks.isEmpty ? '' : '${widget.bookmarks.length}',
              isOpen: _openSection == 4,
              onTap: () => _toggleSection(4),
              child: Column(children: [
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.add_rounded, color: Colors.white70, size: 20),
                  title: Text(t.addBookmark, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: widget.onAddBookmark,
                ),
                if (widget.bookmarks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(t.noBookmarks, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  )
                else
                  ...widget.bookmarks.map((d) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.play_circle_rounded, color: Colors.white70, size: 20),
                        title: Text(_fmtDuration(d), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 18),
                          onPressed: widget.onRemoveBookmark == null ? null : () => widget.onRemoveBookmark!(d),
                        ),
                        onTap: widget.onJumpToBookmark == null ? null : () => widget.onJumpToBookmark!(d),
                      )),
              ]),
            ),
            const SizedBox(height: 8),
          ],

          _IntegratedSectionTile(
            icon: Symbols.settings_rounded,
            title: t.playerSettings,
            subtitle: '',
            isOpen: _openSection == 2,
            onTap: () => _toggleSection(2),
            child: Column(children: [
              if (widget.onShowSpeedPicker != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Symbols.speed_rounded, color: Colors.white70, size: 20),
                  title: Text(t.playbackSpeedWithValue(widget.currentSpeed), style: const TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: widget.onShowSpeedPicker!,
                ),
              if (widget.onToggleRememberPosition != null)
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.rememberPosition, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  value: widget.rememberPosition,
                  onChanged: (_) => widget.onToggleRememberPosition!(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              if (widget.onToggleStats != null)
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.statsForNerds, style: const TextStyle(color: Colors.white, fontSize: 13)),
                  value: widget.showStats,
                  onChanged: (_) => widget.onToggleStats!(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
            ]),
          ),
        ],
      ),
    );
  }

  void _pickFit(VideoFitMode mode) {
    if (widget.onSetFitMode != null) {
      widget.onSetFitMode!(mode);
    } else {
      widget.onToggleFit();
    }
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final VoidCallback onTap;
  const _QuickActionTile({required this.icon, required this.title, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: iconColor ?? Colors.white70, size: 20),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        onTap: onTap,
      ),
    );
  }
}

class _SimpleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _SimpleTile(this.icon, this.title, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : Colors.white70, size: 20),
      title: Text(title, style: TextStyle(color: selected ? Theme.of(context).colorScheme.primary : Colors.white, fontSize: 13)),
      trailing: selected ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary, size: 18) : null,
      onTap: onTap,
    );
  }
}

class _IntegratedSectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isOpen;
  final VoidCallback onTap;
  final Widget child;
  const _IntegratedSectionTile({required this.icon, required this.title, required this.subtitle, required this.isOpen, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isOpen ? Colors.black.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOpen ? cs.primary.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08), width: isOpen ? 1.5 : 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        InkWell(
          borderRadius: isOpen ? const BorderRadius.vertical(top: Radius.circular(14)) : BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isOpen ? cs.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 18, color: isOpen ? cs.primary : Colors.white70)),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(color: isOpen ? Colors.white : Colors.white70, fontSize: 14, fontWeight: isOpen ? FontWeight.bold : FontWeight.w600))),
              if (subtitle.isNotEmpty) ...[
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(width: 8),
              ],
              Icon(isOpen ? Symbols.expand_less_rounded : Symbols.expand_more_rounded, color: isOpen ? cs.primary : Colors.white54, size: 22),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: isOpen ? Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 12), child: child) : const SizedBox.shrink(),
        ),
      ]),
    );
  }
}