import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';

class ImageEnhancementService {
  ImageEnhancementService._();

  static Future<void> enable(Player player) async {
    final native = player.platform as NativePlayer;

    // ─── 1. تعديل الألوان والتباين ───────────────────
    await native.setProperty('contrast', '12');
    await native.setProperty('brightness', '2');
    await native.setProperty('saturation', '10');
    await native.setProperty('gamma', '1');
    await native.setProperty('hue', '0');

    // ─── 2. فلتر تنعيم ومنع تكتل البيكسلات ─────────────
    await native.setProperty('deband', 'yes');
    await native.setProperty('deband-iterations', '4');
    await native.setProperty('deband-threshold', '64');
    await native.setProperty('deband-range', '20');
    await native.setProperty('deband-grain', '8'); // تشويش خفيف جداً يمنح الصورة مظهراً طبيعياً

    // ─── 3. تنعيم حركة تدرج الألوان (Dithering) ─────────
    await native.setProperty('temporal-dither', 'yes');
    await native.setProperty('dither', 'ordered');
  }

  static Future<void> disable(Player player) async {
    final native = player.platform as NativePlayer;

    // ─── العودة إلى القيم الافتراضية الحقيقية لـ mpv ───
    await native.setProperty('contrast', '0');
    await native.setProperty('brightness', '0');
    await native.setProperty('saturation', '0');
    await native.setProperty('gamma', '0');
    await native.setProperty('hue', '0');

    // إيقاف الـ Deband بالكامل وإعادة القيم الافتراضية الآمنة
    await native.setProperty('deband', 'no');
    await native.setProperty('deband-iterations', '1');
    await native.setProperty('deband-threshold', '32');
    await native.setProperty('deband-range', '16');
    await native.setProperty('deband-grain', '0'); // 💡 تصحيح: 0 لمنع ظهور تشويش ونقاط على الشاشة

    // 💡 تصحيح الـ Dither للعودة للوضع التلقائي الآمن بدلاً من تعطيله تماماً
    await native.setProperty('temporal-dither', 'no');
    await native.setProperty('dither', 'fruit'); 
  }

  // 💡 تم دمج وظائف الـ HDR في ملف HDRService المخصص لضمان نظافة الكود وعدم التعارض
}
