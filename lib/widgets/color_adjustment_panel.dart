import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class ColorAdjustmentPanel extends StatefulWidget {
  final double brightness, contrast, saturation, hue, gamma;
  final Function(String type, double value) onChanged;
  final VoidCallback onReset;
  final VoidCallback onClose;

  const ColorAdjustmentPanel({
    super.key,
    required this.brightness,
    required this.contrast,
    required this.saturation,
    required this.hue,
    required this.gamma,
    required this.onChanged,
    required this.onReset,
    required this.onClose,
  });

  @override
  State<ColorAdjustmentPanel> createState() => _ColorAdjustmentPanelState();
}

class _ColorAdjustmentPanelState extends State<ColorAdjustmentPanel> {
  late double _brightness;
  late double _contrast;
  late double _saturation;
  late double _hue;
  late double _gamma;

  @override
  void initState() {
    super.initState();
    _brightness = widget.brightness;
    _contrast   = widget.contrast;
    _saturation = widget.saturation;
    _hue        = widget.hue;
    _gamma      = widget.gamma;
  }

  void _onChange(String type, double value) {
    setState(() {
      switch (type) {
        case 'brightness': _brightness = value; break;
        case 'contrast':   _contrast   = value; break;
        case 'saturation': _saturation = value; break;
        case 'hue':        _hue        = value; break;
        case 'gamma':      _gamma      = value; break;
      }
    });
    widget.onChanged(type, value);
  }

  void _onReset() {
    setState(() {
      _brightness = 0;
      _contrast   = 0;
      _saturation = 0;
      _hue        = 0;
      _gamma      = 0;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.88),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.primary.withOpacity(0.4), width: 1),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 16, spreadRadius: 2)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    t.colorAdjustmentTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70, size: 20),
                    onPressed: _onReset,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Slider(t.brightness, _brightness, cs.primary, (v) => _onChange('brightness', v)),
              _Slider(t.contrast,   _contrast,   cs.primary, (v) => _onChange('contrast',   v)),
              _Slider(t.saturation, _saturation, cs.primary, (v) => _onChange('saturation', v)),
              _Slider(t.hue,        _hue,        cs.primary, (v) => _onChange('hue',        v)),
              _Slider('Gamma',      _gamma,      cs.primary, (v) => _onChange('gamma',      v)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _Slider(this.label, this.value, this.color, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: color,
                inactiveTrackColor: Colors.white24,
                thumbColor: color,
                overlayColor: color.withOpacity(0.2),
              ),
              child: Slider(
                value: value.clamp(-100.0, 100.0),
                min: -100,
                max: 100,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                  color: value != 0 ? color : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}