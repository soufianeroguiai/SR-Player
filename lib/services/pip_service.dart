import 'package:flutter/services.dart';

class PipService {
  static const _channel = MethodChannel('com.splayer.app/pip');

  /// Enter Picture-in-Picture mode
  static Future<void> enter() async {
    try {
      await _channel.invokeMethod('enterPip');
    } catch (_) {}
  }
}
