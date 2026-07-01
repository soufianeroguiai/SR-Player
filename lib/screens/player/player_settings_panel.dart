// FILE: lib/screens/player/player_settings_panel.dart

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class PlayerSettingsPanel extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onCaptureScreenshot;
  final VoidCallback onToggleFit;
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

  const PlayerSettingsPanel({
    super.key,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToPlaylist,
    required this.onCaptureScreenshot,
    required this.onToggleFit,
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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (widget.onOpenPlaylistEditor != null) ...[
            _QuickActionTile(
              icon: Symbols.queue_music_rounded,
              title: 'قوائم التشغيل',
              onTap: widget.onOpenPlaylistEditor!,
            ),
            const SizedBox(height: 4),
          ],
          _QuickActionTile(icon: Symbols.favorite_rounded, title: widget.isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة', iconColor: widget.isFavorite ? Colors.amber : Colors.white70, onTap: widget.onToggleFavorite),
          const SizedBox(height: 4),
          _QuickActionTile(icon: Symbols.playlist_add_rounded, title: 'إضافة إلى قائمة التشغيل', onTap: widget.onAddToPlaylist),
          const SizedBox(height: 4),
          _QuickActionTile(icon: Symbols.camera_rounded, title: 'لقطة شاشة', onTap: widget.onCaptureScreenshot),
          const SizedBox(height: 8),

          _IntegratedSectionTile(
            icon: Symbols.aspect_ratio_rounded,
            title: 'نسبة العرض',
            subtitle: widget.currentFitMode,
            isOpen: _openSection == 1,
            onTap: () => _toggleSection(1),
            child: Column(children: [
              _SimpleTile(Icons.fit_screen_rounded, 'احتواء', widget.currentFitMode == 'احتواء', () { widget.onToggleFit(); _toggleSection(1); }),
              _SimpleTile(Icons.fullscreen_rounded, 'تغطية', widget.currentFitMode == 'تغطية', () { widget.onToggleFit(); _toggleSection(1); }),
              _SimpleTile(Icons.zoom_out_map_rounded, 'تمديد', widget.currentFitMode == 'تمديد', () { widget.onToggleFit(); _toggleSection(1); }),
            ]),
          ),
          const SizedBox(height: 4),

          _QuickActionTile(icon: Symbols.picture_in_picture_rounded, title: 'نافذة عائمة (PiP)', onTap: widget.onEnterPip),
          const SizedBox(height: 4),
          if (widget.onSleepTimer != null) ...[
            _QuickActionTile(icon: Symbols.bedtime_rounded, title: 'مؤقت النوم', onTap: widget.onSleepTimer!),
            const SizedBox(height: 4),
          ],
          _QuickActionTile(icon: Symbols.info_rounded, title: 'معلومات الفيديو', onTap: widget.onShowInfo),
          const SizedBox(height: 8),

          _IntegratedSectionTile(
            icon: Symbols.settings_rounded,
            title: 'إعدادات المشغل',
            subtitle: '',
            isOpen: _openSection == 2,
            onTap: () => _toggleSection(2),
            child: Column(children: [
              if (widget.onShowSpeedPicker != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Symbols.speed_rounded, color: Colors.white70, size: 20),
                  title: Text('سرعة التشغيل (${widget.currentSpeed}x)', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: widget.onShowSpeedPicker!,
                ),
              if (widget.onToggleRememberPosition != null)
                SwitchListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('تذكر موضع التشغيل', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: widget.rememberPosition,
                  onChanged: (_) => widget.onToggleRememberPosition!(),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
            ]),
          ),
        ],
      ),
    );
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
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
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
        color: isOpen ? Colors.black.withOpacity(0.8) : Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOpen ? cs.primary.withOpacity(0.6) : Colors.white.withOpacity(0.08), width: isOpen ? 1.5 : 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        InkWell(
          borderRadius: isOpen ? const BorderRadius.vertical(top: Radius.circular(14)) : BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isOpen ? cs.primary.withOpacity(0.2) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
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