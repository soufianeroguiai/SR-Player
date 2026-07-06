import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/app_localizations.dart';

class AudioSettingsPanel extends StatefulWidget {
  final Player player;
  final double volumeLevel;
  final ValueChanged<double> onVolumeChanged;
  final List<AudioTrack> audioTracks;
  final AudioTrack? currentAudioTrack;
  final void Function(AudioTrack) onTrackSelected;
  final double audioDelay;
  final ValueChanged<double> onAudioDelayChanged;
  final VoidCallback onClose;

  const AudioSettingsPanel({
    super.key,
    required this.player,
    required this.volumeLevel,
    required this.onVolumeChanged,
    required this.audioTracks,
    required this.currentAudioTrack,
    required this.onTrackSelected,
    required this.audioDelay,
    required this.onAudioDelayChanged,
    required this.onClose,
  });

  @override
  State<AudioSettingsPanel> createState() => _AudioSettingsPanelState();
}

class _AudioSettingsPanelState extends State<AudioSettingsPanel> {
  int _openSection = -1;
  bool _muted = false;

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

    final activeAudioName = widget.currentAudioTrack?.title ??
                            widget.currentAudioTrack?.language ??
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
                  child: const Icon(Symbols.audiotrack_rounded, size: 18, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.audioLabel, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (widget.currentAudioTrack != null)
                        Text(activeAudioName, style: TextStyle(color: cs.primary, fontSize: 11)),
                    ],
                  ),
                ),
                _QuickIconBtn(
                  icon: _muted ? Symbols.volume_off_rounded : Symbols.volume_up_rounded,
                  color: _muted ? Colors.redAccent : Colors.white70,
                  onTap: () {
                    setState(() => _muted = !_muted);
                    widget.player.setVolume(_muted ? 0 : (widget.volumeLevel * 100.0));
                  },
                ),
              ],
            ),
          ),

          if (widget.audioTracks.isNotEmpty) ...[
            _IntegratedSectionTile(
              icon: Symbols.audiotrack_rounded,
              title: t.audioTracks,
              subtitle: t.audioTracksCount(widget.audioTracks.length),
              isOpen: _openSection == 0,
              onTap: () => _toggleSection(0),
              child: _buildAudioTrackSection(cs, t),
            ),
          ],

          _IntegratedSectionTile(
            icon: Symbols.volume_up_rounded,
            title: t.volumeLevel,
            subtitle: '${(widget.volumeLevel * 100).round()}%',
            isOpen: _openSection == 1,
            onTap: () => _toggleSection(1),
            child: _buildVolumeSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.equalizer_rounded,
            title: t.equalizerLabel,
            subtitle: s.bassBoost ? t.enabled : t.disabled,
            isOpen: _openSection == 4,
            onTap: () => _toggleSection(4),
            child: _buildEqualizerSection(cs, s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.timeline_rounded,
            title: t.audioSyncLabel,
            subtitle: '${widget.audioDelay > 0 ? '+' : ''}${widget.audioDelay.toStringAsFixed(0)} ms',
            isOpen: _openSection == 2,
            onTap: () => _toggleSection(2),
            child: _buildAudioSyncSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.info_rounded,
            title: t.audioInfo,
            subtitle: '',
            isOpen: _openSection == 3,
            onTap: () => _toggleSection(3),
            child: _buildAudioInfoSection(t),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioTrackSection(ColorScheme cs, AppLocalizations t) {
    return Column(
      children: widget.audioTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        final name = track.title ?? track.language ?? t.audioTrackNumber(index + 1);
        final isActive = widget.currentAudioTrack == track;
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

  Widget _buildVolumeSection(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(t.volumeLevel, widget.volumeLevel, 0.0, 2.0, widget.onVolumeChanged, cs, display: (v) => '${(v * 100).round()}%'),
      const SizedBox(height: 10),
      _CompactSlider(t.audioBoostOption, widget.volumeLevel.clamp(1.0, 2.0), 1.0, 2.0, (v) => widget.onVolumeChanged(v), cs, display: (v) => '${(v * 100).round()}%'),
      const SizedBox(height: 10),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.mute, style: const TextStyle(color: Colors.white, fontSize: 13)),
        value: _muted,
        onChanged: (v) {
          setState(() => _muted = v);
          widget.player.setVolume(v ? 0 : widget.volumeLevel * 100.0);
        },
        activeColor: cs.primary,
      ),
    ]);
  }

  Widget _buildEqualizerSection(ColorScheme cs, SettingsProvider s, AppLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.bassBoostLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.bassBoostDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.bassBoost,
        onChanged: (v) => s.setBassBoost(v),
        activeColor: cs.primary,
      ),
      const Divider(height: 1, color: Colors.white12),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.trebleBoostLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.trebleBoostDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.surroundSound,
        onChanged: (v) => s.setSurroundSound(v),
        activeColor: cs.primary,
      ),
      const Divider(height: 1, color: Colors.white12),
      ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.openGraphicEqualizer, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.bands10, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: const Icon(Symbols.chevron_right_rounded, color: Colors.white54, size: 20),
        onTap: () => _showEqualizerDialog(context, s, t),
      ),
    ]);
  }

  Widget _buildAudioSyncSection(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(t.audioDelay, widget.audioDelay, -500.0, 500.0, widget.onAudioDelayChanged, cs,
          display: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(0)} ms'),
      const SizedBox(height: 6),
      Text(t.audioDelayHelp, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      const SizedBox(height: 8),
      Center(
        child: TextButton.icon(
          onPressed: () => widget.onAudioDelayChanged(0),
          icon: const Icon(Symbols.restart_alt_rounded, size: 18),
          label: Text(t.resetButton),
          style: TextButton.styleFrom(foregroundColor: cs.primary),
        ),
      ),
    ]);
  }

  Widget _buildAudioInfoSection(AppLocalizations t) {
    final track = widget.currentAudioTrack;
    return track != null
        ? Column(children: [
            _infoTile(t.language, track.language ?? t.unknown),
            _infoTile(t.titleLabel, track.title ?? t.unknown),
            _infoTile(t.codec, track.codec ?? t.unknown),
            _infoTile(t.channel, track.channels != null ? '${track.channels}' : t.unknown),
            _infoTile(t.bitrate, track.bitrate != null ? '${track.bitrate} kbps' : t.unknown),
          ])
        : Text(t.noAudioInfo, style: const TextStyle(color: Colors.white38));
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Flexible(
          child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.left),
        ),
      ]),
    );
  }

  void _showEqualizerDialog(BuildContext context, SettingsProvider s, AppLocalizations t) {
    final List<int> bandFrequencies = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final bands = List<double>.from(s.equalizerBands);
          return AlertDialog(
            title: Text(t.graphicEqualizerTitle),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < bands.length; i++)
                      _CompactSlider('${bandFrequencies[i]} Hz', bands[i], -20, 20, (v) {
                        bands[i] = v;
                        setDialogState(() {});
                      }, Theme.of(context).colorScheme, display: (v) => '${v.toStringAsFixed(1)} dB'),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
              ElevatedButton(
                onPressed: () {
                  s.setEqualizerBands(bands);
                  Navigator.pop(ctx);
                },
                child: Text(t.apply),
              ),
            ],
          );
        },
      ),
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

class _QuickIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickIconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}