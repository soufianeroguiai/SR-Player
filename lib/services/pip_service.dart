import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// يدير الدخول إلى وضع "صورة داخل صورة" (PiP) على أندرويد، ويعكس
/// الحالة الحقيقية القادمة من النظام (وليس قيمة محلية مفترَضة).
class PipService {
  static const _channel = MethodChannel('com.splayer.app/pip');
  static bool _listenerAttached = false;

  /// تعكس آخر حالة PiP أبلغ عنها أندرويد فعلياً عبر
  /// onPictureInPictureModeChanged. يجب الاستماع إليها بدل افتراض
  /// أن enter() نجحت دائماً، لأن أندرويد قد يرفض الطلب (مثلاً إذا
  /// كانت الميزة معطّلة في إعدادات النظام).
  static final ValueNotifier<bool> isInPipMode = ValueNotifier(false);

  static void _ensureListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onPipModeChanged') {
        isInPipMode.value = call.arguments as bool? ?? false;
      }
    });
  }

  static Future<void> enter() async {
    _ensureListener();
    try {
      await _channel.invokeMethod('enterPip');
      // لا نُحدِّث isInPipMode هنا يدوياً؛ الحالة الموثوقة تصل عبر
      // onPipModeChanged من Android بعد لحظات قصيرة من نجاح الطلب.
    } catch (e) {
      debugPrint('فشل الدخول إلى وضع PiP: $e');
    }
  }

  /// نُبلِغ الجانب الأصلي (Kotlin) هل يوجد فيديو قيد التشغيل حالياً أم لا.
  /// أندرويد يستدعي onUserLeaveHint() فور خروج المستخدم من التطبيق مباشرة
  /// (بدون أي تأخير)، ولا يقدر ينتظر رد من Dart فتلك اللحظة بالذات - لذلك
  /// لازم نُحدِّث هاذ العلَم على الجانب الأصلي مسبقاً فـ كل مرة تتغيّر فيها
  /// حالة التشغيل، حتى يكون جاهزاً وقت الحاجة.
  static Future<void> setEligible(bool eligible) async {
    _ensureListener();
    try {
      await _channel.invokeMethod('setPipEligible', eligible);
    } catch (e) {
      debugPrint('فشل تحديث أهلية PiP: $e');
    }
  }
}