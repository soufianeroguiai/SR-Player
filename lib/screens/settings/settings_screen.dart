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
  int _openSection = 0;
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
        _sectionHeader(context, 'المشغل', Symbols.play_circle_rounded),
        _card(context, [
          _switchTile(context, Symbols.resume_rounded, 'تذكر موضع التشغيل', 'متابعة من آخر موضع', s.rememberPosition, s.setRememberPosition),
          _divider(),
          _switchTile(context, Symbols.notifications_off_rounded, 'استئناف صامت', 'متابعة من الموضع بدون إظهار تنبيه', s.silentResume, s.setSilentResume),
          _divider(),
          _switchTile(context, Symbols.play_arrow_rounded, 'تشغيل تلقائي', 'تشغيل الفيديو فور الفتح', s.autoPlay, s.setAutoPlay),
          _divider(),
          _choiceTile(context, Symbols.speed_rounded, 'سرعة التشغيل الافتراضية', '${s.defaultSpeed}x', () => showSpeedPicker(context, s)),
          _divider(),
          _choiceTile(context, Symbols.fast_forward_rounded, 'مدة القفز عند النقر المزدوج', '${s.doubleTapSeekSeconds} ثوانٍ', () => showSeekSecondsPicker(context, s)),
          _divider(),
          _choiceTile(context, Symbols.timer_rounded, 'مدة اختفاء أزرار التحكم', '${s.controlsHideSeconds} ثوانٍ', () => showHideDelayPicker(context, s)),
          _divider(),
          _switchTile(context, Symbols.fast_forward_rounded, 'تسريع بالضغط المطول', 'تسريع مؤقت عند الضغط باستمرار', s.longPressSpeedEnabled, s.setLongPressSpeedEnabled),
          if (s.longPressSpeedEnabled) ...[
            _divider(),
            _choiceTile(context, Symbols.speed_rounded, 'سرعة الضغط المطول', '${s.longPressSpeedValue.toStringAsFixed(1)}x', () => showLongPressSpeedDialog(context, s)),
          ],
          _divider(),
          _choiceTile(context, Symbols.touch_app_rounded, 'حساسية الإيماءات', '${(s.gestureSensitivity * 100).round()}%', () => showGestureSensitivityDialog(context, s)),
          _divider(),
          _switchTile(context, Symbols.screen_rotation_rounded, 'تدوير الشاشة الذكي', 'حسب وضعية الهاتف تلقائياً', s.smartRotationEnabled, s.setSmartRotationEnabled),
          _divider(),
          _switchTile(context, Symbols.picture_in_picture_rounded, 'صورة داخل صورة تلقائياً', 'عند الخروج من التطبيق أثناء التشغيل', s.autoPipOnBackground, s.setAutoPipOnBackground),
          _divider(),
          _choiceTile(
            context,
            Symbols.memory_rounded,
            'وضع فك التشفير',
            hwDecoderName(s.hwDecoderMode),
            () => _showDecoderPicker(context, s),
          ),
          _divider(),
          _choiceTile(
            context,
            Symbols.palette_rounded,
            'تنسيق الألوان',
            colorFormatName(s.colorFormat),
            () => _showColorFormatPicker(context, s),
          ),
        ]),
        const SizedBox(height: 16),
        _sectionHeader(context, 'الصوت', Symbols.graphic_eq_rounded),
        _card(context, [
          _choiceTile(context, Symbols.volume_up_rounded, 'تضخيم الصوت الافتراضي', '${s.defaultAudioBoost.round()}%', () => showBoostDialog(context, s)),
          _divider(),
          _choiceTile(context, Symbols.language_rounded, 'لغة الصوت المفضلة', langName(s.preferredAudioLanguage), () => showAudioLanguagePicker(context, s)),
        ]),
        const SizedBox(height: 16),
        _sectionHeader(context, 'الترجمة', Symbols.subtitles_rounded),

        // قسم المظهر
        _card(context, [
          _sectionFoldHeader(context, 'المظهر', Symbols.palette_rounded, _openSection == 0, () => setState(() => _openSection = _openSection == 0 ? -1 : 0)),
          if (_openSection == 0) ...[
            _fontSection(context, s, sub),
            const SizedBox(height: 12),
            _colorSection(context, s, sub),
            const SizedBox(height: 12),
            _effectsSection(context, s, sub),
            const SizedBox(height: 12),
            _switchTile(context, Symbols.format_italic_rounded, 'تأثير مائل', 'تفعيل الخط المائل للترجمة', s.subtitleItalic, s.setSubtitleItalic),
            const Divider(height: 1),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  s.updateSubtitleSettings(sub.copyWith(
                    fontSize: 30.0, subtitleScale: 1.0, fontFamily: 'Roboto',
                    textColor: const Color(0xFFFFFFFF), fontWeightIndex: 2,
                    outlineColor: const Color(0xFF000000), outlineWidth: 2.0,
                    shadowEnabled: false, shadowColor: const Color(0xFF000000),
                    shadowOpacity: 0.5, shadowOffsetX: 2.0, shadowOffsetY: 2.0,
                    shadowBlurRadius: 4.0, bgColor: const Color(0xFF000000),
                    bgOpacity: 0.0, bgBorderRadius: 4.0, letterSpacing: 0.0,
                    lineHeight: 1.2, lineSpacing: 1.0, autoWrap: true, maxLines: 2,
                  ));
                  s.setSubtitleItalic(false);
                },
                icon: Icon(Symbols.restart_alt_rounded, color: cs.primary),
                label: Text('إعادة ضبط المظهر', style: TextStyle(color: cs.primary)),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 12),

        // قسم الموضع
        _card(context, [
          _sectionFoldHeader(context, 'الموضع', Symbols.open_with_rounded, _openSection == 1, () => setState(() => _openSection = _openSection == 1 ? -1 : 1)),
          if (_openSection == 1) ...[
            _positionSection(context, s, sub),
            const SizedBox(height: 12),
            _switchTile(context, Symbols.format_textdirection_r_to_l_rounded, 'اتجاه النص',
                sub.alignment == SubtitleAlignment.right ? 'من اليمين إلى اليسار' : 'من اليسار إلى اليمين',
                sub.alignment == SubtitleAlignment.right,
                (v) => s.updateSubtitleSettings(sub.copyWith(alignment: v ? SubtitleAlignment.right : SubtitleAlignment.left))),
            const Divider(height: 1),
            Center(
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
          ],
        ]),
        const SizedBox(height: 12),

        // قسم السلوك
        _card(context, [
          _sectionFoldHeader(context, 'السلوك', Symbols.settings_rounded, _openSection == 2, () => setState(() => _openSection = _openSection == 2 ? -1 : 2)),
          if (_openSection == 2) ...[
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
            Center(
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
          ],
        ]),
        const SizedBox(height: 12),

        // قسم التوافق
        _card(context, [
          _sectionFoldHeader(context, 'التوافق', Symbols.tune_rounded, _openSection == 3, () => setState(() => _openSection = _openSection == 3 ? -1 : 3)),
          if (_openSection == 3) ...[
            _renderingSection(context, s, sub),
            const Divider(height: 1),
            Center(
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
          ],
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

  // --- دوال الحفظ والتصدير وإعدادات أخرى ---
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
      _sliderRow(context, 'سمك الخط', sub.fontWeightIndex.toDouble(), 0, 3, _fontWeightName(sub.fontWeightIndex),
          (v) => s.updateSubtitleSettings(sub.copyWith(fontWeightIndex: v.toInt()))),
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

  // --- عناصر الواجهة المساعدة ---
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
}