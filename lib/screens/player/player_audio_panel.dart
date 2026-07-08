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
  final VoidCallback onAudioFilterSettingsChanged;
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
    required this.onAudioFilterSettingsChanged,
    required this.onClose,
  });

  @override
  State<AudioSettingsPanel> createState() => _AudioSettingsPanelState();
}

class _AudioSettingsPanelState extends State<AudioSettingsPanel> {
  final Set<int> _openSections = {};
  bool _muted = false;
  double _previousVolume = 1.0;

  void _toggleSection(int index) {
    setState(() {
      if (_openSections.contains(index)) {
        _openSections.remove(index);
      } else {
        _openSections.add(index);
      }
    });
  }

  bool _isOpen(int index) => _openSections.contains(index);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = context.watch<SettingsProvider>();
    final t = AppLocalizations.of(context)!;

    final activeAudioName = widget.currentAudioTrack?.title ??
                            widget.currentAudioTrack?.language ??
                            t.noActiveTrack;

    return Directionality(
      textDirection: TextDirection.ltr,
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
                    setState(() {
                      if (_muted) {
                        _muted = false;
                        widget.player.setVolume((_previousVolume * 100).toDouble());
                        widget.onVolumeChanged(_previousVolume);
                      } else {
                        _previousVolume = widget.volumeLevel;
                        _muted = true;
                        widget.player.setVolume(0);
                        widget.onVolumeChanged(0);
                      }
                    });
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
              isOpen: _isOpen(0),
              onTap: () => _toggleSection(0),
              child: _buildAudioTrackSection(cs, t),
            ),
          ],

          _IntegratedSectionTile(
            icon: Symbols.volume_up_rounded,
            title: t.volumeLevel,
            subtitle: '${(widget.volumeLevel * 100).round()}%',
            isOpen: _isOpen(1),
            onTap: () => _toggleSection(1),
            child: _buildVolumeSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.equalizer_rounded,
            title: t.equalizerLabel,
            subtitle: s.equalizerPreset == 'Off' ? t.disabled : t.enabled,
            isOpen: _isOpen(4),
            onTap: () => _toggleSection(4),
            child: _buildEqualizerSection(cs, s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.timeline_rounded,
            title: t.audioSyncLabel,
            subtitle: '${widget.audioDelay > 0 ? '+' : ''}${widget.audioDelay.toStringAsFixed(0)} ms',
            isOpen: _isOpen(2),
            onTap: () => _toggleSection(2),
            child: _buildAudioSyncSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.info_rounded,
            title: t.audioInfo,
            subtitle: '',
            isOpen: _isOpen(3),
            onTap: () => _toggleSection(3),
            child: _buildAudioInfoSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.speaker_rounded,
            title: t.outputSection,
            subtitle: s.audioOutputMode,
            isOpen: _isOpen(5),
            onTap: () => _toggleSection(5),
            child: _buildOutputSection(s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.language_rounded,
            title: t.languageSectionAudio,
            subtitle: langName(s.preferredAudioLanguage),
            isOpen: _isOpen(6),
            onTap: () => _toggleSection(6),
            child: _buildLanguageSection(s, t),
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
        final lang = track.language?.toUpperCase() ?? '?';
        final codec = track.codec ?? '?';
        final channels = track.channels != null ? '${track.channels}' : '?';
        final bitrate = track.bitrate != null ? '${track.bitrate} kbps' : '?';
        final isDefault = index == 0;
        final isActive = widget.currentAudioTrack == track;

        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: Text(
            lang,
            style: TextStyle(
              color: isActive ? cs.primary : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          title: Text(
            track.title ?? track.language ?? t.audioTrackNumber(index + 1),
            style: TextStyle(
              color: isActive ? cs.primary : Colors.white,
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            '$codec · $channels ch · $bitrate${isDefault ? ' · ${t.defaultLabel}' : ''}',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          trailing: isActive
              ? Icon(Symbols.check_rounded, color: cs.primary, size: 18)
              : null,
          onTap: () => widget.onTrackSelected(track),
        );
      }).toList(),
    );
  }

  Widget _buildVolumeSection(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(
        t.volumeLevel,
        widget.volumeLevel.clamp(0.0, 1.0),
        0.0,
        1.0,
        (v) {
          widget.onVolumeChanged(v);
          widget.player.setVolume((v * 100).toDouble());
        },
        cs,
        display: (v) => '${(v * 100).round()}%',
      ),
      const SizedBox(height: 10),
      _CompactSlider(
        t.audioBoostOption,
        widget.volumeLevel > 1.0 ? widget.volumeLevel : 1.0,
        1.0,
        3.0,
        (v) {
          widget.onVolumeChanged(v);
          widget.player.setVolume((v * 100).toDouble());
        },
        cs,
        display: (v) => '${(v * 100).round()}%',
      ),
    ]);
  }

  Widget _buildEqualizerSection(ColorScheme cs, SettingsProvider s, AppLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _choiceTile(
        context: context,
        icon: Symbols.tune_rounded,
        title: t.presetLabel,
        subtitle: s.equalizerPreset,
        onTap: () => _showPresetPicker(context, s, t),
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.bassBoostLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.bassBoostDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.bassBoost,
        onChanged: (v) {
          s.setBassBoost(v);
          widget.onAudioFilterSettingsChanged();
        },
        activeColor: cs.primary,
      ),
      const Divider(height: 1, color: Colors.white12),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.trebleBoostLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.trebleBoostDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.surroundSound,
        onChanged: (v) {
          s.setSurroundSound(v);
          widget.onAudioFilterSettingsChanged();
        },
        activeColor: cs.primary,
      ),
      const Divider(height: 1, color: Colors.white12),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.normalizeVolume, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.normalizeVolumeDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.normalizeVolume,
        onChanged: (v) {
          s.setNormalizeVolume(v);
          widget.onAudioFilterSettingsChanged();
        },
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _QuickJumpBtn(label: '-500', onTap: () => widget.onAudioDelayChanged(widget.audioDelay - 500)),
          _QuickJumpBtn(label: '-50', onTap: () => widget.onAudioDelayChanged(widget.audioDelay - 50)),
          _QuickJumpBtn(label: '+50', onTap: () => widget.onAudioDelayChanged(widget.audioDelay + 50)),
          _QuickJumpBtn(label: '+500', onTap: () => widget.onAudioDelayChanged(widget.audioDelay + 500)),
        ],
      ),
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
            _infoTile(t.codec, track.codec ?? t.unknown),
            _infoTile(t.channel, track.channels != null ? '${track.channels}' : t.unknown),
            _infoTile(t.bitrate, track.bitrate != null ? '${track.bitrate} kbps' : t.unknown),
            _infoTile(t.language, track.language ?? t.unknown),
          ])
        : Text(t.noAudioInfo, style: const TextStyle(color: Colors.white38));
  }

  Widget _buildOutputSection(SettingsProvider s, AppLocalizations t) {
    final modes = ['Stereo', 'Mono', 'Left', 'Right', '5.1 Downmix', 'Passthrough'];
    return Column(
      children: modes.map((mode) {
        final isSelected = s.audioOutputMode == mode;
        return ListTile(
          dense: true,
          title: Text(mode, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white, fontSize: 13)),
          trailing: isSelected ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary, size: 18) : null,
          onTap: () {
            s.setAudioOutputMode(mode);
            widget.onAudioFilterSettingsChanged();
          },
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSection(SettingsProvider s, AppLocalizations t) {
    final langs = {'ara': t.arabicLanguageOption, 'eng': t.englishLanguageOption, 'fra': t.frenchLanguageOption, 'spa': 'Español', 'jpn': '日本語', 'auto': t.autoOption};
    return Column(
      children: langs.entries.map((e) {
        final isSelected = s.preferredAudioLanguage == e.key;
        return ListTile(
          dense: true,
          title: Text(e.value, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white, fontSize: 13)),
          trailing: isSelected ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary, size: 18) : null,
          onTap: () {
            s.setPreferredAudioLanguage(e.key);
          },
        );
      }).toList(),
    );
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

  void _showPresetPicker(BuildContext context, SettingsProvider s, AppLocalizations t) {
    final presets = ['Off', 'Rock', 'Pop', 'Movie', 'Classical', 'Jazz', 'Speech', 'Custom'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Text(t.presetLabel, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              const Divider(height: 1),
              ...presets.map((preset) => ListTile(
                title: Text(preset),
                trailing: s.equalizerPreset == preset ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary, size: 18) : null,
                onTap: () {
                  s.setEqualizerPreset(preset);
                  widget.onAudioFilterSettingsChanged();
                  Navigator.pop(ctx);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showEqualizerDialog(BuildContext context, SettingsProvider s, AppLocalizations t) {
    final List<int> bandFrequencies = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000];
    final bands = List<double>.from(s.equalizerBands);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                      child: Text(t.graphicEqualizerTitle,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                    const Divider(height: 1),
                    for (int i = 0; i < bands.length; i++)
                      _CompactSlider('${bandFrequencies[i]} Hz', bands[i], -20, 20, (v) {
                        bands[i] = v;
                        setDialogState(() {});
                      }, Theme.of(context).colorScheme, display: (v) => '${v.toStringAsFixed(1)} dB'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(t.cancel)),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () {
                              s.setEqualizerBands(bands);
                              widget.onAudioFilterSettingsChanged();
                              Navigator.pop(ctx);
                            },
                            child: Text(t.apply)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _choiceTile({required BuildContext context, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70, size: 18),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: const Icon(Symbols.chevron_right_rounded, color: Colors.white54, size: 20),
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

class _QuickJumpBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickJumpBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

String langName(String code) {
  const names = {
    'ara': 'العربية',
    'eng': 'English',
    'fra': 'Français',
    'spa': 'Español',
    'jpn': '日本語',
    'auto': 'تلقائي / Auto',
  };
  return names[code] ?? code.toUpperCase();
}