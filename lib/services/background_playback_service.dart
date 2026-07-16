import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../main.dart' show logGlobalError;

/// يتحكم بخدمة أمامية (Foreground Service) على أندرويد، دورها الوحيد هو
/// إبقاء الصوت شغّالاً بعد قفل الشاشة. بدون خدمة أمامية، أندرويد (خصوصاً
/// فوضع Doze الحديث) يوقف تنفيذ التطبيق فالخلفية بعد مدة قصيرة من قفل
/// الشاشة، فيتوقف الصوت معه رغم أن الفيديو "قيد التشغيل" من منظور Flutter.
class BackgroundPlaybackService {
  // نفس قناة PiP بالضبط (com.splayer.app/pip) - مُعرَّفة ومُتحكَّم بها من
  // نفس MainActivity.kt، فلا داعي لقناة منفصلة.
  static const _channel = MethodChannel('com.splayer.app/pip');

  static bool _isRunning = false;

  /// يبدأ الخدمة الأمامية مع عنوان الفيديو الحالي (يظهر فالإشعار).
  /// إشعار الخدمة إلزامي من طرف أندرويد لأي خدمة أمامية من نوع
  /// mediaPlayback، ولا يمكن إخفاؤه بالكامل.
  static Future<void> start(String title) async {
    if (_isRunning) return;
    _isRunning = true;
    try {
      await _channel.invokeMethod('startPlaybackService', title);
    } catch (e, st) {
      debugPrint('فشل بدء خدمة التشغيل الأمامية: $e');
      logGlobalError('فشل بدء خدمة التشغيل الأمامية (البقاء شغّالاً بعد قفل الشاشة): $e', st);
      _isRunning = false;
    }
  }

  static Future<void> stop() async {
    if (!_isRunning) return;
    _isRunning = false;
    try {
      await _channel.invokeMethod('stopPlaybackService');
    } catch (e) {
      debugPrint('فشل إيقاف خدمة التشغيل الأمامية: $e');
    }
  }
}
