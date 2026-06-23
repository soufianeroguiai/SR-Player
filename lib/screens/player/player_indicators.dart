import 'dart:ui';
import 'package:flutter/material.dart';

/// عناصر بصرية عائمة لعرض مستوى الصوت/الإضاءة أثناء السحب على الشاشة.
/// النسخة المعدّلة: أصغر حجماً، ألوان أهدأ، تصميم أبسط.
class PlayerIndicators {
  static Widget buildFloatingIndicator({
    required IconData icon,
    required double displayValue, // من 0.0 إلى 1.0
    required String labelText,
    required Color color,
  }) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 40,
        height: 140,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.55),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withOpacity(0.9), size: 16),
            const SizedBox(height: 6),
            Expanded(
              child: RotatedBox(
                quarterTurns: -1,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                    activeTrackColor: color.withOpacity(0.8),
                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                  ),
                  child: Slider(
                      value: displayValue.clamp(0.0, 1.0),
                      onChanged: null,
                      min: 0,
                      max: 1),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labelText,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}