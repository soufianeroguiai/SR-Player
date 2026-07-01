import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';

class HDRService {
  HDRService._();

  static bool _enabled = false;
  static bool get isEnabled => _enabled;

  static Future<void> enable(Player player) async {
    final native = player.platform as NativePlayer;

    // 💡 تشغيل الحساب الديناميكي للإضاءة (ممتاز وفارق جداً في جودة الصورة)
    await native.setProperty('hdr-compute-peak', 'yes');
    
    // 💡 تحديث: خوارزمية 'spline' أو 'bt.2390' هما الأفضل
    // خوارزمية bt.2390 ممتازة، ولكن spline تعطي تدرجاً أنعم للألوان (Gradient) في شاشات الهاتف
    await native.setProperty('tone-mapping', 'bt.2390');
    await native.setProperty('tone-mapping-param', 'default');
    
    // تأكيد تمرير البيانات الناتيف للشاشة لتتولى العرض السينمائي
    await native.setProperty('target-peak', 'auto');
    await native.setProperty('target-prim', 'auto');
    await native.setProperty('target-trc', 'auto');
    
    // 💡 تحديث حرج لـ gamut-mapping: استخدام 'perceptual' بدلاً من 'clip'
    // خيار perceptual يحافظ على تشبع الألوان الحقيقي (Saturation) دون أن تظهر الصورة باهتة
    await native.setProperty('gamut-mapping', 'perceptual');

    _enabled = true;
  }

  static Future<void> disable(Player player) async {
    final native = player.platform as NativePlayer;

    await native.setProperty('hdr-compute-peak', 'no');
    await native.setProperty('tone-mapping', 'auto');
    await native.setProperty('tone-mapping-param', 'default');
    await native.setProperty('target-peak', 'auto');
    await native.setProperty('target-prim', 'auto');
    await native.setProperty('target-trc', 'auto');

    try {
      // 💡 تصحيح: العودة للقيمة الافتراضية 'auto' بدلاً من تمرير نص فارغ لتجنب الأخطاء
      await native.setProperty('gamut-mapping', 'auto');
    } catch (_) {}

    _enabled = false;
  }

  static Future<void> toggle(Player player) async {
    if (_enabled) {
      await disable(player);
    } else {
      await enable(player);
    }
  }

  static Future<void> reset(Player player) async {
    await disable(player);
  }
}
