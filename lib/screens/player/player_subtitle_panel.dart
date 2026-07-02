import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:media_kit/media_kit.dart';
import '../../providers/settings_provider.dart';
import '../../models/subtitle_settings.dart';

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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = context.watch<SettingsProvider>();
    final sub = s.subtitleSettings;

    final activeSubtitleName = widget.currentSubtitleTrack?.title ??
                               widget.currentSubtitleTrack?.language ??
                               'لا يوجد مسار نشط';

    return Directionality(
      textDirection: TextDirection.rtl,
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
                      const Text('الترجمة', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
              title: 'الترجمات المدمجة',
              subtitle: '${widget.subtitleTracks.length} مسارات',
              isOpen: _openSection == 1,
              onTap: () => _toggleSection(1),
              child: _buildEmbeddedTracksSection(cs),
            ),
          ],

          _IntegratedSectionTile(
            icon: Symbols.folder_open_rounded,
            title: 'الترجمات الخارجية',
            subtitle: widget.hasExternalSubtitle ? 'ملف خارجي' : 'لا يوجد',
            isOpen: _openSection == 2,
            onTap: () => _toggleSection(2),
            child: _buildExternalSubtitleSection(),
          ),

          _IntegratedSectionTile(
            icon: Symbols.palette_rounded,
            title: 'المظهر',
            subtitle: '${sub.fontSize.toInt()}px',
            isOpen: _openSection == 3,
            onTap: () => _toggleSection(3),
            child: _buildAppearanceSection(s, sub, cs),
          ),

          _IntegratedSectionTile(
            icon: Symbols.open_with_rounded,
            title: 'الموضع',
            subtitle: '${sub.bottomMargin.toInt()}px / ${sub.horizontalMargin.toInt()}px',
            isOpen: _openSection == 7,
            onTap: () => _toggleSection(7),
            child: _buildPositionSection(s, sub, cs),
          ),

          _IntegratedSectionTile(
            icon: Symbols.timeline_rounded,
            title: 'المزامنة',
            subtitle: '${widget.subtitleSync > 0 ? '+' : ''}${widget.subtitleSync.toStringAsFixed(1)}s',
            isOpen: _openSection == 4,
            onTap: () => _toggleSection(4),
            child: _buildSyncSection(cs),
          ),

          _IntegratedSectionTile(
            icon: Symbols.text_fields_rounded,
            title: 'الترميز',
            subtitle: s.subtitleEncoding,
            isOpen: _openSection == 5,
            onTap: () => _toggleSection(5),
            child: _buildEncodingSection(s),
          ),

          _IntegratedSectionTile(
            icon: Symbols.tune_rounded,
            title: 'خيارات متقدمة',
            subtitle: '',
            isOpen: _openSection == 6,
            onTap: () => _toggleSection(6),
            child: _buildAdvancedSection(s),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedTracksSection(ColorScheme cs) {
    return Column(
      children: widget.subtitleTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        final name = track.title ?? track.language ?? 'ترجمة ${index + 1}';
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

  Widget _buildExternalSubtitleSection() {
    return Column(children: [
      ListTile(
        dense: true,
        leading: const Icon(Symbols.folder_open_rounded, color: Colors.white70, size: 18),
        title: const Text('اختيار ملف ترجمة', style: TextStyle(color: Colors.white, fontSize: 13)),
        onTap: widget.onPickSubtitle,
      ),
      if (widget.hasExternalSubtitle)
        ListTile(
          dense: true,
          leading: const Icon(Symbols.close_rounded, color: Colors.redAccent, size: 18),
          title: const Text('إزالة الترجمة الخارجية', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
          onTap: widget.onRemoveExternal,
        ),
    ]);
  }

  Widget _buildAppearanceSection(SettingsProvider s, SubtitleSettings sub, ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider('حجم الخط', sub.fontSize, 12, 80, (v) => s.updateSubtitleSettings(sub.copyWith(fontSize: v)), cs),
      const SizedBox(height: 14),
      SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _fontList.length,
          itemBuilder: (_, i) {
            final (id, label, isGoogle) = _fontList[i];
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
                child: Text(label, style: TextStyle(color: sel ? cs.primary : Colors.white54, fontSize: 11)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 14),
      _ColorPickerRow(currentColor: sub.textColor, onColorChanged: (c) => s.updateSubtitleSettings(sub.copyWith(textColor: c))),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(child: Text('خلفية النص', style: TextStyle(color: Colors.white70, fontSize: 12))),
        Switch(
          value: sub.bgOpacity > 0,
          onChanged: (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v ? 0.65 : 0.0)),
          activeColor: cs.primary,
        ),
      ]),
      if (sub.bgOpacity > 0) ...[
        const SizedBox(height: 6),
        _ColorPickerRow(currentColor: sub.bgColor, onColorChanged: (c) => s.updateSubtitleSettings(sub.copyWith(bgColor: c))),
        const SizedBox(height: 6),
        _CompactSlider('شفافية الخلفية', sub.bgOpacity, 0.1, 1.0, (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v)), cs, display: (v) => '${(v * 100).toInt()}%'),
      ],
      const SizedBox(height: 14),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: const Text('خط مائل', style: TextStyle(color: Colors.white, fontSize: 13)),
        value: s.subtitleItalic,
        onChanged: s.setSubtitleItalic,
        activeColor: cs.primary,
      ),
    ]);
  }

  Widget _buildPositionSection(SettingsProvider s, SubtitleSettings sub, ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider('الارتفاع عن الأسفل', sub.bottomMargin, 0, 300, (v) => s.updateSubtitleSettings(sub.copyWith(bottomMargin: v)), cs, display: (v) => '${v.toInt()} px'),
      const SizedBox(height: 14),
      _CompactSlider('الهامش الأفقي', sub.horizontalMargin, 0, 120, (v) => s.updateSubtitleSettings(sub.copyWith(horizontalMargin: v)), cs, display: (v) => '${v.toInt()} px'),
    ]);
  }

  Widget _buildSyncSection(ColorScheme cs) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider('تأخير الترجمة', widget.subtitleSync, -5.0, 5.0, widget.onSyncChanged, cs,
          display: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)} ثانية'),
      const SizedBox(height: 6),
      Text('القيمة السالبة تُقدم الترجمة، والموجبة تؤخرها', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
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

  Widget _buildAdvancedSection(SettingsProvider s) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text('حفظ الإعدادات كافتراضية', style: TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: const Text('تنطبق على جميع الفيديوهات', style: TextStyle(color: Colors.white38, fontSize: 11)),
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
  const _ColorPickerRow({required this.currentColor, required this.onColorChanged});
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
          final picked = await showColorPickerDialog(context, currentColor, title: const Text('اختر لوناً', style: TextStyle(fontWeight: FontWeight.bold)));
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