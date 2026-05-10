import 'package:flutter/services.dart';

class ZaloPayService {
  // Channel name must match exactly with the one in MainActivity.kt
  static const MethodChannel _channel =
      MethodChannel('com.example.customer/zalopay');

  /// Start ZaloPay payment process
  /// [zpToken] is received from your backend order creation API
  /// Returns: "SUCCESS", "CANCELED", or "ERROR"
  static Future<String> payOrder(String zpToken) async {
    try {
      final String result = await _channel.invokeMethod('payOrder', {
        'zptoken': zpToken,
      });
      return result;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print("ZaloPay Error: '${e.message}'.");
      return "ERROR";
    } catch (e) {
      return "ERROR";
    }
  }
}
