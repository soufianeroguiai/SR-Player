import 'package:flutter/material.dart';
import '../models/subtitle_settings.dart';
import '../services/subtitle_service.dart';

class SubtitleRenderer extends StatelessWidget {
  final SubtitleEntry? currentEntry;
  final SubtitleSettings settings;
  final Size videoSize;
  final Size screenSize;
  final EdgeInsets safeArea;
  final bool visible;

  const SubtitleRenderer({
    super.key,
    required this.currentEntry,
    required this.settings,
    required this.videoSize,
    required this.screenSize,
    required this.safeArea,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (currentEntry == null || !visible || currentEntry!.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // --- اختبار: إجبار النص على الظهور بوضوح ---
    const testStyle = TextStyle(
      fontSize: 28,
      color: Colors.white,
      backgroundColor: Color(0x88000000), // خلفية نصف شفافة
      fontWeight: FontWeight.bold,
    );

    String displayText = currentEntry!.text;

    // نصفي أكواد ASS إن وجدت (للقراءة)
    displayText = displayText.replaceAll(RegExp(r'\{.*?\}'), '');

    // نستخدم Positioned ثابتة في الأسفل للتجربة
    return Positioned(
      left: 0,
      right: 0,
      bottom: 60,  // ثابت
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: Text(
              displayText,
              style: testStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}