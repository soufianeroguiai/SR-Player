import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';

class ScalerService {
  ScalerService._();

  /// إعداد الجودة القصوى (يعادل وضع المعالجة الفائقة في MX Player)
  /// مناسب للفيديوهات عند تشغيل تسريع العتاد أو الهواتف القوية
  static Future<void> applyBalanced(Player player) async {
    final native = player.platform as NativePlayer;

    await native.setProperty('scale', 'spline36');
    await native.setProperty('dscale', 'mitchell');
    await native.setProperty('cscale', 'spline36');

    await native.setProperty('scale-antiring', '0.7');
    await native.setProperty('cscale-antiring', '0.7');
  }

  /// إعداد الأداء السريع (هواتف ضعيفة أو عند غياب تسريع العتاد)
  static Future<void> applyPerformance(Player player) async {
    final native = player.platform as NativePlayer;

    await native.setProperty('scale', 'bilinear');
    await native.setProperty('dscale', 'bilinear');
    await native.setProperty('cscale', 'bilinear');

    await native.setProperty('scale-antiring', '0.0');
    await native.setProperty('cscale-antiring', '0.0');
  }

  /// إعادة الإعدادات الافتراضية للمشغل عند إغلاق وضع التحسين الذكي
  static Future<void> reset(Player player) async {
    final native = player.platform as NativePlayer;

    await native.setProperty('scale', 'lanczos');
    await native.setProperty('dscale', 'hermite');
    await native.setProperty('cscale', 'lanczos');
    await native.setProperty('scale-antiring', '0.0');
    await native.setProperty('cscale-antiring', '0.0');
  }
}