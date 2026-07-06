import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../providers/settings_provider.dart';
import '../../models/subtitle_settings.dart';
import '../../l10n/app_localizations.dart';
import 'settings_widgets.dart';

void showFontPicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  final fonts = [
    ('Roboto', 'Roboto'),
    ('Cairo', 'Cairo'),
    ('Amiri', 'Amiri'),
    ('Noto Naskh Arabic', 'Noto Naskh'),
    ('Tajawal', 'Tajawal'),
    ('monospace', 'Monospace'),
  ];
  final currentFont = s.subtitleSettings.fontFamily;
  showDialog(
    context: ctx,
    builder: (context) => SimpleDialog(
      title: Text(t.chooseFont),
      children: fonts.map((f) => RadioListTile<String>(
        title: Text(f.$2),
        value: f.$1,
        groupValue: currentFont,
        onChanged: (v) {
          s.updateSubtitleSettings(s.subtitleSettings.copyWith(fontFamily: v!));
          Navigator.pop(context);
        },
      )).toList(),
    ),
  );
}

void showBoostDialog(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showDialog(
    context: ctx,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(t.chooseBoost),
        content: Slider(
          value: s.defaultAudioBoost,
          min: 50,
          max: 200,
          divisions: 30,
          label: '${s.defaultAudioBoost.round()}%',
          onChanged: (v) {
            s.setDefaultAudioBoost(v);
            setDialogState(() {});
          },
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.okButton))],
      ),
    ),
  );
}

void showAudioLanguagePicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  final langs = {
    'ara': t.arabicLanguageOption,
    'eng': t.englishLanguageOption,
    'fra': t.frenchLanguageOption,
    'spa': 'Español',
    'jpn': '日本語',
  };
  showDialog(
    context: ctx,
    builder: (context) => SimpleDialog(
      title: Text(t.chooseAudioLanguage),
      children: langs.entries.map((e) => RadioListTile<String>(
        title: Text(e.value),
        value: e.key,
        groupValue: s.preferredAudioLanguage,
        onChanged: (v) { s.setPreferredAudioLanguage(v!); Navigator.pop(context); },
      )).toList(),
    ),
  );
}

void showEncodingPicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  const encodings = ['UTF-8', 'UTF-16', 'Windows-1256', 'ISO-8859-6'];
  showDialog(
    context: ctx,
    builder: (context) => SimpleDialog(
      title: Text(t.chooseEncoding),
      children: encodings.map((enc) => RadioListTile<String>(
        title: Text(enc),
        value: enc,
        groupValue: s.subtitleEncoding,
        onChanged: (v) { s.setSubtitleEncoding(v!); Navigator.pop(context); },
      )).toList(),
    ),
  );
}

void showSubtitleLanguagePicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  final langs = {
    'ara': t.arabicLanguageOption,
    'eng': t.englishLanguageOption,
    'fra': t.frenchLanguageOption,
    'spa': 'Español',
    'deu': 'Deutsch',
    'ita': 'Italiano',
  };
  showDialog(
    context: ctx,
    builder: (context) => SimpleDialog(
      title: Text(t.chooseSubtitleLanguage),
      children: langs.entries.map((e) => RadioListTile<String>(
        title: Text(e.value),
        value: e.key,
        groupValue: s.subtitleSettings.autoLanguage,
        onChanged: (v) {
          s.updateSubtitleSettings(s.subtitleSettings.copyWith(autoLanguage: v!));
          Navigator.pop(context);
        },
      )).toList(),
    ),
  );
}

void showSyncDialog(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  final controller = TextEditingController(text: s.defaultSubtitleSync.toStringAsFixed(1));
  showDialog(
    context: ctx,
    builder: (context) => AlertDialog(
      title: Text(t.syncDefault),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(hintText: t.exampleSync),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(controller.text);
            if (value != null) s.setDefaultSubtitleSync(value);
            Navigator.pop(context);
          },
          child: Text(t.okButton),
        ),
      ],
    ),
  );
}

void showThemePicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showBottomPicker<ThemeMode>(
    ctx,
    title: t.chooseAppearance,
    currentValue: s.themeMode,
    items: [
      (ThemeMode.dark, t.themeDark, Symbols.dark_mode_rounded),
      (ThemeMode.light, t.themeLight, Symbols.light_mode_rounded),
      (ThemeMode.system, t.themeSystem, Symbols.brightness_auto_rounded),
    ],
    onSelected: s.setThemeMode,
  );
}

void showLanguagePicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showBottomPicker<String>(
    ctx,
    title: t.chooseLanguage,
    currentValue: s.appLanguageCode,
    items: [
      ('system', t.systemLanguageOption, Symbols.smartphone_rounded),
      ('ar', t.arabicLanguageOption, Symbols.language_rounded),
      ('en', t.englishLanguageOption, Symbols.language_rounded),
      ('fr', t.frenchLanguageOption, Symbols.language_rounded),
    ],
    onSelected: s.setAppLanguageCode,
  );
}

void showSpeedPicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  final cs = Theme.of(ctx).colorScheme;
  showModalBottomSheet(
    context: ctx,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Text(t.playbackSpeedTitle, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        const Divider(height: 1),
        ...[0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((sp) => ListTile(
          title: Text('${sp}x'),
          trailing: s.defaultSpeed == sp ? Icon(Symbols.check_rounded, color: cs.primary) : null,
          onTap: () { s.setDefaultSpeed(sp); Navigator.pop(ctx); },
        )),
      ]),
    ),
  );
}

void showSortPicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showBottomPicker<String>(
    ctx,
    title: t.sortByTitle,
    currentValue: s.sortBy,
    items: [
      ('date', t.sortByDate, Symbols.calendar_today_rounded),
      ('name', t.sortByName, Symbols.sort_by_alpha_rounded),
      ('size', t.sortBySize, Symbols.data_usage_rounded),
      ('duration', t.sortByDuration, Symbols.timer_rounded),
    ],
    onSelected: s.setSortBy,
  );
}

void showSeekSecondsPicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showBottomPicker<int>(
    ctx,
    title: t.doubleTapSeekTitle,
    currentValue: s.doubleTapSeekSeconds,
    items: [
      (5, t.seconds5, Symbols.fast_rewind_rounded),
      (10, t.seconds10, Symbols.fast_rewind_rounded),
      (15, t.seconds15, Symbols.fast_rewind_rounded),
      (30, t.seconds30, Symbols.fast_rewind_rounded),
    ],
    onSelected: s.setDoubleTapSeekSeconds,
  );
}

void showHideDelayPicker(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showBottomPicker<int>(
    ctx,
    title: t.controlsHideDelayTitle,
    currentValue: s.controlsHideSeconds,
    items: [
      (2, t.seconds2, Symbols.timer_rounded),
      (4, t.seconds4, Symbols.timer_rounded),
      (6, t.seconds6, Symbols.timer_rounded),
      (10, t.seconds10b, Symbols.timer_rounded),
    ],
    onSelected: s.setControlsHideSeconds,
  );
}

void showLongPressSpeedDialog(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showDialog(
    context: ctx,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(t.longPressSpeedTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s.longPressSpeedValue.toStringAsFixed(2)}x'),
            Slider(
              value: s.longPressSpeedValue,
              min: 1.5,
              max: 4.0,
              divisions: 10,
              label: '${s.longPressSpeedValue.toStringAsFixed(2)}x',
              onChanged: (v) {
                s.setLongPressSpeedValue(v);
                setDialogState(() {});
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.okButton))],
      ),
    ),
  );
}

void showGestureSensitivityDialog(BuildContext ctx, SettingsProvider s) {
  final t = AppLocalizations.of(ctx)!;
  showDialog(
    context: ctx,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(t.gestureSensitivityTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${(s.gestureSensitivity * 100).round()}%'),
            Slider(
              value: s.gestureSensitivity,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: '${(s.gestureSensitivity * 100).round()}%',
              onChanged: (v) {
                s.setGestureSensitivity(v);
                setDialogState(() {});
              },
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.okButton))],
      ),
    ),
  );
}

void showThemeColorPicker(BuildContext ctx, SettingsProvider s) async {
  final picked = await showColorPickerDialog(ctx, s.themeSeedColor);
  s.setThemeSeedColor(picked);
}