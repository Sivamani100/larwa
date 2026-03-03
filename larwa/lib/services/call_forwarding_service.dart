// lib/services/call_forwarding_service.dart
import 'package:flutter/services.dart';
import '../core/constants.dart';

class CallForwardingService {
  static const _channel = MethodChannel(AppConstants.callForwardingChannel);

  /// Enable call forwarding to Twilio number (AI Mode ON)
  static Future<bool> enable(String twilioNumber) async {
    try {
      final result = await _channel.invokeMethod<String>('enableForwarding', {
        'twilioNumber': twilioNumber,
      });
      print('[CallForwarding] Enabled: $result');
      return true;
    } on PlatformException catch (e) {
      print('[CallForwarding] Error enabling: ${e.message}');
      return false;
    }
  }

  /// Disable call forwarding (AI Mode OFF)
  static Future<bool> disable() async {
    try {
      final result = await _channel.invokeMethod<String>('disableForwarding');
      print('[CallForwarding] Disabled: $result');
      return true;
    } on PlatformException catch (e) {
      print('[CallForwarding] Error disabling: ${e.message}');
      return false;
    }
  }

  /// Check current forwarding status
  static Future<String> checkStatus() async {
    try {
      final result = await _channel.invokeMethod<String>(
        'checkForwardingStatus',
      );
      return result ?? 'Unknown';
    } on PlatformException catch (e) {
      return 'Error: ${e.message}';
    }
  }
}
