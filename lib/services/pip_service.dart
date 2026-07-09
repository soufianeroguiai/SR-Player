import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// يدير الدخول إلى وضع "صورة داخل صورة" (PiP) على أندرويد، ويعكس
/// الحالة الحقيقية القادمة من النظام (وليس قيمة محلية مفترَضة).
class PipService {
  static const _channel = MethodChannel('com.splayer.app/pip');
  static bool _listenerAttached = false;

  /// تعكس آخر حالة PiP أبلغ عنها أندرويد فعلياً عبر
  /// onPictureInPictureModeChanged.
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
    } catch (e) {
      debugPrint('فشل الدخول إلى وضع PiP: $e');
    }
  }

  /// الخروج من وضع PiP برمجيًا (يُغلق نافذة PiP النظامية).
  static Future<void> exit() async {
    try {
      await _channel.invokeMethod('exitPip');
      // سيتم تحديث isInPipMode عبر المستمع عند الخروج الفعلي
    } catch (e) {
      debugPrint('فشل الخروج من PiP: $e');
    }
  }
}