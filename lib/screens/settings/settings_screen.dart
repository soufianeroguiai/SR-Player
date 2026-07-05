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
    if (bytes <= 0) return '0 ميغابايت';
    final mb = bytes / (1024 * 1024);
    if (mb < 1) return '${(bytes / 1024).toStringAsFixed(0)} كيلوبايت';
    return '${mb.toStringAsFixed(1)} ميغابايت';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final sub = s.subtitleSettings;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: IconButton(icon: const Icon(Symbols.arrow_back_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _sectionHeader(context, 'عام', Symbols.settings_rounded),
        _card(context, [
          _choiceTile(context, Symbols.dark_mode_rounded, 'المظهر', themeName(s.themeMode), () => showThemePicker(context, s)),
          _divider(),
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: Icon(Symbols.palette_rounded, color: cs.onSurfaceVariant, size: 22),
            ),
            title: const Text('لون التطبيق'),
            subtitle: const Text('لون الواجهة الأساسي (Material You)'),
            trailing: GestureDetector(
              onTap: () => showThemeColorPicker(context, s),
              child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: s.themeSeedColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant),
                ),
              ),
            ),
            onTap: () => showThemeColorPicker(context, s),
          ),
        ]),
        const SizedBox(height: 16),

        // ==========================================
        //         المشغل (قسم موسع بالكامل)
        // ==========================================
        _sectionHeader(context, 'المشغل', Symbols.play_circle_rounded),

        // --- التشغيل ---
        _card(context, [
          _sectionFoldHeader(context, 'التشغيل', Symbols.play_arrow_rounded, _openSection == 100, () => setState(() => _openSection = _openSection == 100 ? -1 : 100)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 100
                ? Column(children: [
                    _switchTile(context, Symbols.play_arrow_rounded, 'التشغيل التلقائي', '', s.autoPlay, s.setAutoPlay),
                    _divider(),
                    _switchTile(context, Symbols.resume_rounded, 'استئناف آخر موضع', '', s.rememberPosition, s.setRememberPosition),
                    _divider(),
                    _switchTile(context, Symbols.speed_rounded, 'تذكر سرعة التشغيل', '', s.rememberPlaybackSpeed, s.setRememberPlaybackSpeed),
                    _divider(),
                    _choiceTile(context, Symbols.repeat_rounded, 'التشغيل المتكرر', loopModeName(s.loopMode), () => _showLoopModePicker(context, s)),
                    _divider(),
                    _switchTile(context, Symbols.skip_next_rounded, 'الانتقال للفيديو التالي تلقائياً', '', s.autoNextVideo, s.setAutoNextVideo),
                    _divider(),
                    _switchTile(context, Symbols.picture_in_picture_rounded, 'الانتقال للوضع المصغر عند الخروج', '', s.autoPipOnBackground, s.setAutoPipOnBackground),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- سرعة التشغيل ---
        _card(context, [
          _sectionFoldHeader(context, 'سرعة التشغيل', Symbols.speed_rounded, _openSection == 101, () => setState(() => _openSection = _openSection == 101 ? -1 : 101)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 101
                ? Column(children: [
                    _choiceTile(context, Symbols.speed_rounded, 'سرعة التشغيل الافتراضية', '${s.defaultSpeed}x', () => showSpeedPicker(context, s)),
                    _divider(),
                    _switchTile(context, Symbols.history_rounded, 'تذكر آخر سرعة', '', s.rememberSpeed, s.setRememberSpeed),
                    _divider(),
                    _switchTile(context, Symbols.fast_forward_rounded, 'السماح بسرعة حتى 4×', '', s.allowSpeedUpTo4x, s.setAllowSpeedUpTo4x),
                    _divider(),
                    _switchTile(context, Symbols.music_note_rounded, 'تصحيح طبقة الصوت (Pitch Correction)', '', s.pitchCorrection, s.setPitchCorrection),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- عرض الفيديو ---
        _card(context, [
          _sectionFoldHeader(context, 'عرض الفيديو', Symbols.aspect_ratio_rounded, _openSection == 102, () => setState(() => _openSection = _openSection == 102 ? -1 : 102)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 102
                ? Column(children: [
                    _choiceTile(context, Symbols.aspect_ratio_rounded, 'الوضع الافتراضي', videoModeName(s.defaultVideoMode), () => _showVideoModePicker(context, s)),
                    _divider(),
                    _switchTile(context, Symbols.history_rounded, 'تذكر آخر وضع', '', s.rememberVideoMode, s.setRememberVideoMode),
                    _divider(),
                    _switchTile(context, Symbols.screen_rotation_rounded, 'تدوير تلقائي', '', s.autoRotate, s.setAutoRotate),
                    _divider(),
                    _switchTile(context, Symbols.fullscreen_rounded, 'ملء الشاشة تلقائياً', '', s.autoFullscreen, s.setAutoFullscreen),
                    _divider(),
                    _switchTile(context, Symbols.screen_lock_landscape_rounded, 'إبقاء الشاشة مضاءة', '', s.keepScreenOn, s.setKeepScreenOn),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- التحكم بالإيماءات ---
        _card(context, [
          _sectionFoldHeader(context, 'التحكم بالإيماءات', Symbols.touch_app_rounded, _openSection == 103, () => setState(() => _openSection = _openSection == 103 ? -1 : 103)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 103
                ? Column(children: [
                    _switchTile(context, Symbols.volume_up_rounded, 'السحب للصوت', '', s.gestureVolume, s.setGestureVolume),
                    _divider(),
                    _switchTile(context, Symbols.brightness_6_rounded, 'السحب للسطوع', '', s.gestureBrightness, s.setGestureBrightness),
                    _divider(),
                    _switchTile(context, Symbols.fast_forward_rounded, 'السحب للتقديم والترجيع', '', s.gestureSeek, s.setGestureSeek),
                    _divider(),
                    _switchTile(context, Symbols.touch_app_rounded, 'النقر للإيقاف', '', s.tapToPause, s.setTapToPause),
                    _divider(),
                    _switchTile(context, Symbols.double_arrow_rounded, 'النقر المزدوج', '', s.doubleTapSeek, s.setDoubleTapSeek),
                    _divider(),
                    _switchTile(context, Symbols.speed_rounded, 'الضغط المطول = سرعة مؤقتة ×2', '', s.longPressSpeed, s.setLongPressSpeed),
                    _divider(),
                    _switchTile(context, Symbols.vibration_rounded, 'اهتزاز عند الوصول للنهاية', '', s.vibrateOnEnd, s.setVibrateOnEnd),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- التقديم والترجيع ---
        _card(context, [
          _sectionFoldHeader(context, 'التقديم والترجيع', Symbols.fast_rewind_rounded, _openSection == 104, () => setState(() => _openSection = _openSection == 104 ? -1 : 104)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 104
                ? Column(children: [
                    _choiceTile(context, Symbols.timeline_rounded, 'مدة التخطي', '${s.doubleTapSeekSeconds} ثوانٍ', () => showSeekSecondsPicker(context, s)),
                    _divider(),
                    _switchTile(context, Symbols.image_rounded, 'إظهار معاينة أثناء السحب', '', s.showSeekPreview, s.setShowSeekPreview),
                    _divider(),
                    _switchTile(context, Symbols.timer_rounded, 'إظهار الوقت أثناء السحب', '', s.showSeekTime, s.setShowSeekTime),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- واجهة المشغل ---
        _card(context, [
          _sectionFoldHeader(context, 'واجهة المشغل', Symbols.layers_rounded, _openSection == 105, () => setState(() => _openSection = _openSection == 105 ? -1 : 105)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 105
                ? Column(children: [
                    _switchTile(context, Symbols.visibility_off_rounded, 'إخفاء الأزرار تلقائياً', '', s.autoHideControls, s.setAutoHideControls),
                    if (s.autoHideControls) ...[
                      _divider(),
                      _choiceTile(context, Symbols.timer_rounded, 'مدة الإخفاء', '${s.controlsHideSeconds} ثوانٍ', () => showHideDelayPicker(context, s)),
                    ],
                    _divider(),
                    _switchTile(context, Symbols.timer_off_rounded, 'إظهار الوقت المتبقي', '', s.showRemainingTime, s.setShowRemainingTime),
                    _divider(),
                    _switchTile(context, Symbols.timer_rounded, 'إظهار الوقت المنقضي', '', s.showElapsedTime, s.setShowElapsedTime),
                    _divider(),
                    _switchTile(context, Symbols.title_rounded, 'إظهار اسم الفيديو', '', s.showVideoTitle, s.setShowVideoTitle),
                    _divider(),
                    _switchTile(context, Symbols.battery_full_rounded, 'إظهار البطارية', '', s.showBattery, s.setShowBattery),
                    _divider(),
                    _switchTile(context, Symbols.schedule_rounded, 'إظهار الساعة', '', s.showClock, s.setShowClock),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- القوائم ---
        _card(context, [
          _sectionFoldHeader(context, 'القوائم', Symbols.queue_music_rounded, _openSection == 106, () => setState(() => _openSection = _openSection == 106 ? -1 : 106)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 106
                ? Column(children: [
                    _switchTile(context, Symbols.auto_mode_rounded, 'التشغيل المتواصل', '', s.continuousPlayback, s.setContinuousPlayback),
                    _divider(),
                    _switchTile(context, Symbols.delete_rounded, 'إزالة الفيديو بعد التشغيل', '', s.removeVideoAfterPlayback, s.setRemoveVideoAfterPlayback),
                    _divider(),
                    _switchTile(context, Symbols.history_rounded, 'تذكر القائمة الأخيرة', '', s.rememberLastPlaylist, s.setRememberLastPlaylist),
                    _divider(),
                    _switchTile(context, Symbols.save_rounded, 'حفظ ترتيب التشغيل', '', s.savePlaylistOrder, s.setSavePlaylistOrder),
                    _divider(),
                    _switchTile(context, Symbols.shuffle_rounded, 'تشغيل عشوائي', '', s.shufflePlaylist, s.setShufflePlaylist),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- الطاقة ---
        _card(context, [
          _sectionFoldHeader(context, 'الطاقة', Symbols.battery_saver_rounded, _openSection == 107, () => setState(() => _openSection = _openSection == 107 ? -1 : 107)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 107
                ? Column(children: [
                    _switchTile(context, Symbols.screen_lock_landscape_rounded, 'منع قفل الشاشة', '', s.preventScreenLock, s.setPreventScreenLock),
                    _divider(),
                    _switchTile(context, Symbols.brightness_4_rounded, 'خفض السطوع عند التوقف', '', s.reduceBrightnessOnPause, s.setReduceBrightnessOnPause),
                    _divider(),
                    _switchTile(context, Symbols.stop_rounded, 'إيقاف التشغيل بعد انتهاء الفيديو', '', s.stopAfterVideo, s.setStopAfterVideo),
                    _divider(),
                    _choiceTile(context, Symbols.bedtime_rounded, 'مؤقت النوم (Sleep Timer)', s.sleepTimerMinutes == 0 ? 'معطل' : '${s.sleepTimerMinutes} دقيقة', () => _showSleepTimerPicker(context, s)),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- التحكم ---
        _card(context, [
          _sectionFoldHeader(context, 'التحكم', Symbols.gamepad_rounded, _openSection == 108, () => setState(() => _openSection = _openSection == 108 ? -1 : 108)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 108
                ? Column(children: [
                    _switchTile(context, Symbols.volume_up_rounded, 'أزرار الصوت للتقديم', '', s.volumeKeysSeek, s.setVolumeKeysSeek),
                    _divider(),
                    _switchTile(context, Symbols.keyboard_rounded, 'دعم لوحة المفاتيح', '', s.keyboardSupport, s.setKeyboardSupport),
                    _divider(),
                    _switchTile(context, Symbols.gamepad_rounded, 'دعم يد التحكم', '', s.gamepadSupport, s.setGamepadSupport),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        // --- خيارات متقدمة ---
        _card(context, [
          _sectionFoldHeader(context, 'خيارات متقدمة', Symbols.settings_rounded, _openSection == 109, () => setState(() => _openSection = _openSection == 109 ? -1 : 109)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 109
                ? Column(children: [
                    _choiceTile(context, Symbols.memory_rounded, 'وضع فك التشفير', hwDecoderName(s.hwDecoderMode), () => _showDecoderPicker(context, s)),
                    _divider(),
                    _switchTile(context, Symbols.auto_fix_high_rounded, 'الرجوع إلى Software عند الفشل', '', s.fallbackToSoftware, s.setFallbackToSoftware),
                    _divider(),
                    _switchTile(context, Symbols.speed_rounded, 'تشغيل منخفض التأخير', '', s.lowLatencyPlayback, s.setLowLatencyPlayback),
                    _divider(),
                    _switchTile(context, Symbols.video_stable_rounded, 'Frame Dropping', '', s.frameDropping, s.setFrameDropping),
                    _divider(),
                    _switchTile(context, Symbols.video_settings_rounded, 'VSync', '', s.vsync, s.setVsync),
                    _divider(),
                    _switchTile(context, Symbols.bug_report_rounded, 'Logging', '', s.loggingEnabled, s.setLoggingEnabled),
                    _divider(),
                    _switchTile(context, Symbols.info_rounded, 'إظهار معلومات الفيديو', '', s.showVideoInfo, s.setShowVideoInfo),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 16),

        // ==========================================
        //                الصوت
        // ==========================================
        _sectionHeader(context, 'الصوت', Symbols.graphic_eq_rounded),

        _card(context, [
          _sectionFoldHeader(context, 'الصوت العام', Symbols.volume_up_rounded, _openSection == 4, () => setState(() => _openSection = _openSection == 4 ? -1 : 4)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 4
                ? Column(children: [
                    _choiceTile(context, Symbols.volume_up_rounded, 'تضخيم الصوت الافتراضي', '${s.defaultAudioBoost.round()}%', () => showBoostDialog(context, s)),
                    _divider(),
                    _sliderRow(context, 'موازنة الصوت (Balance)', s.audioBalance, -1.0, 1.0, s.audioBalance.toStringAsFixed(1), (v) => s.setAudioBalance(v)),
                    _divider(),
                    _switchTile(context, Symbols.volume_up_rounded, 'تذكر مستوى الصوت لكل فيديو', '', s.rememberVolumePerVideo, s.setRememberVolumePerVideo),
                    _divider(),
                    _switchTile(context, Symbols.restart_alt_rounded, 'إعادة ضبط مستوى الصوت لكل فيديو', '', s.resetVolumePerVideo, s.setResetVolumePerVideo),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'إخراج الصوت', Symbols.speaker_rounded, _openSection == 5, () => setState(() => _openSection = _openSection == 5 ? -1 : 5)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 5
                ? Column(children: [
                    _choiceTile(context, Symbols.speaker_rounded, 'وضع إخراج الصوت', s.audioOutputMode == 'stereo' ? 'ستيريو' : s.audioOutputMode == 'mono' ? 'أحادي' : 'محيطي', () => _showAudioModePicker(context, s)),
                    _divider(),
                    _switchTile(context, Symbols.bluetooth_rounded, 'التحويل التلقائي عند توصيل سماعة', '', s.autoSwitchBluetooth, s.setAutoSwitchBluetooth),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'المسارات الصوتية', Symbols.playlist_play_rounded, _openSection == 6, () => setState(() => _openSection = _openSection == 6 ? -1 : 6)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 6
                ? Column(children: [
                    _choiceTile(context, Symbols.language_rounded, 'لغة الصوت المفضلة', langName(s.preferredAudioLanguage), () => showAudioLanguagePicker(context, s)),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'معادل الصوت', Symbols.equalizer_rounded, _openSection == 7, () => setState(() => _openSection = _openSection == 7 ? -1 : 7)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 7
                ? Column(children: [
                    _switchTile(context, Symbols.equalizer_rounded, 'تشغيل المعادل', '', s.bassBoost, s.setBassBoost),
                    if (s.bassBoost) ...[
                      _divider(),
                      _choiceTile(context, Symbols.tune_rounded, 'فتح المعادل الرسومي', '10 نطاقات', () => _showEqualizerDialog(context, s)),
                    ],
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'مزامنة الصوت', Symbols.timeline_rounded, _openSection == 8, () => setState(() => _openSection = _openSection == 8 ? -1 : 8)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 8
                ? Column(children: [
                    _sliderRow(context, 'تأخير الصوت (ms)', s.audioDelayMs.toDouble(), -5000, 5000, '${s.audioDelayMs} ms', (v) => s.setAudioDelayMs(v.toInt())),
                    _divider(),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => s.setAudioDelayMs(0),
                        icon: Icon(Symbols.restart_alt_rounded, color: cs.primary),
                        label: Text('إعادة ضبط', style: TextStyle(color: cs.primary)),
                      ),
                    ),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'معالجة الصوت', Symbols.hearing_rounded, _openSection == 9, () => setState(() => _openSection = _openSection == 9 ? -1 : 9)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 9
                ? Column(children: [
                    _switchTile(context, Symbols.surround_sound_rounded, 'صوت محيطي (Surround)', 'محاكاة صوت محيطي', s.surroundSound, s.setSurroundSound),
                    _divider(),
                    _switchTile(context, Symbols.equalizer_rounded, 'Bass Boost', 'تضخيم الترددات المنخفضة', s.bassBoost, s.setBassBoost),
                  ])
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 16),

        // ==========================================
        //                الترجمة
        // ==========================================
        _sectionHeader(context, 'الترجمة', Symbols.subtitles_rounded),

        _card(context, [
          _sectionFoldHeader(context, 'المظهر', Symbols.palette_rounded, _openSection == 0, () => setState(() => _openSection = _openSection == 0 ? -1 : 0)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 0
                ? Column(
                    children: [
                      _fontSection(context, s, sub),
                      const SizedBox(height: 12),
                      _colorSection(context, s, sub),
                      const SizedBox(height: 12),
                      _effectsSection(context, s, sub),
                      const SizedBox(height: 12),
                      _bgSection(context, s, sub),
                      const SizedBox(height: 12),
                      _switchTile(context, Symbols.format_italic_rounded, 'تأثير مائل', 'تفعيل الخط المائل للترجمة', s.subtitleItalic, s.setSubtitleItalic),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () {
                              s.updateSubtitleSettings(sub.copyWith(
                                fontSize: 30.0, subtitleScale: 1.0, fontFamily: 'Roboto',
                                textColor: const Color(0xFFFFFFFF), textOpacity: 1.0,
                                fontWeightIndex: 2, outlineColor: const Color(0xFF000000),
                                outlineWidth: 2.0, outlineScale: 1.0,
                                shadowEnabled: false, shadowColor: const Color(0xFF000000),
                                shadowOpacity: 0.5, shadowOffsetX: 2.0, shadowOffsetY: 2.0,
                                shadowBlurRadius: 4.0, bgColor: const Color(0xFF000000),
                                bgOpacity: 0.0, bgBorderRadius: 4.0, bgBorderColor: const Color(0xFFFFFFFF),
                                bgBorderWidth: 0.0, bgPadding: 8.0, bgShape: SubtitleBgShape.rounded,
                                letterSpacing: 0.0, wordSpacing: 0.0,
                                lineHeight: 1.2, lineSpacing: 1.0, autoWrap: true, maxLines: 2,
                              ));
                              s.setSubtitleItalic(false);
                            },
                            icon: Icon(Symbols.restart_alt_rounded, color: cs.primary),
                            label: Text('إعادة ضبط المظهر', style: TextStyle(color: cs.primary)),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'الموضع', Symbols.open_with_rounded, _openSection == 1, () => setState(() => _openSection = _openSection == 1 ? -1 : 1)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 1
                ? Column(
                    children: [
                      _positionSection(context, s, sub),
                      const SizedBox(height: 12),
                      _switchTile(context, Symbols.format_textdirection_r_to_l_rounded, 'اتجاه النص',
                          sub.alignment == SubtitleAlignment.right ? 'من اليمين إلى اليسار' : 'من اليسار إلى اليمين',
                          sub.alignment == SubtitleAlignment.right,
                          (v) => s.updateSubtitleSettings(sub.copyWith(alignment: v ? SubtitleAlignment.right : SubtitleAlignment.left))),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () {
                              s.updateSubtitleSettings(sub.copyWith(
                                position: SubtitlePosition.bottom, bottomMargin: 48.0,
                                alignment: SubtitleAlignment.center, horizontalMargin: 24.0,
                                verticalMargin: 24.0, safeAreaPadding: 20.0,
                                respectNotch: true, keepInsideVideo: true,
                              ));
                            },
                            icon: Icon(Symbols.restart_alt_rounded, color: cs.primary),
                            label: Text('إعادة ضبط الموضع', style: TextStyle(color: cs.primary)),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'السلوك', Symbols.settings_rounded, _openSection == 2, () => setState(() => _openSection = _openSection == 2 ? -1 : 2)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 2
                ? Column(
                    children: [
                      _switchTile(context, Symbols.subtitles_rounded, 'إظهار الترجمة تلقائياً', 'تفعيل عند بدء التشغيل', s.showSubtitlesByDefault, s.setShowSubtitlesByDefault),
                      _divider(),
                      _choiceTile(context, Symbols.folder_open_rounded, 'مجلد الترجمة', s.subtitleFolder.isEmpty ? 'غير محدد' : s.subtitleFolder, () async {
                        final result = await FilePicker.getDirectoryPath();
                        if (result != null) s.setSubtitleFolder(result);
                      }),
                      _divider(),
                      _choiceTile(context, Symbols.text_fields_rounded, 'ترميز الأحرف', s.subtitleEncoding, () => showEncodingPicker(context, s)),
                      _divider(),
                      _choiceTile(context, Symbols.language_rounded, 'لغة الترجمة المفضلة', langName(s.preferredSubtitleLanguage), () => showSubtitleLanguagePicker(context, s)),
                      _divider(),
                      _choiceTile(context, Symbols.timeline_rounded, 'مزامنة افتراضية', '${s.defaultSubtitleSync.toStringAsFixed(1)} ثانية', () => showSyncDialog(context, s)),
                      const SizedBox(height: 12),
                      _behaviorSection(context, s, sub),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () {
                              s.setShowSubtitlesByDefault(true);
                              s.updateSubtitleSettings(sub.copyWith(
                                scaleMode: SubtitleScaleMode.smart, autoShow: true,
                                autoLanguage: 'ara', loadLastUsed: true, hideWhenNoDialog: false,
                              ));
                            },
                            icon: Icon(Symbols.restart_alt_rounded, color: cs.primary),
                            label: Text('إعادة ضبط السلوك', style: TextStyle(color: cs.primary)),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),
        const SizedBox(height: 12),

        _card(context, [
          _sectionFoldHeader(context, 'التوافق', Symbols.tune_rounded, _openSection == 3, () => setState(() => _openSection = _openSection == 3 ? -1 : 3)),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _openSection == 3
                ? Column(
                    children: [
                      _renderingSection(context, s, sub),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () {
                              s.updateSubtitleSettings(sub.copyWith(
                                improveAnimation: true, complexTextRendering: true,
                                improveSsaAss: true, ignoreAssFonts: false,
                                ignoreAssEffects: false, fullUnicodeRtlSupport: true,
                                improveAntiAliasing: true, hdrSupport: false,
                              ));
                            },
                            icon: Icon(Symbols.restart_alt_rounded, color: cs.primary),
                            label: Text('إعادة ضبط التوافق', style: TextStyle(color: cs.primary)),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ]),

        const SizedBox(height: 16),
        _sectionHeader(context, 'المكتبة', Symbols.video_library_rounded),
        _card(context, [
          _choiceTile(context, Symbols.sort_rounded, 'الترتيب الافتراضي', sortName(s.sortBy), () => showSortPicker(context, s)),
          _divider(),
          _switchTile(context, Symbols.arrow_downward_rounded, 'ترتيب تنازلي', 'من الأحدث إلى الأقدم', s.sortDesc, s.setSortDesc),
          _divider(),
          _switchTile(context, Symbols.grid_view_rounded, 'عرض شبكي للمكتبة', 'عرض فيديوهات المكتبة كبطاقات', s.libraryGridView, s.setLibraryGridView),
          _divider(),
          _switchTile(context, Symbols.grid_view_rounded, 'عرض شبكي للمجلدات', 'عرض المجلدات كبطاقات', s.foldersGridView, s.setFoldersGridView),
          _divider(),
          _switchTile(context, Symbols.grid_view_rounded, 'عرض شبكي للأخيرة', 'عرض قائمة الأخيرة كبطاقات', s.recentGridView, s.setRecentGridView),
          _divider(),
          _choiceTile(context, Symbols.visibility_off_rounded, 'الملفات المخفية', 'عرض وإظهار الملفات المخفية',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HiddenFilesScreen()))),
        ]),
        const SizedBox(height: 16),
        _sectionHeader(context, 'التخزين', Symbols.storage_rounded),
        _card(context, [
          ListTile(
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: Icon(Symbols.image_rounded, color: cs.onSurfaceVariant, size: 22),
            ),
            title: const Text('ذاكرة الصور المصغرة'),
            subtitle: Text(_cacheSizeBytes == null ? 'جارٍ الحساب...' : _formatBytes(_cacheSizeBytes!)),
            trailing: TextButton(
              onPressed: _confirmClearCache,
              child: const Text('مسح'),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        _sectionHeader(context, 'النسخ الاحتياطي', Symbols.backup_rounded),
        _card(context, [
          _choiceTile(context, Symbols.upload_rounded, 'تصدير الإعدادات', 'حفظ نسخة من كل الإعدادات كملف', _exportSettings),
          _divider(),
          _choiceTile(context, Symbols.download_rounded, 'استيراد الإعدادات', 'استعادة الإعدادات من ملف محفوظ', _importSettings),
        ]),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => _confirmReset(context, s),
            icon: Icon(Symbols.restart_alt_rounded, color: cs.error),
            label: Text('استعادة الإعدادات الافتراضية', style: TextStyle(color: cs.error)),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  // --- دوال الحفظ والتصدير ---
  void _confirmReset(BuildContext context, SettingsProvider s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة الإعدادات'),
        content: const Text('هل تريد إعادة جميع الإعدادات إلى الوضع الافتراضي؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              s.resetAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استعادة الإعدادات')));
            },
            child: Text('استعادة', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح ذاكرة الصور المصغرة'),
        content: const Text('سيتم حذف كل الصور المصغرة المخزَّنة، وستُعاد توليدها تلقائياً عند فتح المكتبة من جديد.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ThumbnailService().clearCache();
              await _loadCacheSize();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم مسح ذاكرة الصور المصغرة')));
              }
            },
            child: Text('مسح', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSettings() async {
    final s = context.read<SettingsProvider>();
    try {
      final dirPath = await FilePicker.getDirectoryPath();
      if (dirPath == null) return;
      final jsonStr = const JsonEncoder.withIndent('  ').convert(s.exportToJson());
      final file = File('$dirPath/sr_player_settings.json');
      await file.writeAsString(jsonStr);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ الإعدادات في: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التصدير: $e')));
      }
    }
  }

  Future<void> _importSettings() async {
    final s = context.read<SettingsProvider>();
    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      final path = result?.files.single.path;
      if (path == null) return;
      final content = await File(path).readAsString();
      final Map<String, dynamic> jsonMap = json.decode(content) as Map<String, dynamic>;
      await s.importFromJson(jsonMap);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استيراد الإعدادات بنجاح')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الاستيراد: $e')));
      }
    }
  }

  void _showDecoderPicker(BuildContext context, SettingsProvider s) {
    final items = [
      {'value': 'auto', 'label': 'تلقائي (موصى)'},
      {'value': 'hw', 'label': 'HW+ (عتاد)'},
      {'value': 'sw', 'label': 'SW (برمجي)'},
    ];
    _showSimpleMenu(context, items, s.hwDecoderMode, (v) => s.setHwDecoderMode(v));
  }

  void _showColorFormatPicker(BuildContext context, SettingsProvider s) {
    final items = [
      {'value': 'yuv', 'label': 'YCbCr (افتراضي)'},
      {'value': 'rgb_full', 'label': 'RGB Full (ألوان حيوية)'},
      {'value': 'rgb_limited', 'label': 'RGB Limited'},
    ];
    _showSimpleMenu(context, items, s.colorFormat, (v) => s.setColorFormat(v));
  }

  void _showSimpleMenu(BuildContext context, List<Map<String, String>> items, String currentValue, ValueChanged<String> onSelected) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: items.map((e) {
          final isSelected = e['value'] == currentValue;
          return ListTile(
            title: Text(e['label']!),
            trailing: isSelected ? Icon(Symbols.check_rounded, color: cs.primary) : null,
            onTap: () {
              onSelected(e['value']!);
              Navigator.pop(context);
            },
          );
        }).toList()),
      ),
    );
  }

  String hwDecoderName(String mode) {
    switch (mode) {
      case 'hw': return 'HW+ (عتاد)';
      case 'sw': return 'SW (برمجي)';
      default: return 'تلقائي (موصى)';
    }
  }

  String colorFormatName(String format) {
    switch (format) {
      case 'rgb_full': return 'RGB Full (ألوان حيوية)';
      case 'rgb_limited': return 'RGB Limited';
      default: return 'YCbCr (افتراضي)';
    }
  }

  // --- أقسام الترجمة المتقدمة ---
  Widget _fontSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sliderRow(context, 'حجم الخط', sub.fontSize, 10, 100, '${sub.fontSize.toInt()} px',
          (v) => s.updateSubtitleSettings(sub.copyWith(fontSize: v))),
      const SizedBox(height: 8),
      _choiceTile(context, Symbols.font_download_rounded, 'نوع الخط', sub.fontFamily,
          () => showFontPicker(context, s)),
      const SizedBox(height: 8),
      _sliderRow(context, 'مقياس الترجمة', sub.subtitleScale, 0.5, 3.0, '${sub.subtitleScale.toStringAsFixed(1)}x',
          (v) => s.updateSubtitleSettings(sub.copyWith(subtitleScale: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'تباعد الأسطر', sub.lineSpacing, 0.8, 2.0, '${sub.lineSpacing.toStringAsFixed(1)}x',
          (v) => s.updateSubtitleSettings(sub.copyWith(lineSpacing: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'أقصى عدد للأسطر', sub.maxLines.toDouble(), 1, 6, '${sub.maxLines}',
          (v) => s.updateSubtitleSettings(sub.copyWith(maxLines: v.toInt()))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.wrap_text_rounded, 'لف النص', 'لف النص التلقائي للترجمة',
          sub.autoWrap,
          (v) => s.updateSubtitleSettings(sub.copyWith(autoWrap: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'تباعد الحروف', sub.letterSpacing, -2, 10, '${sub.letterSpacing.toStringAsFixed(1)}',
          (v) => s.updateSubtitleSettings(sub.copyWith(letterSpacing: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'تباعد الكلمات', sub.wordSpacing, -5, 20, '${sub.wordSpacing.toStringAsFixed(1)}',
          (v) => s.updateSubtitleSettings(sub.copyWith(wordSpacing: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'سمك الخط', sub.fontWeightIndex.toDouble(), 0, 3, _fontWeightName(sub.fontWeightIndex),
          (v) => s.updateSubtitleSettings(sub.copyWith(fontWeightIndex: v.toInt()))),
      const SizedBox(height: 8),
      _sliderRow(context, 'شفافية النص', sub.textOpacity, 0.1, 1.0, '${(sub.textOpacity * 100).toInt()}%',
          (v) => s.updateSubtitleSettings(sub.copyWith(textOpacity: v))),
    ]);
  }

  String _fontWeightName(int index) {
    switch (index) {
      case 0: return 'خفيف';
      case 1: return 'عادي';
      case 2: return 'شبه عريض';
      case 3: return 'عريض جداً';
      default: return 'عادي';
    }
  }

  Widget _colorSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _colorRow(context, 'لون النص', sub.textColor,
          (c) => s.updateSubtitleSettings(sub.copyWith(textColor: c))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.format_paint_rounded, 'خلفية النص', '',
          sub.bgOpacity > 0,
          (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v ? 0.65 : 0.0))),
      if (sub.bgOpacity > 0) ...[
        const SizedBox(height: 8),
        _colorRow(context, 'لون الخلفية', sub.bgColor,
            (c) => s.updateSubtitleSettings(sub.copyWith(bgColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, 'شفافية الخلفية', sub.bgOpacity, 0.1, 1.0, '${(sub.bgOpacity * 100).toInt()}%',
            (v) => s.updateSubtitleSettings(sub.copyWith(bgOpacity: v))),
        const SizedBox(height: 8),
        _sliderRow(context, 'زوايا الخلفية', sub.bgBorderRadius, 0, 20, '${sub.bgBorderRadius.toInt()}',
            (v) => s.updateSubtitleSettings(sub.copyWith(bgBorderRadius: v))),
      ],
    ]);
  }

  Widget _effectsSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _switchTile(context, Symbols.border_color_rounded, 'حدّ خارجي للنص', 'إطار حول كل حرف',
          sub.outlineWidth > 0,
          (v) => s.updateSubtitleSettings(sub.copyWith(outlineWidth: v ? 2.0 : 0.0))),
      if (sub.outlineWidth > 0) ...[
        const SizedBox(height: 8),
        _colorRow(context, 'لون الحدّ', sub.outlineColor,
            (c) => s.updateSubtitleSettings(sub.copyWith(outlineColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, 'سماكة الحدّ', sub.outlineWidth, 0.5, 6.0, sub.outlineWidth.toStringAsFixed(1),
            (v) => s.updateSubtitleSettings(sub.copyWith(outlineWidth: v))),
        const SizedBox(height: 8),
        _sliderRow(context, 'مقياس مستقل للحدود', sub.outlineScale, 0.5, 3.0, '${sub.outlineScale.toStringAsFixed(1)}x',
            (v) => s.updateSubtitleSettings(sub.copyWith(outlineScale: v))),
      ],
      const SizedBox(height: 8),
      _switchTile(context, Symbols.blur_on_rounded, 'ظل النص', 'ظل خلف نص الترجمة',
          sub.shadowEnabled,
          (v) => s.updateSubtitleSettings(sub.copyWith(shadowEnabled: v))),
      if (sub.shadowEnabled) ...[
        const SizedBox(height: 8),
        _colorRow(context, 'لون الظل', sub.shadowColor,
            (c) => s.updateSubtitleSettings(sub.copyWith(shadowColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, 'شفافية الظل', sub.shadowOpacity, 0.1, 1.0, '${(sub.shadowOpacity * 100).toInt()}%',
            (v) => s.updateSubtitleSettings(sub.copyWith(shadowOpacity: v))),
        const SizedBox(height: 8),
        _sliderRow(context, 'إزاحة أفقية', sub.shadowOffsetX, -10, 10, '${sub.shadowOffsetX.toInt()}',
            (v) => s.updateSubtitleSettings(sub.copyWith(shadowOffsetX: v))),
        const SizedBox(height: 8),
        _sliderRow(context, 'إزاحة رأسية', sub.shadowOffsetY, -10, 10, '${sub.shadowOffsetY.toInt()}',
            (v) => s.updateSubtitleSettings(sub.copyWith(shadowOffsetY: v))),
        const SizedBox(height: 8),
        _sliderRow(context, 'تمويه الظل', sub.shadowBlurRadius, 0, 20, '${sub.shadowBlurRadius.toInt()}',
            (v) => s.updateSubtitleSettings(sub.copyWith(shadowBlurRadius: v))),
      ],
    ]);
  }

  Widget _bgSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('الخلفية', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      _choiceTile(context, Symbols.shape_line_rounded, 'شكل الخلفية', _bgShapeName(sub.bgShape),
          () => _showBgShapePicker(context, s, sub)),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.border_style_rounded, 'حدود الخلفية', 'تفعيل حدود حول صندوق الترجمة',
          sub.bgBorderWidth > 0,
          (v) => s.updateSubtitleSettings(sub.copyWith(bgBorderWidth: v ? 2.0 : 0.0))),
      if (sub.bgBorderWidth > 0) ...[
        const SizedBox(height: 8),
        _colorRow(context, 'لون الحدود', sub.bgBorderColor,
            (c) => s.updateSubtitleSettings(sub.copyWith(bgBorderColor: c))),
        const SizedBox(height: 8),
        _sliderRow(context, 'سماكة الحدود', sub.bgBorderWidth, 0.5, 6.0, '${sub.bgBorderWidth.toStringAsFixed(1)}',
            (v) => s.updateSubtitleSettings(sub.copyWith(bgBorderWidth: v))),
      ],
      const SizedBox(height: 8),
      _sliderRow(context, 'Padding الخلفية', sub.bgPadding, 0, 20, '${sub.bgPadding.toInt()} px',
          (v) => s.updateSubtitleSettings(sub.copyWith(bgPadding: v))),
    ]);
  }

  String _bgShapeName(SubtitleBgShape shape) {
    switch (shape) {
      case SubtitleBgShape.rectangle: return 'مستطيل';
      case SubtitleBgShape.rounded: return 'مدور';
      case SubtitleBgShape.capsule: return 'كبسولة';
    }
  }

  void _showBgShapePicker(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('شكل الخلفية', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('مستطيل'),
            leading: const Icon(Symbols.rectangle_rounded),
            trailing: sub.bgShape == SubtitleBgShape.rectangle ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(bgShape: SubtitleBgShape.rectangle));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('مدور'),
            leading: const Icon(Symbols.rounded_corner_rounded),
            trailing: sub.bgShape == SubtitleBgShape.rounded ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(bgShape: SubtitleBgShape.rounded));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('كبسولة'),
            leading: const Icon(Symbols.circle_rounded),
            trailing: sub.bgShape == SubtitleBgShape.capsule ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(bgShape: SubtitleBgShape.capsule));
              Navigator.pop(ctx);
            },
          ),
        ]),
      ),
    );
  }

  Widget _positionSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _choiceTile(context, Symbols.vertical_align_center_rounded, 'موضع الترجمة', _positionName(sub.position),
          () => _showPositionPicker(context, s, sub)),
      const SizedBox(height: 8),
      _sliderRow(context, 'الارتفاع عن الأسفل', sub.bottomMargin, 0, 300, '${sub.bottomMargin.toInt()} px',
          (v) => s.updateSubtitleSettings(sub.copyWith(bottomMargin: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'الهامش الأفقي', sub.horizontalMargin, 0, 120, '${sub.horizontalMargin.toInt()} px',
          (v) => s.updateSubtitleSettings(sub.copyWith(horizontalMargin: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'الهامش العمودي', sub.verticalMargin, 0, 120, '${sub.verticalMargin.toInt()} px',
          (v) => s.updateSubtitleSettings(sub.copyWith(verticalMargin: v))),
      const SizedBox(height: 8),
      _sliderRow(context, 'هامش الأمان', sub.safeAreaPadding, 0, 60, '${sub.safeAreaPadding.toInt()} px',
          (v) => s.updateSubtitleSettings(sub.copyWith(safeAreaPadding: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.videocam_rounded, 'البقاء داخل الفيديو', 'عدم خروج الترجمة خارج حدود الفيديو',
          sub.keepInsideVideo,
          (v) => s.updateSubtitleSettings(sub.copyWith(keepInsideVideo: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.smartphone_rounded, 'احترام النوتش', 'تجنب منطقة الثقب أو النوتش',
          sub.respectNotch,
          (v) => s.updateSubtitleSettings(sub.copyWith(respectNotch: v))),
    ]);
  }

  String _positionName(SubtitlePosition pos) {
    switch (pos) {
      case SubtitlePosition.top: return 'أعلى';
      case SubtitlePosition.center: return 'وسط';
      case SubtitlePosition.bottom: return 'أسفل';
    }
  }

  void _showPositionPicker(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('موضع الترجمة', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('أعلى'),
            leading: const Icon(Symbols.vertical_align_top_rounded),
            trailing: sub.position == SubtitlePosition.top ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.top));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('وسط'),
            leading: const Icon(Symbols.vertical_align_center_rounded),
            trailing: sub.position == SubtitlePosition.center ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.center));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('أسفل'),
            leading: const Icon(Symbols.vertical_align_bottom_rounded),
            trailing: sub.position == SubtitlePosition.bottom ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(position: SubtitlePosition.bottom));
              Navigator.pop(ctx);
            },
          ),
        ]),
      ),
    );
  }

  Widget _behaviorSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _choiceTile(context, Symbols.aspect_ratio_rounded, 'طريقة قياس الترجمة', _scaleModeName(sub.scaleMode),
          () => _showScaleModePicker(context, s, sub)),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.history_rounded, 'تحميل آخر ترجمة مستخدمة', 'استخدام آخر ترجمة تم تحميلها',
          sub.loadLastUsed,
          (v) => s.updateSubtitleSettings(sub.copyWith(loadLastUsed: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.voice_over_off_rounded, 'إخفاء الترجمة عند عدم وجود حوار', 'لترجمات SSA/ASS فقط',
          sub.hideWhenNoDialog,
          (v) => s.updateSubtitleSettings(sub.copyWith(hideWhenNoDialog: v))),
    ]);
  }

  String _scaleModeName(SubtitleScaleMode mode) {
    switch (mode) {
      case SubtitleScaleMode.fixed: return 'حجم ثابت';
      case SubtitleScaleMode.byResolution: return 'حسب دقة الفيديو';
      case SubtitleScaleMode.byWindow: return 'حسب حجم النافذة';
      case SubtitleScaleMode.smart: return 'ذكي (موصى به)';
    }
  }

  void _showScaleModePicker(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('طريقة قياس الترجمة', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('حجم ثابت'),
            subtitle: const Text('نفس الحجم لجميع الفيديوهات'),
            leading: const Icon(Symbols.lock_rounded),
            trailing: sub.scaleMode == SubtitleScaleMode.fixed ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.fixed));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('حسب دقة الفيديو'),
            subtitle: const Text('أكبر لدقة أعلى، أصغر لدقة أقل'),
            leading: const Icon(Symbols.hd_rounded),
            trailing: sub.scaleMode == SubtitleScaleMode.byResolution ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.byResolution));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('حسب حجم النافذة'),
            subtitle: const Text('أكبر لشاشة أكبر، أصغر لشاشة أصغر'),
            leading: const Icon(Symbols.smartphone_rounded),
            trailing: sub.scaleMode == SubtitleScaleMode.byWindow ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.byWindow));
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('ذكي (موصى به)'),
            subtitle: const Text('يجمع بين دقة الفيديو وحجم الشاشة'),
            leading: const Icon(Symbols.auto_awesome_rounded),
            trailing: sub.scaleMode == SubtitleScaleMode.smart ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () {
              s.updateSubtitleSettings(sub.copyWith(scaleMode: SubtitleScaleMode.smart));
              Navigator.pop(ctx);
            },
          ),
        ]),
      ),
    );
  }

  Widget _renderingSection(BuildContext context, SettingsProvider s, SubtitleSettings sub) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _switchTile(context, Symbols.animation_rounded, 'تحسين حركة الخط', 'حركة أكثر سلاسة',
          sub.improveAnimation,
          (v) => s.updateSubtitleSettings(sub.copyWith(improveAnimation: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.text_fields_rounded, 'تحسين معالجة النصوص المعقدة', 'للنصوص العربية والهندية',
          sub.complexTextRendering,
          (v) => s.updateSubtitleSettings(sub.copyWith(complexTextRendering: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.closed_caption_rounded, 'تحسين عرض SSA/ASS', 'معالجة أفضل لترجمات الأنمي',
          sub.improveSsaAss,
          (v) => s.updateSubtitleSettings(sub.copyWith(improveSsaAss: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.font_download_off_rounded, 'تجاهل الخط المحدد داخل ASS', 'استخدام خط التطبيق بدلاً من خط الملف',
          sub.ignoreAssFonts,
          (v) => s.updateSubtitleSettings(sub.copyWith(ignoreAssFonts: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.movie_edit_rounded, 'تجاهل بعض تأثيرات ASS', 'إزالة الحركات والتدرجات',
          sub.ignoreAssEffects,
          (v) => s.updateSubtitleSettings(sub.copyWith(ignoreAssEffects: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.language_rounded, 'دعم Unicode الكامل', 'دعم كل اللغات ورموزها',
          sub.fullUnicodeRtlSupport,
          (v) => s.updateSubtitleSettings(sub.copyWith(fullUnicodeRtlSupport: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.blur_on_rounded, 'تحسين Anti-Aliasing', 'تنعيم حواف النص والحدود',
          sub.improveAntiAliasing,
          (v) => s.updateSubtitleSettings(sub.copyWith(improveAntiAliasing: v))),
      const SizedBox(height: 8),
      _switchTile(context, Symbols.hdr_on_rounded, 'دعم HDR', 'لشاشات HDR إن أمكن',
          sub.hdrSupport,
          (v) => s.updateSubtitleSettings(sub.copyWith(hdrSupport: v))),
    ]);
  }

  // --- دوال واجهة المستخدم المساعدة ---
  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }

  Widget _sectionFoldHeader(BuildContext context, String title, IconData icon, bool isOpen, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isOpen ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isOpen ? cs.onPrimaryContainer : cs.onSurfaceVariant, size: 22),
      ),
      title: Text(title),
      trailing: Icon(
        isOpen ? Symbols.expand_less_rounded : Symbols.expand_more_rounded,
        color: cs.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56);

  Widget _switchTile(BuildContext ctx, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    final cs = Theme.of(ctx).colorScheme;
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: value ? cs.primaryContainer : cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: value ? cs.onPrimaryContainer : cs.onSurfaceVariant, size: 22)),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: Switch(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }

  Widget _choiceTile(BuildContext ctx, IconData icon, String title, String subtitle, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: cs.onSurfaceVariant, size: 22)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Symbols.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
      onTap: onTap,
    );
  }

  Widget _colorRow(BuildContext ctx, String label, Color color, ValueChanged<Color> onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label),
      trailing: GestureDetector(
        onTap: () async {
          final picked = await showColorPickerDialog(ctx, color);
          onChanged(picked);
        },
        child: ColorIndicator(color: color, width: 30, height: 30, borderRadius: 8),
      ),
    );
  }

  Widget _sliderRow(BuildContext ctx, String label, double value, double min, double max, String display, ValueChanged<double> onChanged) {
    final cs = Theme.of(ctx).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          Text(display, style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 13)),
        ]),
        Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: cs.primary),
      ]),
    );
  }

  // --- دوال إعدادات المشغل الجديدة ---
  String loopModeName(String mode) {
    switch (mode) {
      case 'video': return 'تكرار الفيديو';
      case 'playlist': return 'تكرار القائمة';
      default: return 'بدون';
    }
  }

  void _showLoopModePicker(BuildContext context, SettingsProvider s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('التشغيل المتكرر', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('بدون'),
            leading: const Icon(Symbols.block_rounded),
            trailing: s.loopMode == 'none' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setLoopMode('none'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('تكرار الفيديو'),
            leading: const Icon(Symbols.repeat_one_rounded),
            trailing: s.loopMode == 'video' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setLoopMode('video'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('تكرار القائمة'),
            leading: const Icon(Symbols.repeat_rounded),
            trailing: s.loopMode == 'playlist' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setLoopMode('playlist'); Navigator.pop(ctx); },
          ),
        ]),
      ),
    );
  }

  String videoModeName(String mode) {
    switch (mode) {
      case 'cover': return 'Cover';
      case 'fill': return 'Fill';
      case 'stretch': return 'Stretch';
      default: return 'Contain';
    }
  }

  void _showVideoModePicker(BuildContext context, SettingsProvider s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('الوضع الافتراضي', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Contain'),
            leading: const Icon(Symbols.fit_screen_rounded),
            trailing: s.defaultVideoMode == 'contain' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setDefaultVideoMode('contain'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('Cover'),
            leading: const Icon(Symbols.fullscreen_rounded),
            trailing: s.defaultVideoMode == 'cover' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setDefaultVideoMode('cover'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('Fill'),
            leading: const Icon(Symbols.aspect_ratio_rounded),
            trailing: s.defaultVideoMode == 'fill' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setDefaultVideoMode('fill'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('Stretch'),
            leading: const Icon(Symbols.zoom_out_map_rounded),
            trailing: s.defaultVideoMode == 'stretch' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setDefaultVideoMode('stretch'); Navigator.pop(ctx); },
          ),
        ]),
      ),
    );
  }

  void _showSleepTimerPicker(BuildContext context, SettingsProvider s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('مؤقت النوم', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('معطل'),
            leading: const Icon(Symbols.block_rounded),
            trailing: s.sleepTimerMinutes == 0 ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setSleepTimerMinutes(0); Navigator.pop(ctx); },
          ),
          for (final mins in [15, 30, 60, 90, 120])
            ListTile(
              title: Text('$mins دقيقة'),
              leading: const Icon(Symbols.bedtime_rounded),
              trailing: s.sleepTimerMinutes == mins ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
              onTap: () { s.setSleepTimerMinutes(mins); Navigator.pop(ctx); },
            ),
        ]),
      ),
    );
  }

  // --- دوال إعدادات الصوت (محفوظة) ---
  void _showAudioModePicker(BuildContext context, SettingsProvider s) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('وضع إخراج الصوت', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('ستيريو'),
            leading: const Icon(Symbols.speaker_rounded),
            trailing: s.audioOutputMode == 'stereo' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setAudioOutputMode('stereo'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('أحادي'),
            leading: const Icon(Symbols.speaker_rounded),
            trailing: s.audioOutputMode == 'mono' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setAudioOutputMode('mono'); Navigator.pop(ctx); },
          ),
          ListTile(
            title: const Text('محيطي'),
            leading: const Icon(Symbols.surround_sound_rounded),
            trailing: s.audioOutputMode == 'surround' ? Icon(Symbols.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setAudioOutputMode('surround'); Navigator.pop(ctx); },
          ),
        ]),
      ),
    );
  }

  void _showEqualizerDialog(BuildContext context, SettingsProvider s) {
    final List<int> bandFrequencies = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final bands = List<double>.from(s.equalizerBands);
          return AlertDialog(
            title: const Text('المعادل الرسومي'),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < bands.length; i++)
                      _sliderRow(ctx, '${bandFrequencies[i]} Hz', bands[i], -20, 20, '${bands[i].toStringAsFixed(1)} dB', (v) {
                        bands[i] = v;
                        setDialogState(() {});
                      }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  s.setEqualizerBands(bands);
                  Navigator.pop(ctx);
                },
                child: const Text('تطبيق'),
              ),
            ],
          );
        },
      ),
    );
  }
}