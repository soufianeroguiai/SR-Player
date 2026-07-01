import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';

class HWDecoderService {
  HWDecoderService._();

  static bool _enabled = true;
  static bool get isEnabled => _enabled;

  static Future<void> enable(Player player) async {
    final native = player.platform as NativePlayer;
    // 💡 تعديل جوهري: 'mediacodec-copy' هو الخيار الأقوى في أندرويد لمحاكاة وضع +HW في MX Player
    // حيث يفتح فك التشفير عبر كرت الشاشة ويسمح بتطبيق فلاتر الـ Smart Enhance في نفس الوقت.
    await native.setProperty('hwdec', 'mediacodec-copy');
    _enabled = true;
  }

  static Future<void> disable(Player player) async {
    final native = player.platform as NativePlayer;
    await native.setProperty('hwdec', 'no');
    _enabled = false;
  }

  static Future<void> toggle(Player player) async {
    if (_enabled) {
      await disable(player);
    } else {
      await enable(player);
    }
  }

  static Future<String> currentDecoder(Player player) async {
    final native = player.platform as NativePlayer;
    try {
      final value = (await native.getProperty('hwdec-current')).trim().toLowerCase();
      // 💡 تصحيح: التحقق من كلمة 'no' لأن mpv يرجعها عند عمل الـ Software
      if (value.isEmpty || value == 'no') return 'Software';
      return value.toUpperCase(); // سيرجع لك اسم المود مثل MEDIACODEC
    } catch (_) {
      return 'Unknown';
    }
  }

  static Future<String> currentMode(Player player) async {
    final native = player.platform as NativePlayer;
    try {
      return await native.getProperty('hwdec');
    } catch (_) {
      return 'unknown';
    }
  }

  static Future<bool> isHardwareActive(Player player) async {
    final native = player.platform as NativePlayer;
    try {
      final value = (await native.getProperty('hwdec-current')).trim().toLowerCase();
      // 💡 تصحيح حرج: العتاد يكون نشطاً فقط إذا لم تكن القيمة فارغة ولم تكن 'no'
      return value.isNotEmpty && value != 'no';
    } catch (_) {
      return false;
    }
  }

  static Future<void> reset(Player player) async {
    await enable(player);
  }
}
