import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

void showSubtitleSettingsSheet(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(16),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تخصيص الترجمة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white24),
            _buildSettingsContent(context),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSettingsContent(BuildContext context) {
  final s = context.watch<SettingsProvider>();
  final cs = Theme.of(context).colorScheme;

  return Column(mainAxisSize: MainAxisSize.min, children: [
    // حجم الخط
    ListTile(
      dense: true,
      title: const Text('حجم الخط', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: s.subtitleFontSize, min: 10, max: 150,
        onChanged: (v) => s.setSubtitleFontSize(v), activeColor: cs.primary,
      ),
    ),
    // نوع الخط
    ListTile(
      dense: true,
      title: const Text('نوع الخط', style: TextStyle(color: Colors.white)),
      subtitle: Text(s.fontFamily, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      onTap: () {
        _showFontPicker(context, s);
      },
    ),
    // لون النص
    ListTile(
      dense: true,
      title: const Text('لون النص', style: TextStyle(color: Colors.white)),
      trailing: GestureDetector(
        onTap: () async {
          final color = await showColorPickerDialog(context, s.subtitleColor);
          if (color != null) s.setSubtitleColor(color);
        },
        child: ColorIndicator(color: s.subtitleColor),
      ),
    ),
    // لون الخلفية مع زر تفعيل
    SwitchListTile(
      dense: true,
      title: const Text('لون الخلفية', style: TextStyle(color: Colors.white)),
      value: s.subtitleBgOpacity > 0,
      activeColor: cs.primary,
      onChanged: (v) {
        s.setSubtitleBgOpacity(v ? 0.6 : 0.0);
      },
      secondary: GestureDetector(
        onTap: () async {
          final color = await showColorPickerDialog(context, s.subtitleBgColor);
          if (color != null) s.setSubtitleBgColor(color);
        },
        child: ColorIndicator(color: s.subtitleBgColor),
      ),
    ),
    // شفافية الخلفية
    if (s.subtitleBgOpacity > 0)
      ListTile(
        dense: true,
        title: const Text('شفافية الخلفية', style: TextStyle(color: Colors.white)),
        subtitle: Slider(
          value: s.subtitleBgOpacity, min: 0.1, max: 1.0,
          onChanged: (v) => s.setSubtitleBgOpacity(v), activeColor: cs.primary,
        ),
      ),

    const Divider(color: Colors.white24),
    // ── ظل النص ──
    SwitchListTile(
      dense: true,
      title: const Text('ظل النص', style: TextStyle(color: Colors.white)),
      value: s.textShadowEnabled,
      activeColor: cs.primary,
      onChanged: (v) => s.setTextShadowEnabled(v),
    ),
    if (s.textShadowEnabled) ...[
      ListTile(
        dense: true,
        title: const Text('لون ظل النص', style: TextStyle(color: Colors.white70)),
        trailing: GestureDetector(
          onTap: () async {
            final color = await showColorPickerDialog(context, s.textShadowColor);
            if (color != null) s.setTextShadowColor(color);
          },
          child: ColorIndicator(color: s.textShadowColor),
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('حجم ظل النص', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.textShadowBlurRadius, min: 0, max: 20,
          onChanged: (v) => s.setTextShadowBlurRadius(v), activeColor: cs.primary,
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('إزاحة أفقية', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.textShadowOffsetX, min: -10, max: 10,
          onChanged: (v) => s.setTextShadowOffsetX(v), activeColor: cs.primary,
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('إزاحة رأسية', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.textShadowOffsetY, min: -10, max: 10,
          onChanged: (v) => s.setTextShadowOffsetY(v), activeColor: cs.primary,
        ),
      ),
    ],

    const Divider(color: Colors.white24),
    // ── ظل الصندوق (Box Shadow) ──
    SwitchListTile(
      dense: true,
      title: const Text('ظل الصندوق', style: TextStyle(color: Colors.white)),
      value: s.boxShadowEnabled,
      activeColor: cs.primary,
      onChanged: (v) => s.setBoxShadowEnabled(v),
    ),
    if (s.boxShadowEnabled) ...[
      ListTile(
        dense: true,
        title: const Text('لون ظل الصندوق', style: TextStyle(color: Colors.white70)),
        trailing: GestureDetector(
          onTap: () async {
            final color = await showColorPickerDialog(context, s.boxShadowColor);
            if (color != null) s.setBoxShadowColor(color);
          },
          child: ColorIndicator(color: s.boxShadowColor),
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('حجم ظل الصندوق', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.boxShadowBlurRadius, min: 0, max: 20,
          onChanged: (v) => s.setBoxShadowBlurRadius(v), activeColor: cs.primary,
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('إزاحة أفقية للصندوق', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.boxShadowOffsetX, min: -10, max: 10,
          onChanged: (v) => s.setBoxShadowOffsetX(v), activeColor: cs.primary,
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('إزاحة رأسية للصندوق', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.boxShadowOffsetY, min: -10, max: 10,
          onChanged: (v) => s.setBoxShadowOffsetY(v), activeColor: cs.primary,
        ),
      ),
    ],

    const Divider(color: Colors.white24),
    ListTile(
      dense: true,
      title: const Text('الهامش الأفقي', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: s.horizontalMargin, min: 0, max: 100,
        onChanged: (v) => s.setHorizontalMargin(v), activeColor: cs.primary,
      ),
    ),
    ListTile(
      dense: true,
      title: const Text('المسافة السفلية', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: s.bottomPadding, min: 0, max: 200,
        onChanged: (v) => s.setBottomPadding(v), activeColor: cs.primary,
      ),
    ),
  ]);
}

void _showFontPicker(BuildContext context, SettingsProvider s) {
  final fonts = <String>[
    'Roboto',
    'monospace',
    'serif',
    'sans-serif',
    'Cairo',
    'Amiri',
    'Noto Naskh Arabic',
  ];

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Text('اختر نوع الخط', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) => ListTile(
            title: Text(font, style: TextStyle(
              color: s.fontFamily == font ? Theme.of(context).colorScheme.primary : Colors.white,
              fontFamily: font,
            )),
            trailing: s.fontFamily == font
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              s.setFontFamily(font);
              Navigator.pop(ctx);
            },
          )).toList(),
        ),
      ),
    ),
  );
}