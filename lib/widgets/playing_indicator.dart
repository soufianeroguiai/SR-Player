import 'package:flutter/material.dart';

/// أيقونة "موجات الصوت" المتحركة (3 أعمدة) التي تظهر بجانب/فوق الفيديو
/// الذي يعمل حالياً - مستخدَمة فلوحة قائمة التشغيل داخل المشغّل، وأيضاً
/// فوق بطاقة الفيديو (VideoCard) فقوائم التطبيق المختلفة.
class PlayingIndicator extends StatefulWidget {
  final Color? color;
  const PlayingIndicator({super.key, this.color});

  @override
  State<PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<PlayingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final height = 6.0 + (index == 1 ? 10.0 * _ctrl.value : 8.0 * (1 - _ctrl.value));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.0,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
