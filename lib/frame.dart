import 'dart:async';

import 'package:flutter/services.dart';

class Frame {
  static const MethodChannel _channel =
      const MethodChannel('frame');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
