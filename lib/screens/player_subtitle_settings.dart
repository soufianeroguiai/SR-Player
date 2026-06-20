import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

void showSubtitleSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
    ListTile(
      dense: true,
      title: const Text('حجم الخط', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: s.subtitleFontSize, min: 10, max: 150,
        onChanged: (v) => s.setSubtitleFontSize(v), activeColor: cs.primary,
      ),
    ),
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
    ListTile(
      dense: true,
      title: const Text('لون الخلفية', style: TextStyle(color: Colors.white)),
      trailing: GestureDetector(
        onTap: () async {
          final color = await showColorPickerDialog(context, s.subtitleBgColor);
          if (color != null) s.setSubtitleBgColor(color);
        },
        child: ColorIndicator(color: s.subtitleBgColor),
      ),
    ),
    ListTile(
      dense: true,
      title: const Text('شفافية الخلفية', style: TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: s.subtitleBgOpacity, min: 0.0, max: 1.0,
        onChanged: (v) => s.setSubtitleBgOpacity(v), activeColor: cs.primary,
      ),
    ),
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
        title: const Text('لون الظل', style: TextStyle(color: Colors.white70)),
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
        title: const Text('حجم الظل', style: TextStyle(color: Colors.white70)),
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
          onChanged: (v) => s.setTextShadowOffsetX(v),
          activeColor: cs.primary,
        ),
      ),
      ListTile(
        dense: true,
        title: const Text('إزاحة رأسية', style: TextStyle(color: Colors.white70)),
        subtitle: Slider(
          value: s.textShadowOffsetY, min: -10, max: 10,
          onChanged: (v) => s.setTextShadowOffsetY(v),
          activeColor: cs.primary,
        ),
      ),
    ],
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