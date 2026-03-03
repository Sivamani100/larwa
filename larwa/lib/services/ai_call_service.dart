import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'call_control_service.dart';
import '../core/constants.dart';

import '../providers/ai_mode_provider.dart';
import '../providers/local_call_logs_provider.dart';
import '../models/local_call_log.dart';

final aiCallServiceProvider = Provider((ref) => AiCallService(ref));

class AiCallService {
  final Ref _ref;
  final _callControl = CallControlService();

  bool _isCallActive = false;
  String _currentCallerNumber = '';
  List<Map<String, String>> _transcript = [];
  DateTime? _callStartedAt;
  String? _localLogId;
  Timer? _scriptTimer;

  StreamSubscription? _audioSub;
  StreamSubscription? _sttSub;

  AiCallService(this._ref);

  void init() {
    _audioSub = _callControl.audioStream.listen(_handleNativeEvent);
  }

  void _handleNativeEvent(dynamic event) {
    if (event is Uint8List) {
      // MVP: ignore raw mic audio (no Deepgram/streaming)
      return;
    } else if (event is Map) {
      final type = event['event'];
      if (type == 'call_started') {
        _startConversation(event['number'] ?? 'Unknown');
      } else if (type == 'call_ended') {
        _endConversation();
      }
    }
  }

  Future<void> _startConversation(String number) async {
    _isCallActive = true;
    _currentCallerNumber = number;
    _transcript = [];
    _callStartedAt = DateTime.now();
    // Update UI status
    _ref.read(aiModeProvider.notifier).setLiveCall(true);

    await _saveLocalOnlyLog(
      title: 'Incoming call',
      message: 'Caller: $number',
      forceNew: true,
    );

    // MVP scripted flow (no AI): speak preset prompts
    await _callControl.speakText(
      'Hello. This is the assistant for ${AppConstants.ownerName}.',
    );

    // Ask a couple of preset questions with delays, then end the call
    _scriptTimer?.cancel();
    _scriptTimer = Timer(const Duration(seconds: 3), () async {
      if (!_isCallActive) return;
      await _callControl.speakText('May I know your name?');
    });

    Timer(const Duration(seconds: 7), () async {
      if (!_isCallActive) return;
      await _callControl.speakText('What is this call about?');
    });

    Timer(const Duration(seconds: 14), () async {
      if (!_isCallActive) return;
      await _callControl.speakText(
        'Thank you. I will inform them and call back if needed.',
      );
    });

    Timer(const Duration(seconds: 18), () async {
      if (!_isCallActive) return;
      try {
        await _callControl.endCall();
      } catch (_) {}
    });
  }

  Future<void> _saveLocalOnlyLog({
    required String title,
    required String message,
    bool forceNew = false,
  }) async {
    try {
      final store = _ref.read(localCallLogStoreProvider);
      await store.init();
      final now = DateTime.now();
      final id = forceNew || _localLogId == null
          ? '${now.microsecondsSinceEpoch}'
          : _localLogId!;
      _localLogId = id;
      await store.add(
        LocalCallLog(
          id: id,
          callerNumber: _currentCallerNumber,
          createdAt: now,
          title: title,
          message: message,
        ),
      );
    } catch (e) {
      print('Local log save failed: $e');
    }
  }

  Future<void> _endConversation() async {
    if (!_isCallActive) return;
    _isCallActive = false;
    _scriptTimer?.cancel();

    final durationSec = _callStartedAt == null
        ? 0
        : DateTime.now().difference(_callStartedAt!).inSeconds;

    // Immediate hangup / too-short transcript (Option B: local-only)
    if (durationSec <= 2 || _transcript.length <= 1) {
      await _saveLocalOnlyLog(
        title: 'Caller hung up immediately',
        message: 'No conversation captured. Number: $_currentCallerNumber',
      );
    } else {
      await _saveLocalOnlyLog(
        title: 'Call ended',
        message: 'Duration: ${durationSec}s. Number: $_currentCallerNumber',
      );
    }

    // Update UI status
    _ref.read(aiModeProvider.notifier).setLiveCall(false);
  }

  void dispose() {
    _audioSub?.cancel();
    _sttSub?.cancel();
    _scriptTimer?.cancel();
  }
}
