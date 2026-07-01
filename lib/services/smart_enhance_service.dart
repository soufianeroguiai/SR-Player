import 'package:media_kit/media_kit.dart';
import 'package:media_kit/src/player/native/player/real.dart';
import 'hdr_service.dart';
import 'scaler_service.dart';

class SmartEnhanceService {
  SmartEnhanceService._();

  static bool _enabled = false;
  static bool get isEnabled => _enabled;

  // قيم Smart Enhance المُطبَّقة — نحتاجها لاستعادتها عند الإيقاف
  // بدون المساس بقيم color settings المستخدم
  static double _appliedContrast   = 0;
  static double _appliedSaturation = 0;

  static Future<bool> _waitForVO(NativePlayer native) async {
    for (int i = 0; i < 20; i++) {
      try {
        final vo = (await native.getProperty('current-vo')).trim();
        if (vo.isNotEmpty) return true;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 150));
    }
    return false;
  }

  static Future<Map<String, String>> _readProps(NativePlayer native) async {
    final map = <String, String>{};
    await Future.wait([
      native.getProperty('video-codec').then((v) => map['codec'] = v.trim()).catchError((_) => map['codec'] = ''),
      native.getProperty('video-params/pixelformat').then((v) => map['pixel'] = v.trim()).catchError((_) => map['pixel'] = ''),
      native.getProperty('video-params/w').then((v) => map['w'] = v.trim()).catchError((_) => map['w'] = ''),
      native.getProperty('video-params/h').then((v) => map['h'] = v.trim()).catchError((_) => map['h'] = ''),
      native.getProperty('container-fps').then((v) => map['fps'] = v.trim()).catchError((_) => map['fps'] = ''),
      native.getProperty('video-params/gamma').then((v) => map['trc'] = v.trim()).catchError((_) => map['trc'] = ''),
      native.getProperty('video-params/primaries').then((v) => map['primaries'] = v.trim()).catchError((_) => map['primaries'] = ''),
    ]);
    return map;
  }

  static Future<void> enable(
    Player player, {
    // ✅ نستقبل قيم color settings الحالية لنضيف عليها بدل الكتابة فوقها
    double userContrast   = 0,
    double userSaturation = 0,
    double userBrightness = 0,
    double userGamma      = 0,
  }) async {
    if (_enabled) return;
    final native = player.platform as NativePlayer;

    final voReady = await _waitForVO(native);
    if (!voReady) return;

    final props = await _readProps(native);
    final codec     = props['codec'] ?? '';
    final pixel     = props['pixel'] ?? '';
    final w         = int.tryParse(props['w'] ?? '') ?? 0;
    final h         = int.tryParse(props['h'] ?? '') ?? 0;
    final fps       = double.tryParse(props['fps'] ?? '') ?? 0;
    final trc       = props['trc'] ?? '';
    final primaries = props['primaries'] ?? '';

    final maxSide = w > h ? w : h;
    final is10bit = pixel.contains('p10') || pixel.contains('10');
    final isHEVC  = codec.toLowerCase().contains('hevc');
    final isHDR   = (trc.contains('pq') || trc.contains('hlg')) &&
                    !primaries.contains('709');

    // ─── تكبير ذكي ───────────────────────────────────────────
    await ScalerService.applyBalanced(player);
    await native.setProperty('sigmoid-upscaling', 'yes');
    await native.setProperty('correct-downscaling', 'yes');
    await native.setProperty('linear-downscaling', 'yes');

    // ─── تحسينات بصرية ───────────────────────────────────────
    if (isHDR) {
      _appliedContrast   = 5;
      _appliedSaturation = 8;
      // ✅ نضيف على قيم المستخدم بدل الكتابة فوقها
      await native.setProperty('contrast',   (userContrast + _appliedContrast).toString());
      await native.setProperty('saturation', (userSaturation + _appliedSaturation).toString());
      await native.setProperty('brightness', userBrightness.toString());
      await native.setProperty('gamma',      userGamma.toString()); // ✅ بدون تعديل gamma
      await native.setProperty('deband', 'yes');
      await HDRService.enable(player);

    } else if (is10bit && isHEVC && maxSide >= 1080) {
      // ✅ أنمي HEVC 10-bit — القيم المختبرة من اختباراتك
      _appliedContrast   = 15;
      _appliedSaturation = 18;
      await native.setProperty('contrast',   (userContrast + _appliedContrast).toString());
      await native.setProperty('saturation', (userSaturation + _appliedSaturation).toString());
      await native.setProperty('brightness', userBrightness.toString()); // ✅ لا نغير brightness
      await native.setProperty('gamma',      userGamma.toString());       // ✅ لا نغير gamma

      // ✅ target-prim فقط بدون target-trc (سبب الباهتة)
      await native.setProperty('target-prim', 'bt.709');

      await native.setProperty('deband', 'yes');
      await native.setProperty('deband-iterations', '4');
      await native.setProperty('deband-threshold', '64');
      await native.setProperty('deband-range', '20');
      await native.setProperty('deband-grain', '8');

      await native.command([
        'vf', 'add',
        '@smart:unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=0.60'
      ]);

    } else if (maxSide <= 640) {
      _appliedContrast   = 20;
      _appliedSaturation = 22;
      await native.setProperty('contrast',   (userContrast + _appliedContrast).toString());
      await native.setProperty('saturation', (userSaturation + _appliedSaturation).toString());
      await native.setProperty('brightness', userBrightness.toString());
      await native.setProperty('gamma',      userGamma.toString());
      await native.command([
        'vf', 'add',
        '@smart:unsharp=luma_msize_x=5:luma_msize_y=5:luma_amount=1.0'
      ]);

    } else {
      _appliedContrast   = 12;
      _appliedSaturation = 15;
      await native.setProperty('contrast',   (userContrast + _appliedContrast).toString());
      await native.setProperty('saturation', (userSaturation + _appliedSaturation).toString());
      await native.setProperty('brightness', userBrightness.toString());
      await native.setProperty('gamma',      userGamma.toString());
      await native.setProperty('deband', 'yes');
      await native.command([
        'vf', 'add',
        '@smart:unsharp=luma_msize_x=3:luma_msize_y=3:luma_amount=0.45'
      ]);
    }

    await native.setProperty('temporal-dither', 'yes');
    await native.setProperty('dither', 'ordered');

    if (fps > 0 && fps < 25) {
      await native.setProperty('interpolation', 'yes');
      await native.setProperty('tscale', 'oversample');
    }

    _enabled = true;
  }

  static Future<void> disable(
    Player player, {
    // ✅ نستعيد قيم المستخدم بعد الإيقاف بدل الرجوع لـ 0
    double userContrast   = 0,
    double userSaturation = 0,
    double userBrightness = 0,
    double userGamma      = 0,
    double userHue        = 0,
  }) async {
    if (!_enabled) return;
    final native = player.platform as NativePlayer;

    await HDRService.disable(player);
    await ScalerService.reset(player);
    try { await native.command(['vf', 'del', '@smart']); } catch (_) {}

    // ✅ نستعيد قيم المستخدم بدل الإعادة لـ 0
    await Future.wait([
      native.setProperty('contrast',   userContrast.toString()),
      native.setProperty('brightness', userBrightness.toString()),
      native.setProperty('saturation', userSaturation.toString()),
      native.setProperty('gamma',      userGamma.toString()),
      native.setProperty('hue',        userHue.toString()),
      native.setProperty('deband', 'no'),
      native.setProperty('deband-iterations', '1'),
      native.setProperty('deband-threshold', '32'),
      native.setProperty('deband-range', '16'),
      native.setProperty('deband-grain', '0'),
      native.setProperty('temporal-dither', 'no'),
      native.setProperty('dither', 'fruit'),
      native.setProperty('sigmoid-upscaling', 'no'),
      native.setProperty('correct-downscaling', 'no'),
      native.setProperty('linear-downscaling', 'no'),
      native.setProperty('target-prim', 'auto'),
      native.setProperty('target-trc', 'auto'),
      native.setProperty('video-output-levels', 'auto'),
    ]);

    _appliedContrast   = 0;
    _appliedSaturation = 0;
    _enabled = false;
  }

  static Future<void> toggle(Player player,
      {double userContrast = 0, double userSaturation = 0,
       double userBrightness = 0, double userGamma = 0, double userHue = 0}) async {
    if (_enabled) {
      await disable(player,
          userContrast: userContrast, userSaturation: userSaturation,
          userBrightness: userBrightness, userGamma: userGamma, userHue: userHue);
    } else {
      await enable(player,
          userContrast: userContrast, userSaturation: userSaturation,
          userBrightness: userBrightness, userGamma: userGamma);
    }
  }

  static void reset() {
    _enabled = false;
    _appliedContrast   = 0;
    _appliedSaturation = 0;
  }
}
