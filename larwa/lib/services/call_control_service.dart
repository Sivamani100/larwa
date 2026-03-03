import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class CallControlService {
  static const _methodChannel = MethodChannel('com.larwa.larwa/call_control');
  static const _eventChannel = EventChannel('com.larwa.larwa/audio_stream');

  Stream<dynamic>? _audioStream;

  Stream<dynamic> get audioStream {
    _audioStream ??= _eventChannel.receiveBroadcastStream();
    return _audioStream!;
  }

  Future<void> requestRole() async {
    try {
      await _methodChannel.invokeMethod('requestRole');
    } catch (e) {
      print('Error requesting role: $e');
    }
  }

  Future<bool> isRoleHeld() async {
    try {
      return await _methodChannel.invokeMethod('isRoleHeld') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> getAiMode() async {
    try {
      return await _methodChannel.invokeMethod('getAiMode') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getVipNumbers() async {
    try {
      final res = await _methodChannel.invokeMethod('getVipNumbers');
      if (res is List) {
        return res.map((e) => e.toString()).toList();
      }
      return const [];
    } catch (e) {
      return const [];
    }
  }

  Future<void> setVipNumbers(List<String> numbers) async {
    try {
      await _methodChannel.invokeMethod('setVipNumbers', numbers);
    } catch (e) {
      print('Error setting VIP numbers: $e');
    }
  }

  Future<List<String>> getBlockedNumbers() async {
    try {
      final res = await _methodChannel.invokeMethod('getBlockedNumbers');
      if (res is List) {
        return res.map((e) => e.toString()).toList();
      }
      return const [];
    } catch (e) {
      return const [];
    }
  }

  Future<void> setBlockedNumbers(List<String> numbers) async {
    try {
      await _methodChannel.invokeMethod('setBlockedNumbers', numbers);
    } catch (e) {
      print('Error setting blocked numbers: $e');
    }
  }

  Future<void> endCall() async {
    try {
      await _methodChannel.invokeMethod('endCall');
    } catch (e) {
      print('Error ending call: $e');
    }
  }

  Future<void> playAudio(Uint8List pcmBytes) async {
    try {
      await _methodChannel.invokeMethod('playAudio', pcmBytes);
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> speakText(String text) async {
    try {
      await _methodChannel.invokeMethod('speakText', text);
    } catch (e) {
      print('Error speaking text: $e');
    }
  }

  Future<void> toggleAiMode(bool enabled) async {
    try {
      await _methodChannel.invokeMethod('toggleAiMode', enabled);
    } catch (e) {
      print('Error toggling AI mode: $e');
    }
  }
}
