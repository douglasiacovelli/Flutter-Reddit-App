import 'dart:async';

import 'package:flutter/services.dart';

class BuildVariants {
  static const MethodChannel _channel =
      const MethodChannel('build_variants');

  static Future<String> get getVariant async {
    final String version = await _channel.invokeMethod('getVariant');
    return version;
  }

  static Future<String> get getAppVersion async {
    final String version = await _channel.invokeMethod('getAppVersion');
    return version;
  }
}
