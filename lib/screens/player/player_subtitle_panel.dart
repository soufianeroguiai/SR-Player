import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:media_kit/media_kit.dart';
import '../../providers/settings_provider.dart';
import '../../models/subtitle_settings.dart';
import '../../l10n/app_localizations.dart';
import '../../services/online_subtitle_service.dart';

class SubtitleAppearancePanel extends StatefulWidget {
  final List<SubtitleTrack> subtitleTracks;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack) onTrackSelected;
  final VoidCallback onPickSubtitle;
  final VoidCallback onRemoveExternal;
  final bool hasExternalSubtitle;
  final bool showSubtitles;
  final ValueChanged<bool> onToggleSubtitles;
  final double subtitleSync;
  final ValueChanged<double> onSyncChanged;
  final String videoName;
  final void Function(String path, String encoding) onLoadSrt;

  const SubtitleAppearancePanel({
    super.key,
    required this.subtitleTracks,
    required this.currentSubtitleTrack,
    required this.onTrackSelected,
    required this.onPickSubtitle,
    required this.onRemoveExternal,
    required this.hasExternalSubtitle,
    required this.showSubtitles,
    required this.onToggleSubtitles,
    required this.subtitleSync,
    required this.onSyncChanged,
    required this.videoName,
    required this.onLoadSrt,
  });

  @override
  State<SubtitleAppearancePanel> createState() => _SubtitleAppearancePanelState();
}

class _SubtitleAppearancePanelState extends State<SubtitleAppearancePanel> {
  int _openSection = -1;

  static const _fontList = [
    ('sans-serif', 'System Default', false),
    ('Roboto', 'Roboto', false),
    ('monospace', 'Monospace', false),
    ('Cairo', 'Cairo', true),
    ('Amiri', 'Amiri', true),
    ('Noto Naskh Arabic', 'Noto Naskh', true),
    ('Noto Kufi Arabic', 'Noto Kufi', true),
    ('Lateef', 'Lateef', true),
    ('Tajawal', 'Tajawal', true),
    ('Scheherazade New', 'Scheherazade', true),
  ];

  void _toggleSection(int index) {
    setState(() {
      _openSection = _openSection == index ? -1 : index;
    });
  }

  Future<void> _showOnlineSearch(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final service = OpenSubtitlesService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: FutureBuilder<List<SubtitleResult>>(
          future: service.search(query: widget.videoName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(t.noSubtitlesFound));
            }
            final results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final item = results[i];
                return ListTile(
                  title: Text(item.fileName),
                  subtitle: Text('${item.language}  ★ ${item.rating}'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final file = await service.download(item.downloadUrl, '${item.id}.srt');
                      widget.onLoadSrt(file.path, 'UTF-8');
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.downloadFailed(e.toString()))),
                        );
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = context.watch<SettingsProvider>();
    final sub = s.subtitleSettings;
    final t = AppLocalizations.of(context)!;

    final activeSubtitleName = widget.currentSubtitleTrack?.title ??
                               widget.currentSubtitleTrack?.language ??
                               t.noActiveTrack;

    return Directionality(
      textDirection: Directionality.of(context),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Symbols.subtitles_rounded, size: 18, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.subtitleLabel, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (widget.showSubtitles && widget.currentSubtitleTrack != null)
                        Text(activeSubtitleName, style: TextStyle(color: cs.primary, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: widget.showSubtitles,
                  onChanged: widget.onToggleSubtitles,
                  activeColor: cs.primary,
                ),
              ],
            ),
          ),

          if (widget.subtitleTracks.isNotEmpty) ...[
            _IntegratedSectionTile(
              icon: Symbols.video_file_rounded,
              title: t.embeddedSubtitles,
              subtitle: t.embeddedSubtitlesCount(widget.subtitleTracks.length),
              isOpen: _openSection == 1,
              onTap: () => _toggleSection(1),
              child: _buildEmbeddedTracksSection(cs, t),
            ),
          ],

          _IntegratedSectionTile(
            icon: Symbols.folder_open_rounded,
            title: t.externalSubtitles,
            subtitle: widget.hasExternalSubtitle ? t.externalFile : t.none,
            isOpen: _openSection == 2,
            onTap: () => _toggleSection(2),
            child: _buildExternalSubtitleSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.palette_rounded,
            title: t.appearance,
            subtitle: '${sub.fontSize.toInt()}px',
            isOpen: _openSection == 3,
            onTap: () => _toggleSection(3),
            child: _buildAppearanceSection(s, sub, cs, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.open_with_rounded,
            title: t.position,
            subtitle: '${sub.bottomMargin.toInt()}px / ${sub.horizontalMargin.toInt()}px',
            isOpen: _openSection == 7,
            onTap: () => _toggleSection(7),
            child: _buildPositionSection(s, sub, cs, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.timeline_rounded,
            title: t.sync,
            subtitle: '${widget.subtitleSync > 0 ? '+' : ''}${widget.subtitleSync.toStringAsFixed(1)}s',
            isOpen: _openSection == 4,
            onTap: () => _toggleSection(4),
            child: _buildSyncSection(cs, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.text_fields_rounded,
            title: t.encoding,
            subtitle: s.subtitleEncoding,
            isOpen: _openSection == 5,
            onTap: () => _toggleSection(5),
            child: _buildEncodingSection(s),
          ),

          _IntegratedSectionTile(
            icon: Symbols.tune_rounded,
            title: t.advancedOptions,
            subtitle: '',
            isOpen: _openSection == 6,
            onTap: () => _toggleSection(6),
            child: _buildAdvancedSection(s, t),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedTracksSection(ColorScheme cs, AppLocalizations t) {
    return Column(
      children: widget.subtitleTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        final name = track.title ?? track.language ?? t.subtitleTrackNumber(index + 1);
        final isActive = widget.currentSubtitleTrack == track;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(name, style: TextStyle(color: isActive ? cs.primary : Colors.white, fontSize: 13)),
          trailing: isActive ? Icon(Symbols.check_rounded, color: cs.primary, size: 18) : null,
          onTap: () => widget.onTrackSelected(track),
        );
      }).toList(),
    );
  }

  Widget _buildExternalSubtitleSection(AppLocalizations t) {
    return Column(children: [
      ListTile(
        dense: true,
        leading: const Icon(Symbols.folder_open_rounded, color: Colors.white70, size: 18),
        title: Text(t.pickSubtitleFile, style: const TextStyle(color: Colors.white, fontSize: 13)),
        onTap: widget.onPickSubtitle,
      ),
      ListTile(
        dense: true,
        leading: const Icon(Icons.cloud_download_rounded, color: Colors.white70, size: 18),
        title: Text(t.searchOnlineSubtitles, style: const TextStyle(color: Colors.white, fontSize: 13)),
        onTap: () => _showOnlineSearch(context),
      ),
      if (widget.hasExternalSubtitle)
        ListTile(
          dense: true,
          leading: const Icon(Symbols.close_rounded, color: Colors.redAccent, size: 18),
          title: Text(t.removeExternalSubtitle, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          onTap: widget.onRemoveExternal,
        ),
    ]);
  }

  Widget _buildAppearanceSection(SettingsProvider s, SubtitleSettings sub, ColorScheme cs, AppLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(t.fontSize, sub.fontSize, 12, 80, (v) => s.updateSubtitleSettings(sub.copyWith(fontSize: v)), cs),
      const SizedBox(height: 14),
      SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _fontList.length,
          itemBuilder: (_, i) {
            final (id, label, isGoogle) = _fontList[i];
            final displayLabel = label == 'System Default' ? t.systemDefaultFont : label;
            final sel = sub.fontFamily == id;
            return GestureDetector(
              onTap: () => s.updateSubtitleSettings(sub.copyWith(fontFamily: id)),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? cs.primary.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sel ? cs.primary : Colors.white24, width: sel ? 1.5 : 1),
                ),
                child: Text(displayLabel, style: TextStyle(color: sel ? cs.primary : Colors.white54, fontSize: 11)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      _ColorPickerRow(currentColor: sub.textColor, onColorChanged: (c) => s.updateSubtitleSettings(sub.copyWith(textColor: c)), t: t),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: Text(t.textBackground, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        Switch(
          value: sub.bgOpacity > 0,
          onChanged: (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v ? 0.65 : 0.0)),
          activeColor: cs.primary,
        ),
      ]),
      if (sub.bgOpacity > 0) ...[
        const SizedBox(height: 6),
        _ColorPickerRow(currentColor: sub.bgColor, onColorChanged: (c) => s.updateSubtitleSettings(sub.copyWith(bgColor: c)), t: t),
        const SizedBox(height: 6),
        _CompactSlider(t.backgroundOpacity, sub.bgOpacity, 0.1, 1.0, (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v)), cs, display: (v) => '${(v * 100).toInt()}%'),
      ],
      const SizedBox(height: 14),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.italic, style: const TextStyle(color: Colors.white, fontSize: 13)),
        value: s.subtitleItalic,
        onChanged: s.setSubtitleItalic,
        activeColor: cs.primary,
      ),
    ]);
  }

  Widget _buildPositionSection(SettingsProvider s, SubtitleSettings sub, ColorScheme cs, AppLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(t.bottomMargin, sub.bottomMargin, 0, 300, (v) => s.updateSubtitleSettings(sub.copyWith(bottomMargin: v)), cs, display: (v) => '${v.toInt()} px'),
      const SizedBox(height: 14),
      _CompactSlider(t.horizontalMargin, sub.horizontalMargin, 0, 120, (v) => s.updateSubtitleSettings(sub.copyWith(horizontalMargin: v)), cs, display: (v) => '${v.toInt()} px'),
    ]);
  }

  Widget _buildSyncSection(ColorScheme cs, AppLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(t.subtitleDelay, widget.subtitleSync, -5.0, 5.0, widget.onSyncChanged, cs,
          display: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} s'),
      const SizedBox(height: 6),
      Text(t.subtitleDelayHelp, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
    ]);
  }

  Widget _buildEncodingSection(SettingsProvider s) {
    const encodings = ['UTF-8', 'UTF-16', 'Windows-1256', 'ISO-8859-6'];
    return Column(
      children: encodings.map((enc) {
        final sel = s.subtitleEncoding == enc;
        return ListTile(
          dense: true,
          title: Text(enc, style: TextStyle(color: sel ? Theme.of(context).colorScheme.primary : Colors.white, fontSize: 13)),
          trailing: sel ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary, size: 18) : null,
          onTap: () => s.setSubtitleEncoding(enc),
        );
      }).toList(),
    );
  }

  Widget _buildAdvancedSection(SettingsProvider s, AppLocalizations t) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(t.saveAsDefault, style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: Text(t.saveAsDefaultDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      value: s.rememberPosition,
      onChanged: s.setRememberPosition,
      activeColor: Theme.of(context).colorScheme.primary,
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

class _CompactSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ColorScheme cs;
  final String Function(double)? display;
  const _CompactSlider(this.label, this.value, this.min, this.max, this.onChanged, this.cs, {this.display});

  @override
  Widget build(BuildContext context) {
    final displayed = display != null ? display!(value) : value.toStringAsFixed(1);
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6), activeTrackColor: cs.primary, inactiveTrackColor: Colors.white24, thumbColor: cs.primary),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(width: 50, child: Text(displayed, style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
      ],
    );
  }
}

class _ColorPickerRow extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  final AppLocalizations t;
  const _ColorPickerRow({required this.currentColor, required this.onColorChanged, required this.t});
  static const _colors = [Colors.white, Colors.yellow, Color(0xFFFFE680), Color(0xFF80FF80), Color(0xFF80D4FF), Color(0xFFFFB3B3)];
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ..._colors.map((c) => GestureDetector(
            onTap: () => onColorChanged(c),
            child: Container(
              margin: const EdgeInsets.only(right: 6), width: 28, height: 28,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle,
                  border: Border.all(color: currentColor.value == c.value ? Colors.white : Colors.white30, width: currentColor.value == c.value ? 2.5 : 1)),
            ),
          )),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: () async {
          final picked = await showColorPickerDialog(context, currentColor, title: Text(t.pickColor, style: const TextStyle(fontWeight: FontWeight.bold)));
          onColorChanged(picked);
        },
        child: Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white38),
              gradient: const SweepGradient(colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.purple, Colors.red])),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
        ),
      ),
    ]);
  }
}