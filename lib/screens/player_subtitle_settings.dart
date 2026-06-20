import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

// دالة مساعدة لإنشاء أشرطة التمرير بشكل أنيق مع الأرقام
Widget _buildSliderRow({
  required String title,
  required double value,
  required double min,
  required double max,
  required String label,
  required ValueChanged<double> onChanged,
  required Color activeColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text(label, style: TextStyle(color: activeColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: activeColor),
        ),
      ],
    ),
  );
}

// واجهة التخصيص المحسنة
Widget buildSubtitleSettingsContent(BuildContext context) {
  final s = context.watch<SettingsProvider>();
  final cs = Theme.of(context).colorScheme;

  return Directionality(
    textDirection: TextDirection.rtl, // ضمان المحاذاة العربية دائماً
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, 
      children: [
        // ── الخط والحجم ──
        _buildSliderRow(
          title: 'حجم الخط',
          value: s.subtitleFontSize, min: 10, max: 100,
          label: '${s.subtitleFontSize.toInt()} px',
          onChanged: (v) => s.setSubtitleFontSize(v),
          activeColor: cs.primary,
        ),
        
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: const Text('نوع الخط', style: TextStyle(color: Colors.white, fontSize: 14)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(s.fontFamily, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Icon(Icons.arrow_drop_down, color: Colors.white70),
            ],
          ),
          onTap: () => _showFontPicker(context, s),
        ),

        const Divider(color: Colors.white24, height: 24),
        
        // ── الألوان والخلفية بطريقة احترافية ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('لون النص', style: TextStyle(color: Colors.white, fontSize: 14)),
            GestureDetector(
              onTap: () async {
                final color = await showColorPickerDialog(context, s.subtitleColor);
                if (color != null) s.setSubtitleColor(color);
              },
              child: ColorIndicator(color: s.subtitleColor, width: 30, height: 30, borderRadius: 8),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // تصميم لون الخلفية والتوغل بجانب بعضهما
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('خلفية النص', style: TextStyle(color: Colors.white, fontSize: 14)),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final color = await showColorPickerDialog(context, s.subtitleBgColor);
                    if (color != null) s.setSubtitleBgColor(color);
                  },
                  child: ColorIndicator(color: s.subtitleBgColor, width: 30, height: 30, borderRadius: 8),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: s.subtitleBgOpacity > 0,
                  onChanged: (v) => s.setSubtitleBgOpacity(v ? 0.6 : 0.0),
                  activeColor: cs.primary,
                ),
              ],
            ),
          ],
        ),

        if (s.subtitleBgOpacity > 0) ...[
          const SizedBox(height: 8),
          _buildSliderRow(
            title: 'شفافية الخلفية',
            value: s.subtitleBgOpacity, min: 0.1, max: 1.0,
            label: '${(s.subtitleBgOpacity * 100).toInt()}%',
            onChanged: (v) => s.setSubtitleBgOpacity(v),
            activeColor: cs.primary,
          ),
        ],

        const Divider(color: Colors.white24, height: 24),

        // ── ظل النص ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ظل النص', style: TextStyle(color: Colors.white, fontSize: 14)),
            Switch(
              value: s.textShadowEnabled,
              onChanged: (v) => s.setTextShadowEnabled(v),
              activeColor: cs.primary,
            ),
          ],
        ),
        
        if (s.textShadowEnabled) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('لون الظل', style: TextStyle(color: Colors.white70, fontSize: 13)),
              GestureDetector(
                onTap: () async {
                  final color = await showColorPickerDialog(context, s.textShadowColor);
                  if (color != null) s.setTextShadowColor(color);
                },
                child: ColorIndicator(color: s.textShadowColor, width: 24, height: 24, borderRadius: 6),
              ),
            ],
          ),
          _buildSliderRow(
            title: 'حجم الظل (Blur)', value: s.textShadowBlurRadius, min: 0, max: 20,
            label: '${s.textShadowBlurRadius.toInt()}',
            onChanged: (v) => s.setTextShadowBlurRadius(v), activeColor: cs.primary,
          ),
        ],

        const Divider(color: Colors.white24, height: 24),

        // ── الموقع (مزامنة مع السحب) ──
        _buildSliderRow(
          title: 'الارتفاع عن الأسفل',
          value: s.bottomPadding, min: 0, max: 300,
          label: '${s.bottomPadding.toInt()} px',
          onChanged: (v) => s.setBottomPadding(v),
          activeColor: cs.primary,
        ),
      ],
    ),
  );
}

void _showFontPicker(BuildContext context, SettingsProvider s) {
  final fonts = ['Roboto', 'monospace', 'serif', 'sans-serif', 'Cairo', 'Amiri', 'Noto Naskh Arabic'];
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: const Text('اختر نوع الخط', style: TextStyle(color: Colors.white), textAlign: TextAlign.right),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fonts.map((font) => ListTile(
            title: Text(font, textAlign: TextAlign.right, style: TextStyle(
              color: s.fontFamily == font ? Theme.of(context).colorScheme.primary : Colors.white,
              fontFamily: font,
            )),
            trailing: s.fontFamily == font ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
            onTap: () { s.setFontFamily(font); Navigator.pop(ctx); },
          )).toList(),
        ),
      ),
    ),
  );
}
