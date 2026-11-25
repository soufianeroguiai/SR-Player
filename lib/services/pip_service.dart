import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// يدير الدخول إلى وضع "صورة داخل صورة" (PiP) على أندرويد، ويعكس
/// الحالة الحقيقية القادمة من النظام (وليس قيمة محلية مفترَضة).
///
/// ملاحظة: هذه الفئة تملك المعالج الوحيد لقناة `com.splayer.app/pip`
/// (MethodChannel يقبل معالجاً واحداً فقط)، لذلك أُضيفت إليها أيضاً
/// أحداث أزرار الصوت، ومستوى البطارية، وفتح فيديو من تطبيق خارجي.
class PipService {
  static const _channel = MethodChannel('com.splayer.app/pip');
  static bool _listenerAttached = false;

  /// تعكس آخر حالة PiP أبلغ عنها أندرويد فعلياً عبر
  /// onPictureInPictureModeChanged. يجب الاستماع إليها بدل افتراض
  /// أن enter() نجحت دائماً، لأن أندرويد قد يرفض الطلب (مثلاً إذا
  /// كانت الميزة معطّلة في إعدادات النظام).
  static final ValueNotifier<bool> isInPipMode = ValueNotifier(false);

  /// أحداث أزرار الصوت (+1 رفع، -1 خفض) عندما يكون الاعتراض مفعّلاً.
  static final StreamController<int> volumeKeyEvents =
      StreamController<int>.broadcast();

  /// يُستدعى عندما يصل فيديو جديد من تطبيق خارجي (مدير الملفات مثلاً)
  /// والتطبيق مفتوح مسبقاً. المعامل: {path, name}.
  static void Function(Map<String, String> video)? onExternalVideo;

  static void _ensureListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onPipModeChanged':
          isInPipMode.value = call.arguments as bool? ?? false;
          break;
        case 'onVolumeKey':
          volumeKeyEvents.add(call.arguments as int? ?? 0);
          break;
        case 'onOpenVideo':
          final args = call.arguments;
          if (args is Map) {
            onExternalVideo?.call(
                args.map((k, v) => MapEntry(k.toString(), v.toString())));
          }
          break;
      }
    });
  }

  /// يجب استدعاؤها مبكراً (عند بدء التطبيق) حتى لا تضيع أحداث PiP أو
  /// فتح الفيديوهات الخارجية قبل ربط المعالج.
  static void init() => _ensureListener();

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

  /// يفعّل/يعطّل اعتراض أزرار الصوت على الجانب الأصلي (للتقديم/الترجيع).
  static Future<void> setInterceptVolumeKeys(bool intercept) async {
    _ensureListener();
    try {
      await _channel.invokeMethod('setInterceptVolumeKeys', intercept);
    } catch (e) {
      debugPrint('فشل تغيير اعتراض أزرار الصوت: $e');
    }
  }

  /// مستوى البطارية 0-100، أو -1 إن تعذّر القراءة.
  static Future<int> getBatteryLevel() async {
    try {
      return await _channel.invokeMethod<int>('getBatteryLevel') ?? -1;
    } catch (_) {
      return -1;
    }
  }

  /// الفيديو الذي فُتح به التطبيق من تطبيق خارجي (إن وُجد) - يُرجَع مرة واحدة.
  static Future<Map<String, String>?> getInitialVideo() async {
    _ensureListener();
    try {
      final r = await _channel.invokeMethod<Map>('getInitialVideo');
      if (r == null) return null;
      return r.map((k, v) => MapEntry(k.toString(), v.toString()));
    } catch (_) {
      return null;
    }
  }
}
