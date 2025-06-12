import 'package:flutter/services.dart';

class NativeAppUsageBridge {
  static const MethodChannel _channel = MethodChannel('app_usage_channel');

  static Future<Map<String, List<int>>> getHourlyAppUsage() async {
    final Map<String, dynamic> result = await _channel.invokeMethod('getHourlyAppUsage');
    return result.map((key, value) => MapEntry(key, List<int>.from(value as List)));
  }
}
