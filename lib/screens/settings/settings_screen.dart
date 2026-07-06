import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/settings_provider.dart';
import '../../models/subtitle_settings.dart';
import '../../services/thumbnail_service.dart';
import '../../l10n/app_localizations.dart';
import 'settings_widgets.dart';
import 'settings_dialogs.dart';
import 'hidden_files_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _openSection = -1;
  int? _cacheSizeBytes;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await ThumbnailService().getCacheSizeBytes();
    if (mounted) setState(() => _cacheSizeBytes = size);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    final mb = bytes / (1024 * 1024);
    if (mb < 1) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${mb.toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final sub = s.subtitleSettings;
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTitle),
        leading: IconButton(icon: const Icon(Symbols.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sectionHeader(context, t.generalSection, Symbols.settings_rounded),

        _card(context, [
          _sectionFoldHeader(context, t.languageSection, Symbols.language_rounded, _openSection == 200, () => setState(() => _openSection = _openSection == 200 ? -1 : 200)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 200 ? Column(children: [
              _choiceTile(context, Symbols.language_rounded, t.languageOption, languageDisplayName(s.appLanguageCode, t), () => showLanguagePicker(context, s)),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.themeSection, Symbols.dark_mode_rounded, _openSection == 201, () => setState(() => _openSection = _openSection == 201 ? -1 : 201)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 201 ? Column(children: [
              _choiceTile(context, Symbols.dark_mode_rounded, t.appearanceOption, themeName(s.themeMode, t), () => showThemePicker(context, s)),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.appColorSection, Symbols.palette_rounded, _openSection == 202, () => setState(() => _openSection = _openSection == 202 ? -1 : 202)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 202 ? Column(children: [
              ListTile(
                leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(Symbols.palette_rounded, color: cs.onSurfaceVariant, size: 22)),
                title: Text(t.themeColorOption),
                subtitle: Text(t.themeColorSubtitle),
                trailing: GestureDetector(
                  onTap: () => showThemeColorPicker(context, s),
                  child: Container(width: 28, height: 28, decoration: BoxDecoration(color: s.themeSeedColor, shape: BoxShape.circle, border: Border.all(color: cs.outlineVariant))),
                ),
                onTap: () => showThemeColorPicker(context, s),
              ),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.startupScreenSection, Symbols.home_rounded, _openSection == 203, () => setState(() => _openSection = _openSection == 203 ? -1 : 203)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 203 ? Column(children: [
              _choiceTile(context, Symbols.home_rounded, t.startupScreenSection, t.libraryTab, () {}),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.autoRotateOption, Symbols.screen_rotation_rounded, _openSection == 204, () => setState(() => _openSection = _openSection == 204 ? -1 : 204)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 204 ? Column(children: [
              _switchTile(context, Symbols.screen_rotation_rounded, t.autoRotateOption, '', s.autoRotate, s.setAutoRotate),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.keepScreenOnOption, Symbols.screen_lock_landscape_rounded, _openSection == 205, () => setState(() => _openSection = _openSection == 205 ? -1 : 205)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 205 ? Column(children: [
              _switchTile(context, Symbols.screen_lock_landscape_rounded, t.keepScreenOnOption, '', s.keepScreenOn, s.setKeepScreenOn),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.autoHideStatusBarOption, Symbols.hide_source_rounded, _openSection == 206, () => setState(() => _openSection = _openSection == 206 ? -1 : 206)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 206 ? Column(children: [
              _switchTile(context, Symbols.hide_source_rounded, t.autoHideStatusBarOption, '', s.autoHideStatusBar, s.setAutoHideStatusBar),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.vibrateOnGestureOption, Symbols.vibration_rounded, _openSection == 207, () => setState(() => _openSection = _openSection == 207 ? -1 : 207)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 207 ? Column(children: [
              _switchTile(context, Symbols.vibration_rounded, t.vibrateOnGestureOption, '', s.vibrateOnEnd, s.setVibrateOnEnd),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.animationsOption, Symbols.animation_rounded, _openSection == 208, () => setState(() => _openSection = _openSection == 208 ? -1 : 208)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 208 ? Column(children: [
              _switchTile(context, Symbols.animation_rounded, t.animationsOption, '', s.animationsEnabled, s.setAnimationsEnabled),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 24),

        Center(
          child: TextButton.icon(
            onPressed: () => _confirmReset(context, s),
            icon: Icon(Symbols.restart_alt_rounded, color: cs.error),
            label: Text(t.resetAllButton, style: TextStyle(color: cs.error)),
          ),
        ),
        const SizedBox(height: 16),

        _sectionHeader(context, t.playerSection, Symbols.play_circle_rounded),

        _card(context, [
          _sectionFoldHeader(context, t.playbackSection, Symbols.play_arrow_rounded, _openSection == 100, () => setState(() => _openSection = _openSection == 100 ? -1 : 100)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 100 ? Column(children: [
              _switchTile(context, Symbols.play_arrow_rounded, t.autoPlayOption, '', s.autoPlay, s.setAutoPlay),
              _divider(),
              _switchTile(context, Symbols.resume_rounded, t.resumePositionOption, '', s.rememberPosition, s.setRememberPosition),
              _divider(),
              _switchTile(context, Symbols.speed_rounded, t.rememberSpeedOption, '', s.rememberPlaybackSpeed, s.setRememberPlaybackSpeed),
              _divider(),
              _choiceTile(context, Symbols.repeat_rounded, t.repeatModeOption, loopModeName(s.loopMode, t), () => _showLoopModePicker(context, s)),
              _divider(),
              _switchTile(context, Symbols.skip_next_rounded, t.autoNextOption, '', s.autoNextVideo, s.setAutoNextVideo),
              _divider(),
              _switchTile(context, Symbols.picture_in_picture_rounded, t.autoPipOption, '', s.autoPipOnBackground, s.setAutoPipOnBackground),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.speedSection, Symbols.speed_rounded, _openSection == 101, () => setState(() => _openSection = _openSection == 101 ? -1 : 101)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 101 ? Column(children: [
              _choiceTile(context, Symbols.speed_rounded, t.defaultSpeedOption, '${s.defaultSpeed}x', () => showSpeedPicker(context, s)),
              _divider(),
              _switchTile(context, Symbols.history_rounded, t.rememberLastSpeedOption, '', s.rememberSpeed, s.setRememberSpeed),
              _divider(),
              _switchTile(context, Symbols.fast_forward_rounded, t.allow4xOption, '', s.allowSpeedUpTo4x, s.setAllowSpeedUpTo4x),
              _divider(),
              _switchTile(context, Symbols.music_note_rounded, t.pitchCorrectionOption, '', s.pitchCorrection, s.setPitchCorrection),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.videoDisplaySection, Symbols.aspect_ratio_rounded, _openSection == 102, () => setState(() => _openSection = _openSection == 102 ? -1 : 102)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 102 ? Column(children: [
              _choiceTile(context, Symbols.aspect_ratio_rounded, t.defaultVideoModeOption, _videoModeName(s.defaultVideoMode, t), () => _showVideoModePicker(context, s)),
              _divider(),
              _switchTile(context, Symbols.history_rounded, t.rememberVideoModeOption, '', s.rememberVideoMode, s.setRememberVideoMode),
              _divider(),
              _switchTile(context, Symbols.fullscreen_rounded, t.autoFullscreenOption, '', s.autoFullscreen, s.setAutoFullscreen),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.gesturesSection, Symbols.touch_app_rounded, _openSection == 103, () => setState(() => _openSection = _openSection == 103 ? -1 : 103)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 103 ? Column(children: [
              _switchTile(context, Symbols.volume_up_rounded, t.gestureVolumeOption, '', s.gestureVolume, s.setGestureVolume),
              _divider(),
              _switchTile(context, Symbols.brightness_6_rounded, t.gestureBrightnessOption, '', s.gestureBrightness, s.setGestureBrightness),
              _divider(),
              _switchTile(context, Symbols.fast_forward_rounded, t.gestureSeekOption, '', s.gestureSeek, s.setGestureSeek),
              _divider(),
              _switchTile(context, Symbols.touch_app_rounded, t.tapToPauseOption, '', s.tapToPause, s.setTapToPause),
              _divider(),
              _switchTile(context, Symbols.double_arrow_rounded, t.doubleTapOption, '', s.doubleTapSeek, s.setDoubleTapSeek),
              _divider(),
              _switchTile(context, Symbols.speed_rounded, t.longPressSpeedOption, '', s.longPressSpeed, s.setLongPressSpeed),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.seekSection, Symbols.fast_rewind_rounded, _openSection == 104, () => setState(() => _openSection = _openSection == 104 ? -1 : 104)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 104 ? Column(children: [
              _choiceTile(context, Symbols.timeline_rounded, t.seekDurationOption, '${s.doubleTapSeekSeconds} s', () => showSeekSecondsPicker(context, s)),
              _divider(),
              _switchTile(context, Symbols.image_rounded, t.seekPreviewOption, '', s.showSeekPreview, s.setShowSeekPreview),
              _divider(),
              _switchTile(context, Symbols.timer_rounded, t.seekTimeOption, '', s.showSeekTime, s.setShowSeekTime),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.uiSection, Symbols.layers_rounded, _openSection == 105, () => setState(() => _openSection = _openSection == 105 ? -1 : 105)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 105 ? Column(children: [
              _switchTile(context, Symbols.visibility_off_rounded, t.autoHideControlsOption, '', s.autoHideControls, s.setAutoHideControls),
              if (s.autoHideControls) ...[
                _divider(),
                _choiceTile(context, Symbols.timer_rounded, t.hideDelayOption, '${s.controlsHideSeconds} s', () => showHideDelayPicker(context, s)),
              ],
              _divider(),
              _switchTile(context, Symbols.timer_off_rounded, t.showRemainingTimeOption, '', s.showRemainingTime, s.setShowRemainingTime),
              _divider(),
              _switchTile(context, Symbols.timer_rounded, t.showElapsedTimeOption, '', s.showElapsedTime, s.setShowElapsedTime),
              _divider(),
              _switchTile(context, Symbols.title_rounded, t.showVideoTitleOption, '', s.showVideoTitle, s.setShowVideoTitle),
              _divider(),
              _switchTile(context, Symbols.battery_full_rounded, t.showBatteryOption, '', s.showBattery, s.setShowBattery),
              _divider(),
              _switchTile(context, Symbols.schedule_rounded, t.showClockOption, '', s.showClock, s.setShowClock),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.playlistSection, Symbols.queue_music_rounded, _openSection == 106, () => setState(() => _openSection = _openSection == 106 ? -1 : 106)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 106 ? Column(children: [
              _switchTile(context, Symbols.auto_mode_rounded, t.continuousPlaybackOption, '', s.continuousPlayback, s.setContinuousPlayback),
              _divider(),
              _switchTile(context, Symbols.delete_rounded, t.removeAfterPlaybackOption, '', s.removeVideoAfterPlayback, s.setRemoveVideoAfterPlayback),
              _divider(),
              _switchTile(context, Symbols.history_rounded, t.rememberPlaylistOption, '', s.rememberLastPlaylist, s.setRememberLastPlaylist),
              _divider(),
              _switchTile(context, Symbols.save_rounded, t.savePlaylistOrderOption, '', s.savePlaylistOrder, s.setSavePlaylistOrder),
              _divider(),
              _switchTile(context, Symbols.shuffle_rounded, t.shufflePlaylistOption, '', s.shufflePlaylist, s.setShufflePlaylist),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.energySection, Symbols.battery_saver_rounded, _openSection == 107, () => setState(() => _openSection = _openSection == 107 ? -1 : 107)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 107 ? Column(children: [
              _switchTile(context, Symbols.screen_lock_landscape_rounded, t.preventLockOption, '', s.preventScreenLock, s.setPreventScreenLock),
              _divider(),
              _switchTile(context, Symbols.brightness_4_rounded, t.reduceBrightnessOption, '', s.reduceBrightnessOnPause, s.setReduceBrightnessOnPause),
              _divider(),
              _switchTile(context, Symbols.stop_rounded, t.stopAfterVideoOption, '', s.stopAfterVideo, s.setStopAfterVideo),
              _divider(),
              _choiceTile(context, Symbols.bedtime_rounded, t.sleepTimerOption, s.sleepTimerMinutes == 0 ? t.sleepTimerDisabled : t.sleepTimerMinutes(s.sleepTimerMinutes), () => _showSleepTimerPicker(context, s)),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.controlSection, Symbols.gamepad_rounded, _openSection == 108, () => setState(() => _openSection = _openSection == 108 ? -1 : 108)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 108 ? Column(children: [
              _switchTile(context, Symbols.volume_up_rounded, t.volumeKeysSeekOption, '', s.volumeKeysSeek, s.setVolumeKeysSeek),
              _divider(),
              _switchTile(context, Symbols.keyboard_rounded, t.keyboardSupportOption, '', s.keyboardSupport, s.setKeyboardSupport),
              _divider(),
              _switchTile(context, Symbols.gamepad_rounded, t.gamepadSupportOption, '', s.gamepadSupport, s.setGamepadSupport),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.advancedSection, Symbols.settings_rounded, _openSection == 109, () => setState(() => _openSection = _openSection == 109 ? -1 : 109)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 109 ? Column(children: [
              _choiceTile(context, Symbols.memory_rounded, t.decoderModeOption, hwDecoderName(s.hwDecoderMode, t), () => _showDecoderPicker(context, s)),
              _divider(),
              _switchTile(context, Symbols.auto_fix_high_rounded, t.fallbackSoftwareOption, '', s.fallbackToSoftware, s.setFallbackToSoftware),
              _divider(),
              _switchTile(context, Symbols.speed_rounded, t.lowLatencyOption, '', s.lowLatencyPlayback, s.setLowLatencyPlayback),
              _divider(),
              _switchTile(context, Symbols.video_stable_rounded, t.frameDroppingOption, '', s.frameDropping, s.setFrameDropping),
              _divider(),
              _switchTile(context, Symbols.video_settings_rounded, t.vsyncOption, '', s.vsync, s.setVsync),
              _divider(),
              _switchTile(context, Symbols.bug_report_rounded, t.loggingOption, '', s.loggingEnabled, s.setLoggingEnabled),
              _divider(),
              _switchTile(context, Symbols.info_rounded, t.showVideoInfoOption, '', s.showVideoInfo, s.setShowVideoInfo),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 16),

        _sectionHeader(context, t.audioSection, Symbols.graphic_eq_rounded),

        _card(context, [
          _sectionFoldHeader(context, t.audioGeneralSection, Symbols.volume_up_rounded, _openSection == 4, () => setState(() => _openSection = _openSection == 4 ? -1 : 4)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 4 ? Column(children: [
              _choiceTile(context, Symbols.volume_up_rounded, t.audioBoostOption, '${s.defaultAudioBoost.round()}%', () => showBoostDialog(context, s)),
              _divider(),
              _sliderRow(context, t.audioBalanceOption, s.audioBalance, -1.0, 1.0, s.audioBalance.toStringAsFixed(1), (v) => s.setAudioBalance(v)),
              _divider(),
              _switchTile(context, Symbols.volume_up_rounded, t.rememberVolumeOption, '', s.rememberVolumePerVideo, s.setRememberVolumePerVideo),
              _divider(),
              _switchTile(context, Symbols.restart_alt_rounded, t.resetVolumeOption, '', s.resetVolumePerVideo, s.setResetVolumePerVideo),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.audioOutputSection, Symbols.speaker_rounded, _openSection == 5, () => setState(() => _openSection = _openSection == 5 ? -1 : 5)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 5 ? Column(children: [
              _choiceTile(context, Symbols.speaker_rounded, t.audioOutputModeOption, audioModeName(s.audioOutputMode, t), () => _showAudioModePicker(context, s)),
              _divider(),
              _switchTile(context, Symbols.bluetooth_rounded, t.autoBluetoothOption, '', s.autoSwitchBluetooth, s.setAutoSwitchBluetooth),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.audioTracksSection, Symbols.playlist_play_rounded, _openSection == 6, () => setState(() => _openSection = _openSection == 6 ? -1 : 6)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 6 ? Column(children: [
              _choiceTile(context, Symbols.language_rounded, t.preferredAudioLanguageOption, langName(s.preferredAudioLanguage), () => showAudioLanguagePicker(context, s)),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.equalizerSection, Symbols.equalizer_rounded, _openSection == 7, () => setState(() => _openSection = _openSection == 7 ? -1 : 7)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 7 ? Column(children: [
              _switchTile(context, Symbols.equalizer_rounded, t.equalizerEnabledOption, '', s.bassBoost, s.setBassBoost),
              if (s.bassBoost) ...[
                _divider(),
                _choiceTile(context, Symbols.tune_rounded, t.openEqualizerOption, t.equalizerBandsSubtitle, () => _showEqualizerDialog(context, s)),
              ],
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.audioSyncSection, Symbols.timeline_rounded, _openSection == 8, () => setState(() => _openSection = _openSection == 8 ? -1 : 8)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 8 ? Column(children: [
              _sliderRow(context, t.audioDelayOption, s.audioDelayMs.toDouble(), -5000, 5000, '${s.audioDelayMs} ms', (v) => s.setAudioDelayMs(v.toInt())),
              _divider(),
              Center(child: TextButton.icon(onPressed: () => s.setAudioDelayMs(0), icon: Icon(Symbols.restart_alt_rounded, color: cs.primary), label: Text(t.resetButton, style: TextStyle(color: cs.primary)))),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.audioProcessingSection, Symbols.hearing_rounded, _openSection == 9, () => setState(() => _openSection = _openSection == 9 ? -1 : 9)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 9 ? Column(children: [
              _switchTile(context, Symbols.surround_sound_rounded, t.surroundSoundOption, t.surroundSoundSubtitle, s.surroundSound, s.setSurroundSound),
              _divider(),
              _switchTile(context, Symbols.equalizer_rounded, t.bassBoostOption, t.bassBoostSubtitle, s.bassBoost, s.setBassBoost),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 16),

        _sectionHeader(context, t.subtitlesSection, Symbols.subtitles_rounded),

        _card(context, [
          _sectionFoldHeader(context, t.subAppearanceSection, Symbols.palette_rounded, _openSection == 0, () => setState(() => _openSection = _openSection == 0 ? -1 : 0)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 0 ? Column(children: [
              _fontSection(context, s, sub),
              const SizedBox(height: 12),
              _colorSection(context, s, sub),
              const SizedBox(height: 12),
              _effectsSection(context, s, sub),
              const SizedBox(height: 12),
              _bgSection(context, s, sub),
              const SizedBox(height: 12),
              _switchTile(context, Symbols.format_italic_rounded, t.italicOption, t.italicSubtitle, s.subtitleItalic, s.setSubtitleItalic),
              const Divider(height: 1),
              Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Center(child: TextButton.icon(onPressed: () {
                s.updateSubtitleSettings(sub.copyWith(fontSize: 30.0, subtitleScale: 1.0, fontFamily: 'Roboto', textColor: const Color(0xFFFFFFFF), textOpacity: 1.0, fontWeightIndex: 2, outlineColor: const Color(0xFF000000), outlineWidth: 2.0, outlineScale: 1.0, shadowEnabled: false, shadowColor: const Color(0xFF000000), shadowOpacity: 0.5, shadowOffsetX: 2.0, shadowOffsetY: 2.0, shadowBlurRadius: 4.0, bgColor: const Color(0xFF000000), bgOpacity: 0.0, bgBorderRadius: 4.0, bgBorderColor: const Color(0xFFFFFFFF), bgBorderWidth: 0.0, bgPadding: 8.0, bgShape: SubtitleBgShape.rounded, letterSpacing: 0.0, wordSpacing: 0.0, lineHeight: 1.2, lineSpacing: 1.0, autoWrap: true, maxLines: 2));
                s.setSubtitleItalic(false);
              }, icon: Icon(Symbols.restart_alt_rounded, color: cs.primary), label: Text(t.resetAppearanceButton, style: TextStyle(color: cs.primary))))),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.subPositionSection, Symbols.open_with_rounded, _openSection == 1, () => setState(() => _openSection = _openSection == 1 ? -1 : 1)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 1 ? Column(children: [
              _positionSection(context, s, sub),
              const SizedBox(height: 12),
              _switchTile(context, Symbols.format_textdirection_r_to_l_rounded, t.textDirectionOption, sub.alignment == SubtitleAlignment.right ? t.textDirectionRTL : t.textDirectionLTR, sub.alignment == SubtitleAlignment.right, (v) => s.updateSubtitleSettings(sub.copyWith(alignment: v ? SubtitleAlignment.right : SubtitleAlignment.left))),
              const Divider(height: 1),
              Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Center(child: TextButton.icon(onPressed: () { s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.bottom, bottomMargin: 48.0, alignment: SubtitleAlignment.center, horizontalMargin: 24.0, verticalMargin: 24.0, safeAreaPadding: 20.0, respectNotch: true, keepInsideVideo: true)); }, icon: Icon(Symbols.restart_alt_rounded, color: cs.primary), label: Text(t.resetPositionButton, style: TextStyle(color: cs.primary))))),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.subBehaviorSection, Symbols.settings_rounded, _openSection == 2, () => setState(() => _openSection = _openSection == 2 ? -1 : 2)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 2 ? Column(children: [
              _switchTile(context, Symbols.subtitles_rounded, t.autoShowSubtitlesOption, t.autoShowSubtitlesSubtitle, s.showSubtitlesByDefault, s.setShowSubtitlesByDefault),
              _divider(),
              _choiceTile(context, Symbols.folder_open_rounded, t.subtitleFolderOption, s.subtitleFolder.isEmpty ? '---' : s.subtitleFolder, () async { final result = await FilePicker.getDirectoryPath(); if (result != null) s.setSubtitleFolder(result); }),
              _divider(),
              _choiceTile(context, Symbols.text_fields_rounded, t.subtitleEncodingOption, s.subtitleEncoding, () => showEncodingPicker(context, s)),
              _divider(),
              _choiceTile(context, Symbols.language_rounded, t.preferredSubtitleLanguageOption, langName(s.preferredSubtitleLanguage), () => showSubtitleLanguagePicker(context, s)),
              _divider(),
              _choiceTile(context, Symbols.timeline_rounded, t.defaultSyncOption, '${s.defaultSubtitleSync.toStringAsFixed(1)} s', () => showSyncDialog(context, s)),
              const SizedBox(height: 12),
              _behaviorSection(context, s, sub),
              const Divider(height: 1),
              Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Center(child: TextButton.icon(onPressed: () { s.setShowSubtitlesByDefault(true); s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.smart, autoShow: true, autoLanguage: 'ara', loadLastUsed: true, hideWhenNoDialog: false)); }, icon: Icon(Symbols.restart_alt_rounded, color: cs.primary), label: Text(t.resetBehaviorButton, style: TextStyle(color: cs.primary))))),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, t.subCompatibilitySection, Symbols.tune_rounded, _openSection == 3, () => setState(() => _openSection = _openSection == 3 ? -1 : 3)),
          AnimatedSize(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: Alignment.topCenter,
            child: _openSection == 3 ? Column(children: [
              _renderingSection(context, s, sub),
              const Divider(height: 1),
              Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Center(child: TextButton.icon(onPressed: () { s.updateSubtitleSettings(sub.copyWith(improveAnimation: true, complexTextRendering: true, improveSsaAss: true, ignoreAssFonts: false, ignoreAssEffects: false, fullUnicodeRtlSupport: true, improveAntiAliasing: true, hdrSupport: false)); }, icon: Icon(Symbols.restart_alt_rounded, color: cs.primary), label: Text(t.resetCompatibilityButton, style: TextStyle(color: cs.primary))))),
            ]) : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 16),

        _sectionHeader(context, t.librarySection, Symbols.video_library_rounded),
        _card(context, [
          _choiceTile(context, Symbols.sort_rounded, t.sortByOption, sortName(s.sortBy, t), () => showSortPicker(context, s)),
          _divider(),
          _switchTile(context, Symbols.arrow_downward_rounded, t.sortDescOption, '', s.sortDesc, s.setSortDesc),
          _divider(),
          _switchTile(context, Symbols.grid_view_rounded, t.libraryGridViewOption, '', s.libraryGridView, s.setLibraryGridView),
          _divider(),
          _switchTile(context, Symbols.grid_view_rounded, t.foldersGridViewOption, '', s.foldersGridView, s.setFoldersGridView),
          _divider(),
          _switchTile(context, Symbols.grid_view_rounded, t.recentGridViewOption, '', s.recentGridView, s.setRecentGridView),
          _divider(),
          _choiceTile(context, Symbols.visibility_off_rounded, t.hiddenFilesOption, '', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HiddenFilesScreen()))),
        ]),
        const SizedBox(height: 16),
        _sectionHeader(context, t.storageSection, Symbols.storage_rounded),
        _card(context, [
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(Symbols.image_rounded, color: cs.onSurfaceVariant, size: 22)),
            title: Text(t.thumbnailCacheOption),
            subtitle: Text(_cacheSizeBytes == null ? t.calculatingSize : _formatBytes(_cacheSizeBytes!)),
            trailing: TextButton(onPressed: _confirmClearCache, child: Text(t.clearCacheButton)),
          ),
        ]),
        const SizedBox(height: 16),
        _sectionHeader(context, t.backupSection, Symbols.backup_rounded),
        _card(context, [
          _choiceTile(context, Symbols.upload_rounded, t.exportSettingsOption, '', _exportSettings),
          _divider(),
          _choiceTile(context, Symbols.download_rounded, t.importSettingsOption, '', _importSettings),
        ]),
        const SizedBox(height: 32),
      ]),
    );
  }

  void _confirmReset(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.resetAllDialogTitle),
        content: Text(t.resetAllDialogBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancelButton)),
          TextButton(onPressed: () { s.resetAll(); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.settingsSavedMessage))); }, child: Text(t.confirmResetButton, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ],
      ),
    );
  }

  void _confirmClearCache() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.clearCacheDialogTitle),
        content: Text(t.clearCacheDialogBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancelButton)),
          TextButton(onPressed: () async { Navigator.pop(ctx); await ThumbnailService().clearCache(); await _loadCacheSize(); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.cacheClearedMessage))); }, child: Text(t.clearCacheButton, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ],
      ),
    );
  }

  Future<void> _exportSettings() async {
    final s = context.read<SettingsProvider>();
    final t = AppLocalizations.of(context)!;
    try {
      final dirPath = await FilePicker.getDirectoryPath();
      if (dirPath == null) return;
      final jsonStr = const JsonEncoder.withIndent('  ').convert(s.exportToJson());
      final file = File('$dirPath/sr_player_settings.json');
      await file.writeAsString(jsonStr);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.exportSuccessMessage(file.path))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.exportFailMessage(e.toString()))));
    }
  }

  Future<void> _importSettings() async {
    final s = context.read<SettingsProvider>();
    final t = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      final path = result?.files.single.path;
      if (path == null) return;
      final content = await File(path).readAsString();
      final Map<String, dynamic> jsonMap = json.decode(content) as Map<String, dynamic>;
      await s.importFromJson(jsonMap);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.importSuccessMessage)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.importFailMessage(e.toString()))));
    }
  }

  void _showDecoderPicker(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    final items = [{'value': 'auto', 'label': t.decoderAuto}, {'value': 'hw', 'label': t.decoderHW}, {'value': 'sw', 'label': t.decoderSW}];
    _showSimpleMenu(context, items, s.hwDecoderMode, (v) => s.setHwDecoderMode(v));
  }

  void _showColorFormatPicker(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    final items = [{'value': 'yuv', 'label': t.colorFormatYCbCr}, {'value': 'rgb_full', 'label': t.colorFormatRGBFull}, {'value': 'rgb_limited', 'label': t.colorFormatRGBLimited}];
    _showSimpleMenu(context, items, s.colorFormat, (v) => s.setColorFormat(v));
  }

  void _showSimpleMenu(BuildContext context, List<Map<String, String>> items, String currentValue, ValueChanged<String> onSelected) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: items.map((e) { final isSelected = e['value'] == currentValue; return ListTile(title: Text(e['label']!), trailing: isSelected ? Icon(Symbols.check_rounded, color: cs.primary) : null, onTap: () { onSelected(e['value']!); Navigator.pop(context); }); }).toList())));
  }

  String hwDecoderName(String mode, AppLocalizations t) { switch (mode) { case 'hw': return t.decoderHW; case 'sw': return t.decoderSW; default: return t.decoderAuto; } }
  String colorFormatName(String format, AppLocalizations t) { switch (format) { case 'rgb_full': return t.colorFormatRGBFull; case 'rgb_limited': return t.colorFormatRGBLimited; default: return t.colorFormatYCbCr; } }

  Widget _fontSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sliderRow(context, t.fontSizeOption, sub.fontSize, 10, 100, '${sub.fontSize.toInt()} px', (v) => s.updateSubtitleSettings(sub.copyWith(fontSize: v))),
      const SizedBox(height: 8),
      _choiceTile(context, Symbols.font_download_rounded, t.fontFamilyOption, sub.fontFamily, () => showFontPicker(context, s)),
      const SizedBox(height: 8),
      _sliderRow(context, t.subScaleOption, sub.subtitleScale, 0.5, 3.0, '${sub.subtitleScale.toStringAsFixed(1)}x', (v) => s.updateSubtitleSettings(sub.copyWith(subtitleScale: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.lineSpacingOption, sub.lineSpacing, 0.8, 2.0, '${sub.lineSpacing.toStringAsFixed(1)}x', (v) => s.updateSubtitleSettings(sub.copyWith(lineSpacing: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.maxLinesOption, sub.maxLines.toDouble(), 1, 6, '${sub.maxLines}', (v) => s.updateSubtitleSettings(sub.copyWith(maxLines: v.toInt()))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.wrap_text_rounded, t.wrapTextOption, t.wrapTextSubtitle, sub.autoWrap, (v) => s.updateSubtitleSettings(sub.copyWith(autoWrap: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.letterSpacingOption, sub.letterSpacing, -2, 10, '${sub.letterSpacing.toStringAsFixed(1)}', (v) => s.updateSubtitleSettings(sub.copyWith(letterSpacing: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.wordSpacingOption, sub.wordSpacing, -5, 20, '${sub.wordSpacing.toStringAsFixed(1)}', (v) => s.updateSubtitleSettings(sub.copyWith(wordSpacing: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.fontWeightOption, sub.fontWeightIndex.toDouble(), 0, 3, _fontWeightName(sub.fontWeightIndex, t), (v) => s.updateSubtitleSettings(sub.copyWith(fontWeightIndex: v.toInt()))),
      const SizedBox(height: 8),
      _sliderRow(context, t.textOpacityOption, sub.textOpacity, 0.1, 1.0, '${(sub.textOpacity * 100).toInt()}%', (v) => s.updateSubtitleSettings(sub.copyWith(textOpacity: v))),
    ]);
  }

  String _fontWeightName(int index, AppLocalizations t) { switch (index) { case 0: return t.fontWeightLight; case 1: return t.fontWeightNormal; case 2: return t.fontWeightSemiBold; case 3: return t.fontWeightBold; default: return t.fontWeightNormal; } }

  Widget _colorSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _colorRow(context, t.textColorOption, sub.textColor, (c) => s.updateSubtitleSettings(sub.copyWith(textColor: c))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.format_paint_rounded, t.backgroundSwitch, '', sub.bgOpacity > 0, (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v ? 0.65 : 0.0))),
      if (sub.bgOpacity > 0) ...[
        const SizedBox(height: 8),
        _colorRow(context, t.backgroundColorOption, sub.bgColor, (c) => s.updateSubtitleSettings(sub.copyWith(bgColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, t.backgroundOpacityOption, sub.bgOpacity, 0.1, 1.0, '${(sub.bgOpacity * 100).toInt()}%', (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v))),
        const SizedBox(height: 8),
        _sliderRow(context, t.backgroundRadiusOption, sub.bgBorderRadius, 0, 20, '${sub.bgBorderRadius.toInt()}', (v) => s.updateSubtitleSettings(sub.copyWith(bgBorderRadius: v))),
      ],
    ]);
  }

  Widget _effectsSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _switchTile(context, Symbols.border_color_rounded, t.outlineSwitch, t.outlineSubtitle, sub.outlineWidth > 0, (v) => s.updateSubtitleSettings(sub.copyWith(outlineWidth: v ? 2.0 : 0.0))),
      if (sub.outlineWidth > 0) ...[
        const SizedBox(height: 8),
        _colorRow(context, t.outlineColorOption, sub.outlineColor, (c) => s.updateSubtitleSettings(sub.copyWith(outlineColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, t.outlineWidthOption, sub.outlineWidth, 0.5, 6.0, sub.outlineWidth.toStringAsFixed(1), (v) => s.updateSubtitleSettings(sub.copyWith(outlineWidth: v))),
        const SizedBox(height: 8),
        _sliderRow(context, t.outlineScaleOption, sub.outlineScale, 0.5, 3.0, '${sub.outlineScale.toStringAsFixed(1)}x', (v) => s.updateSubtitleSettings(sub.copyWith(outlineScale: v))),
      ],
      const SizedBox(height: 8),
      _switchTile(context, Symbols.blur_on_rounded, t.shadowSwitch, t.shadowSubtitle, sub.shadowEnabled, (v) => s.updateSubtitleSettings(sub.copyWith(shadowEnabled: v))),
      if (sub.shadowEnabled) ...[
        const SizedBox(height: 8),
        _colorRow(context, t.shadowColorOption, sub.shadowColor, (c) => s.updateSubtitleSettings(sub.copyWith(shadowColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, t.shadowOpacityOption, sub.shadowOpacity, 0.1, 1.0, '${(sub.shadowOpacity * 100).toInt()}%', (v) => s.updateSubtitleSettings(sub.copyWith(shadowOpacity: v))),
        const SizedBox(height: 8),
        _sliderRow(context, t.shadowOffsetXOption, sub.shadowOffsetX, -10, 10, '${sub.shadowOffsetX.toInt()}', (v) => s.updateSubtitleSettings(sub.copyWith(shadowOffsetX: v))),
        const SizedBox(height: 8),
        _sliderRow(context, t.shadowOffsetYOption, sub.shadowOffsetY, -10, 10, '${sub.shadowOffsetY.toInt()}', (v) => s.updateSubtitleSettings(sub.copyWith(shadowOffsetY: v))),
        const SizedBox(height: 8),
        _sliderRow(context, t.shadowBlurOption, sub.shadowBlurRadius, 0, 20, '${sub.shadowBlurRadius.toInt()}', (v) => s.updateSubtitleSettings(sub.copyWith(shadowBlurRadius: v))),
      ],
    ]);
  }

  Widget _bgSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t.backgroundSection, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      _choiceTile(context, Symbols.shape_line_rounded, t.backgroundShapeOption, _bgShapeName(sub.bgShape, t), () => _showBgShapePicker(context, s, sub)),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.border_style_rounded, t.backgroundBorderSwitch, '', sub.bgBorderWidth > 0, (v) => s.updateSubtitleSettings(sub.copyWith(bgBorderWidth: v ? 2.0 : 0.0))),
      if (sub.bgBorderWidth > 0) ...[
        const SizedBox(height: 8),
        _colorRow(context, t.backgroundBorderColorOption, sub.bgBorderColor, (c) => s.updateSubtitleSettings(sub.copyWith(bgBorderColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, t.backgroundBorderWidthOption, sub.bgBorderWidth, 0.5, 6.0, '${sub.bgBorderWidth.toStringAsFixed(1)}', (v) => s.updateSubtitleSettings(sub.copyWith(bgBorderWidth: v))),
      ],
      const SizedBox(height: 8),
      _sliderRow(context, t.backgroundPaddingOption, sub.bgPadding, 0, 20, '${sub.bgPadding.toInt()} px', (v) => s.updateSubtitleSettings(sub.copyWith(bgPadding: v))),
    ]);
  }

  String _bgShapeName(SubtitleBgShape shape, AppLocalizations t) { switch (shape) { case SubtitleBgShape.rectangle: return t.backgroundShapeRectangle; case SubtitleBgShape.rounded: return t.backgroundShapeRounded; case SubtitleBgShape.capsule: return t.backgroundShapeCapsule; } }

  void _showBgShapePicker(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.backgroundShapeOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.backgroundShapeRectangle), leading: const Icon(Symbols.rectangle_rounded), trailing: sub.bgShape == SubtitleBgShape.rectangle ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(bgShape: SubtitleBgShape.rectangle)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.backgroundShapeRounded), leading: const Icon(Symbols.rounded_corner_rounded), trailing: sub.bgShape == SubtitleBgShape.rounded ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(bgShape: SubtitleBgShape.rounded)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.backgroundShapeCapsule), leading: const Icon(Symbols.circle_rounded), trailing: sub.bgShape == SubtitleBgShape.capsule ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(bgShape: SubtitleBgShape.capsule)); Navigator.pop(ctx); }),
    ])));
  }

  Widget _positionSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _choiceTile(context, Symbols.vertical_align_center_rounded, t.positionOption, _positionName(sub.position, t), () => _showPositionPicker(context, s, sub)),
      const SizedBox(height: 8),
      _sliderRow(context, t.bottomMarginOption, sub.bottomMargin, 0, 300, '${sub.bottomMargin.toInt()} px', (v) => s.updateSubtitleSettings(sub.copyWith(bottomMargin: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.horizontalMarginOption, sub.horizontalMargin, 0, 120, '${sub.horizontalMargin.toInt()} px', (v) => s.updateSubtitleSettings(sub.copyWith(horizontalMargin: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.verticalMarginOption, sub.verticalMargin, 0, 120, '${sub.verticalMargin.toInt()} px', (v) => s.updateSubtitleSettings(sub.copyWith(verticalMargin: v))),
      const SizedBox(height: 8),
      _sliderRow(context, t.safeAreaPaddingOption, sub.safeAreaPadding, 0, 60, '${sub.safeAreaPadding.toInt()} px', (v) => s.updateSubtitleSettings(sub.copyWith(safeAreaPadding: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.videocam_rounded, t.keepInsideVideoOption, t.keepInsideVideoSubtitle, sub.keepInsideVideo, (v) => s.updateSubtitleSettings(sub.copyWith(keepInsideVideo: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.smartphone_rounded, t.respectNotchOption, t.respectNotchSubtitle, sub.respectNotch, (v) => s.updateSubtitleSettings(sub.copyWith(respectNotch: v))),
    ]);
  }

  String _positionName(SubtitlePosition pos, AppLocalizations t) { switch (pos) { case SubtitlePosition.top: return t.positionTop; case SubtitlePosition.center: return t.positionCenter; case SubtitlePosition.bottom: return t.positionBottom; } }

  void _showPositionPicker(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.positionOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.positionTop), leading: const Icon(Symbols.vertical_align_top_rounded), trailing: sub.position == SubtitlePosition.top ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.top)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.positionCenter), leading: const Icon(Symbols.vertical_align_center_rounded), trailing: sub.position == SubtitlePosition.center ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.center)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.positionBottom), leading: const Icon(Symbols.vertical_align_bottom_rounded), trailing: sub.position == SubtitlePosition.bottom ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.bottom)); Navigator.pop(ctx); }),
    ])));
  }

  Widget _behaviorSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _choiceTile(context, Symbols.aspect_ratio_rounded, t.scaleModeOption, _scaleModeName(sub.scaleMode, t), () => _showScaleModePicker(context, s, sub)),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.history_rounded, t.loadLastUsedOption, '', sub.loadLastUsed, (v) => s.updateSubtitleSettings(sub.copyWith(loadLastUsed: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.voice_over_off_rounded, t.hideWhenNoDialogOption, '', sub.hideWhenNoDialog, (v) => s.updateSubtitleSettings(sub.copyWith(hideWhenNoDialog: v))),
    ]);
  }

  String _scaleModeName(SubtitleScaleMode mode, AppLocalizations t) { switch (mode) { case SubtitleScaleMode.fixed: return t.scaleModeFixed; case SubtitleScaleMode.byResolution: return t.scaleModeResolution; case SubtitleScaleMode.byWindow: return t.scaleModeWindow; case SubtitleScaleMode.smart: return t.scaleModeSmart; } }

  void _showScaleModePicker(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.scaleModeOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.scaleModeFixed), leading: const Icon(Symbols.lock_rounded), trailing: sub.scaleMode == SubtitleScaleMode.fixed ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.fixed)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.scaleModeResolution), leading: const Icon(Symbols.hd_rounded), trailing: sub.scaleMode == SubtitleScaleMode.byResolution ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.byResolution)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.scaleModeWindow), leading: const Icon(Symbols.smartphone_rounded), trailing: sub.scaleMode == SubtitleScaleMode.byWindow ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.byWindow)); Navigator.pop(ctx); }),
      ListTile(title: Text(t.scaleModeSmart), leading: const Icon(Symbols.auto_awesome_rounded), trailing: sub.scaleMode == SubtitleScaleMode.smart ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.smart)); Navigator.pop(ctx); }),
    ])));
  }

  Widget _renderingSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    final t = AppLocalizations.of(context)!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _switchTile(context, Symbols.animation_rounded, t.improveAnimationOption, '', sub.improveAnimation, (v) => s.updateSubtitleSettings(sub.copyWith(improveAnimation: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.text_fields_rounded, t.complexTextOption, '', sub.complexTextRendering, (v) => s.updateSubtitleSettings(sub.copyWith(complexTextRendering: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.closed_caption_rounded, t.improveSsaAssOption, '', sub.improveSsaAss, (v) => s.updateSubtitleSettings(sub.copyWith(improveSsaAss: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.font_download_off_rounded, t.ignoreAssFontsOption, '', sub.ignoreAssFonts, (v) => s.updateSubtitleSettings(sub.copyWith(ignoreAssFonts: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.movie_edit_rounded, t.ignoreAssEffectsOption, '', sub.ignoreAssEffects, (v) => s.updateSubtitleSettings(sub.copyWith(ignoreAssEffects: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.language_rounded, t.unicodeSupportOption, '', sub.fullUnicodeRtlSupport, (v) => s.updateSubtitleSettings(sub.copyWith(fullUnicodeRtlSupport: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.blur_on_rounded, t.antiAliasingOption, '', sub.improveAntiAliasing, (v) => s.updateSubtitleSettings(sub.copyWith(improveAntiAliasing: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.hdr_on_rounded, t.hdrSupportOption, '', sub.hdrSupport, (v) => s.updateSubtitleSettings(sub.copyWith(hdrSupport: v))),
    ]);
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 10), child: Row(children: [Icon(icon, size: 18, color: cs.primary), const SizedBox(width: 8), Text(title, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13))]));
  }

  Widget _sectionFoldHeader(BuildContext context, String title, IconData icon, bool isOpen, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: isOpen ? cs.primaryContainer : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: isOpen ? cs.onPrimaryContainer : cs.onSurfaceVariant, size: 22)), title: Text(title), trailing: Icon(isOpen ? Symbols.expand_less_rounded : Symbols.expand_more_rounded, color: cs.onSurfaceVariant), onTap: onTap);
  }

  Widget _card(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias, child: Column(children: children));
  }

  Widget _divider() => const Divider(height: 1, indent: 56);

  Widget _switchTile(BuildContext ctx, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final cs = Theme.of(ctx).colorScheme;
    return ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: value ? cs.primaryContainer : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: value ? cs.onPrimaryContainer : cs.onSurfaceVariant, size: 22)), title: Text(title), subtitle: subtitle.isNotEmpty ? Text(subtitle) : null, trailing: Switch(value: value, onChanged: onChanged), onTap: () => onChanged(!value));
  }

  Widget _choiceTile(BuildContext ctx, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return ListTile(leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: cs.onSurfaceVariant, size: 22)), title: Text(title), subtitle: Text(subtitle), trailing: Icon(Symbols.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20), onTap: onTap);
  }

  Widget _colorRow(BuildContext ctx, String label, Color color, ValueChanged<Color> onChanged) {
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16), title: Text(label), trailing: GestureDetector(onTap: () async { final picked = await showColorPickerDialog(ctx, color); onChanged(picked); }, child: ColorIndicator(color: color, width: 30, height: 30, borderRadius: 8)));
  }

  Widget _sliderRow(BuildContext ctx, String label, double value, double min, double max, String display, ValueChanged<double> onChanged) {
    final cs = Theme.of(ctx).colorScheme;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)), Text(display, style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 13))]), Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: cs.primary)]));
  }

  String loopModeName(String mode, AppLocalizations t) { switch (mode) { case 'video': return t.repeatVideo; case 'playlist': return t.repeatPlaylist; default: return t.repeatNone; } }
  String _videoModeName(String mode, AppLocalizations t) { switch (mode) { case 'cover': return t.videoModeCover; case 'fill': return t.videoModeFill; case 'stretch': return t.videoModeStretch; default: return t.videoModeContain; } }

  void _showLoopModePicker(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.repeatModeOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.repeatNone), leading: const Icon(Symbols.block_rounded), trailing: s.loopMode == 'none' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setLoopMode('none'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.repeatVideo), leading: const Icon(Symbols.repeat_one_rounded), trailing: s.loopMode == 'video' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setLoopMode('video'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.repeatPlaylist), leading: const Icon(Symbols.repeat_rounded), trailing: s.loopMode == 'playlist' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setLoopMode('playlist'); Navigator.pop(ctx); }),
    ])));
  }

  void _showVideoModePicker(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.defaultVideoModeOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.videoModeContain), leading: const Icon(Symbols.fit_screen_rounded), trailing: s.defaultVideoMode == 'contain' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setDefaultVideoMode('contain'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.videoModeCover), leading: const Icon(Symbols.fullscreen_rounded), trailing: s.defaultVideoMode == 'cover' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setDefaultVideoMode('cover'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.videoModeFill), leading: const Icon(Symbols.aspect_ratio_rounded), trailing: s.defaultVideoMode == 'fill' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setDefaultVideoMode('fill'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.videoModeStretch), leading: const Icon(Symbols.zoom_out_map_rounded), trailing: s.defaultVideoMode == 'stretch' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setDefaultVideoMode('stretch'); Navigator.pop(ctx); }),
    ])));
  }

  void _showSleepTimerPicker(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.sleepTimerOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.sleepTimerDisabled), leading: const Icon(Symbols.block_rounded), trailing: s.sleepTimerMinutes == 0 ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setSleepTimerMinutes(0); Navigator.pop(ctx); }),
      for (final mins in [15, 30, 60, 90, 120]) ListTile(title: Text(t.sleepTimerMinutes(mins)), leading: const Icon(Symbols.bedtime_rounded), trailing: s.sleepTimerMinutes == mins ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setSleepTimerMinutes(mins); Navigator.pop(ctx); }),
    ])));
  }

  String audioModeName(String mode, AppLocalizations t) { switch (mode) { case 'mono': return t.audioModeMono; case 'surround': return t.audioModeSurround; default: return t.audioModeStereo; } }

  void _showAudioModePicker(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text(t.audioOutputModeOption, style: const TextStyle(fontWeight: FontWeight.bold))),
      ListTile(title: Text(t.audioModeStereo), leading: const Icon(Symbols.speaker_rounded), trailing: s.audioOutputMode == 'stereo' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setAudioOutputMode('stereo'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.audioModeMono), leading: const Icon(Symbols.speaker_rounded), trailing: s.audioOutputMode == 'mono' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setAudioOutputMode('mono'); Navigator.pop(ctx); }),
      ListTile(title: Text(t.audioModeSurround), leading: const Icon(Symbols.surround_sound_rounded), trailing: s.audioOutputMode == 'surround' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null, onTap: () { s.setAudioOutputMode('surround'); Navigator.pop(ctx); }),
    ])));
  }

  void _showEqualizerDialog(BuildContext context, SettingsProvider s) {
    final t = AppLocalizations.of(context)!;
    final List<int> bandFrequencies = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: StatefulBuilder(
          builder: (ctx, setDialogState) {
            final bands = List<double>.from(s.equalizerBands);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 12), child: Text(t.equalizerDialogTitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w700, fontSize: 16))),
                  const Divider(height: 1),
                  for (int i = 0; i < bands.length; i++) _sliderRow(ctx, '${bandFrequencies[i]} Hz', bands[i], -20, 20, '${bands[i].toStringAsFixed(1)} dB', (v) { bands[i] = v; setDialogState(() {}); }),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancelButton)), const SizedBox(width: 8), ElevatedButton(onPressed: () { s.setEqualizerBands(bands); Navigator.pop(ctx); }, child: Text(t.applyButton))]),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}