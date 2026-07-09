import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/player_control_service.dart';
import '../../l10n/app_localizations.dart';

class AudioSettingsPanel extends StatefulWidget {
  final Player player;
  final PlayerControlService service;
  final double volumeLevel;
  final double audioBoost;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onAudioBoostChanged;
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
    required this.service,
    required this.volumeLevel,
    required this.audioBoost,
    required this.onVolumeChanged,
    required this.onAudioBoostChanged,
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
  // مجموعة بدل رقم وحيد: أكثر من قسم يقدر يبقى مفتوح فـ نفس الوقت.
  final Set<int> _openSections = {};

  void _toggleSection(int index) {
    setState(() {
      if (_openSections.contains(index)) {
        _openSections.remove(index);
      } else {
        _openSections.add(index);
      }
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
    final isMuted = widget.volumeLevel <= 0.0;

    return Directionality(
      // بقيت الواجهة بنفس الجهة دائماً (بلا مرآة) كيفما دار المستخدم فـ باقي
      // شاشة المشغل — كيتبدل النص المترجم فقط، والتخطيط/الأيقونات ما كيتحركوش.
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
                // زر كتم واحد فقط، مربوط بآلية service.toggleMute الصحيحة
                // (كتحتفظ بمستوى الصوت السابق وترجعه بالضبط عند الإلغاء).
                _QuickIconBtn(
                  icon: isMuted ? Symbols.volume_off_rounded : Symbols.volume_up_rounded,
                  color: isMuted ? Colors.redAccent : Colors.white70,
                  onTap: widget.service.toggleMute,
                ),
              ],
            ),
          ),

          if (widget.audioTracks.isNotEmpty) ...[
            _IntegratedSectionTile(
              icon: Symbols.audiotrack_rounded,
              title: t.audioTracks,
              subtitle: t.audioTracksCount(widget.audioTracks.length),
              isOpen: _openSections.contains(0),
              onTap: () => _toggleSection(0),
              child: _buildAudioTrackSection(cs, t),
            ),
          ],

          _IntegratedSectionTile(
            icon: Symbols.volume_up_rounded,
            title: t.volumeLevel,
            subtitle: '${(widget.volumeLevel * 100).round()}%',
            isOpen: _openSections.contains(1),
            onTap: () => _toggleSection(1),
            child: _buildVolumeSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.trending_up_rounded,
            title: t.audioBoostLabel,
            subtitle: '${(widget.audioBoost * 100).round()}%',
            isOpen: _openSections.contains(5),
            onTap: () => _toggleSection(5),
            child: _buildAudioBoostSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.equalizer_rounded,
            title: t.equalizerLabel,
            subtitle: s.equalizerPreset == 'custom' ? t.presetCustom : _presetName(s.equalizerPreset, t),
            isOpen: _openSections.contains(4),
            onTap: () => _toggleSection(4),
            child: _buildEqualizerSection(cs, s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.timeline_rounded,
            title: t.audioSyncLabel,
            subtitle: '${widget.audioDelay > 0 ? '+' : ''}${widget.audioDelay.toStringAsFixed(0)} ms',
            isOpen: _openSections.contains(2),
            onTap: () => _toggleSection(2),
            child: _buildAudioSyncSection(t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.speaker_group_rounded,
            title: t.outputSectionLabel,
            subtitle: _outputName(s.audioOutputMode, t),
            isOpen: _openSections.contains(6),
            onTap: () => _toggleSection(6),
            child: _buildOutputSection(cs, s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.translate_rounded,
            title: t.preferredAudioSectionLabel,
            subtitle: _langName(s.preferredAudioLanguage, t),
            isOpen: _openSections.contains(7),
            onTap: () => _toggleSection(7),
            child: _buildLanguageSection(cs, s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.tune_rounded,
            title: t.playbackSectionLabel,
            subtitle: '',
            isOpen: _openSections.contains(8),
            onTap: () => _toggleSection(8),
            child: _buildPlaybackSection(cs, s, t),
          ),

          _IntegratedSectionTile(
            icon: Symbols.info_rounded,
            title: t.audioInfo,
            subtitle: '',
            isOpen: _openSections.contains(3),
            onTap: () => _toggleSection(3),
            child: _buildAudioInfoSection(t),
          ),
        ],
      ),
    );
  }

  String _presetName(String preset, AppLocalizations t) {
    switch (preset) {
      case 'rock': return t.presetRock;
      case 'pop': return t.presetPop;
      case 'movie': return t.presetMovie;
      case 'classical': return t.presetClassical;
      case 'jazz': return t.presetJazz;
      case 'speech': return t.presetSpeech;
      case 'custom': return t.presetCustom;
      case 'off':
      default: return t.presetOff;
    }
  }

  String _outputName(String mode, AppLocalizations t) {
    switch (mode) {
      case 'mono': return t.outputMono;
      case 'left': return t.outputLeft;
      case 'right': return t.outputRight;
      case 'downmix51': return t.output51Downmix;
      case 'passthrough': return t.outputPassthrough;
      case 'stereo':
      default: return t.outputStereo;
    }
  }

  String _langName(String code, AppLocalizations t) {
    switch (code) {
      case 'ara': return t.arabicLanguageOption;
      case 'eng': return t.englishLanguageOption;
      case 'jpn': return '日本語';
      case 'auto':
      default: return t.autoOption;
    }
  }

  Widget _buildAudioTrackSection(ColorScheme cs, AppLocalizations t) {
    return Column(
      children: widget.audioTracks.asMap().entries.map((entry) {
        final index = entry.key;
        final track = entry.value;
        final name = track.title ?? track.language ?? t.audioTrackNumber(index + 1);
        final isActive = widget.currentAudioTrack == track;
        final details = <String>[
          if (track.codec != null && track.codec!.isNotEmpty) track.codec!.toUpperCase(),
          if (track.channels != null) t.channelsCount(track.channels!),
          if (track.bitrate != null) '${(track.bitrate! / 1000).round()} kbps',
        ].join(' • ');
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          title: Text(name, style: TextStyle(color: isActive ? cs.primary : Colors.white, fontSize: 13)),
          subtitle: details.isNotEmpty
              ? Text(details, style: const TextStyle(color: Colors.white38, fontSize: 11))
              : null,
          trailing: isActive ? Icon(Symbols.check_rounded, color: cs.primary, size: 18) : null,
          onTap: () => widget.onTrackSelected(track),
        );
      }).toList(),
    );
  }

  Widget _buildVolumeSection(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // مستوى الصوت العادي: 0% إلى 100% فقط، مربوط مباشرة بـ player.setVolume.
      _CompactSlider(t.volumeLevel, widget.volumeLevel, 0.0, 1.0, widget.onVolumeChanged, cs,
          display: (v) => '${(v * 100).round()}%'),
    ]);
  }

  Widget _buildAudioBoostSection(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // تعزيز الصوت: 100% إلى 300%، مستقل كليًا عن مستوى الصوت العادي،
      // ومطبّق كمرشح صوتي حقيقي (وليس عبر setVolume).
      _CompactSlider(t.audioBoostLabel, widget.audioBoost, 1.0, 3.0, widget.onAudioBoostChanged, cs,
          display: (v) => '${(v * 100).round()}%'),
    ]);
  }

  Widget _buildEqualizerSection(ColorScheme cs, SettingsProvider s, AppLocalizations t) {
    final presets = ['off', 'rock', 'pop', 'movie', 'classical', 'jazz', 'speech', 'custom'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: presets.map((p) {
            final selected = s.equalizerPreset == p;
            return ChoiceChip(
              label: Text(_presetName(p, t), style: TextStyle(fontSize: 11, color: selected ? Colors.black : Colors.white70)),
              selected: selected,
              selectedColor: cs.primary,
              backgroundColor: Colors.white.withOpacity(0.08),
              onSelected: (_) {
                s.setEqualizerPreset(p);
                widget.onAudioFilterSettingsChanged();
              },
            );
          }).toList(),
        ),
      ),
      const Divider(height: 1, color: Colors.white12),
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
        title: Text(t.normalizeVolumeLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
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
        onTap: () => _openGraphicEqualizerPanel(context, s, t),
      ),
    ]);
  }

  Widget _buildAudioSyncSection(AppLocalizations t) {
    final cs = Theme.of(context).colorScheme;
    void nudge(double deltaMs) {
      final next = (widget.audioDelay + deltaMs).clamp(-2000.0, 2000.0);
      widget.onAudioDelayChanged(next);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _CompactSlider(t.audioDelay, widget.audioDelay, -500.0, 500.0, widget.onAudioDelayChanged, cs,
          display: (v) => '${v > 0 ? '+' : ''}${v.toStringAsFixed(0)} ms'),
      const SizedBox(height: 6),
      Text(t.audioDelayHelp, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
      const SizedBox(height: 10),
      // أزرار سريعة بدل الاعتماد على السلايدر وحده (أدق وأسهل بإصبع واحد).
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _DelayStepButton(label: '-500', onTap: () => nudge(-500)),
        _DelayStepButton(label: '-50', onTap: () => nudge(-50)),
        _DelayStepButton(label: '+50', onTap: () => nudge(50)),
        _DelayStepButton(label: '+500', onTap: () => nudge(500)),
      ]),
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

  Widget _buildOutputSection(ColorScheme cs, SettingsProvider s, AppLocalizations t) {
    final options = [
      ('stereo', t.outputStereo, Symbols.speaker_group_rounded),
      ('mono', t.outputMono, Symbols.speaker_rounded),
      ('left', t.outputLeft, Symbols.speaker_notes_rounded),
      ('right', t.outputRight, Symbols.speaker_notes_rounded),
      ('downmix51', t.output51Downmix, Symbols.surround_sound_rounded),
      ('passthrough', t.outputPassthrough, Symbols.sync_alt_rounded),
    ];
    return Column(
      children: options.map((opt) {
        final selected = s.audioOutputMode == opt.$1;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(opt.$3, size: 18, color: selected ? cs.primary : Colors.white54),
          title: Text(opt.$2, style: TextStyle(color: selected ? cs.primary : Colors.white, fontSize: 13)),
          trailing: selected ? Icon(Symbols.check_rounded, color: cs.primary, size: 18) : null,
          onTap: () {
            s.setAudioOutputMode(opt.$1);
            widget.onAudioFilterSettingsChanged();
          },
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSection(ColorScheme cs, SettingsProvider s, AppLocalizations t) {
    final options = [
      ('auto', t.autoOption),
      ('ara', t.arabicLanguageOption),
      ('eng', t.englishLanguageOption),
      ('jpn', '日本語'),
    ];
    return Column(
      children: options.map((opt) {
        final selected = s.preferredAudioLanguage == opt.$1;
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(opt.$2, style: TextStyle(color: selected ? cs.primary : Colors.white, fontSize: 13)),
          trailing: selected ? Icon(Symbols.check_rounded, color: cs.primary, size: 18) : null,
          onTap: () => s.setPreferredAudioLanguage(opt.$1),
        );
      }).toList(),
    );
  }

  Widget _buildPlaybackSection(ColorScheme cs, SettingsProvider s, AppLocalizations t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.pitchCorrectionOption, style: const TextStyle(color: Colors.white, fontSize: 13)),
        value: s.pitchCorrection,
        onChanged: (v) {
          s.setPitchCorrection(v);
          widget.onAudioFilterSettingsChanged();
        },
        activeColor: cs.primary,
      ),
      const Divider(height: 1, color: Colors.white12),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.replayGainLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.replayGainDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.replayGain,
        onChanged: (v) {
          s.setReplayGain(v);
          widget.onAudioFilterSettingsChanged();
        },
        activeColor: cs.primary,
      ),
      const Divider(height: 1, color: Colors.white12),
      SwitchListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(t.skipSilenceLabel, style: const TextStyle(color: Colors.white, fontSize: 13)),
        subtitle: Text(t.skipSilenceDesc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        value: s.skipSilence,
        onChanged: (v) {
          s.setSkipSilence(v);
          widget.onAudioFilterSettingsChanged();
        },
        activeColor: cs.primary,
      ),
    ]);
  }

  Widget _buildAudioInfoSection(AppLocalizations t) {
    final track = widget.currentAudioTrack;
    if (track == null) {
      return Text(t.noAudioInfo, style: const TextStyle(color: Colors.white38));
    }
    // معدل العينة وعمق البت مبنيين على audioParams الحية من المشغل (وهي
    // متوفرة فقط للمسار الجاري تشغيله حالياً، ماشي لكل المسارات المتاحة).
    final params = widget.player.state.audioParams;
    return Column(children: [
      _infoTile(t.language, track.language ?? t.unknown),
      _infoTile(t.titleLabel, track.title ?? t.unknown),
      _infoTile(t.codec, track.codec ?? t.unknown),
      _infoTile(t.channel, track.channels != null ? '${track.channels}' : t.unknown),
      _infoTile(t.bitrate, track.bitrate != null ? '${(track.bitrate! / 1000).round()} kbps' : t.unknown),
      _infoTile(t.sampleRate, params?.sampleRate != null ? '${params!.sampleRate} Hz' : t.unknown),
      _infoTile(t.bitDepth, params?.format != null ? params!.format! : t.unknown),
    ]);
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

  // المعادل الرسومي دابا Bottom Sheet بدل AlertDialog: 10 سلايدرز داخل
  // Dialog كتضيق بزاف على الهاتف، والـ Sheet كيعطيهم مساحة كاملة.
  void _openGraphicEqualizerPanel(BuildContext context, SettingsProvider s, AppLocalizations t) {
    final List<int> bandFrequencies = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000];
    // bands خاصها تتبنى مرة وحدة برا الـ builder المتكرر، وإلا كترجع
    // للقيمة الأصلية بعد كل سحبة (بحال المشكل السابق فـ AlertDialog).
    final bands = List<double>.from(s.equalizerBands);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cs = Theme.of(context).colorScheme;
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (ctx, scrollController) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                Text(t.graphicEqualizerPanelTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      for (int i = 0; i < bands.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _CompactSlider('${bandFrequencies[i]} Hz', bands[i], -20, 20, (v) {
                            bands[i] = v;
                            // أي تعديل يدوي كيحوّل البريست تلقائياً لـ "مخصص".
                            if (s.equalizerPreset != 'custom') s.setEqualizerPreset('custom');
                            setSheetState(() {});
                          }, cs, display: (v) => '${v.toStringAsFixed(1)} dB'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(t.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        s.setEqualizerBands(bands);
                        widget.onAudioFilterSettingsChanged();
                        Navigator.pop(ctx);
                      },
                      child: Text(t.apply),
                    ),
                  ),
                ]),
              ]),
            ),
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
            child: Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
          ),
        ),
        SizedBox(width: 50, child: Text(displayed, style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
      ],
    );
  }
}

class _DelayStepButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DelayStepButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: cs.primary,
        side: BorderSide(color: cs.primary.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
