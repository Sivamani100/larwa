// lib/models/call_log.dart

class CallLog {
  final String id;
  final String? twilioCallSid;
  final String callerNumber;
  final String? callerName;
  final String? callerRelationship;
  final bool isKnownContact;
  final DateTime callStartTime;
  final int callDurationSec;
  final String callType; // spam | event | routine | important | urgent
  final String? aiSummary;
  final List<TranscriptEntry>? fullTranscript;
  final String? urgencyLevel; // low | medium | high | urgent
  final String? actionNeeded;
  final String? recommendedResponse;
  final String? deadline;
  final bool shouldCallBack;
  final String status; // new | read | replied | blocked | done
  final DateTime createdAt;

  const CallLog({
    required this.id,
    this.twilioCallSid,
    required this.callerNumber,
    this.callerName,
    this.callerRelationship,
    required this.isKnownContact,
    required this.callStartTime,
    required this.callDurationSec,
    required this.callType,
    this.aiSummary,
    this.fullTranscript,
    this.urgencyLevel,
    this.actionNeeded,
    this.recommendedResponse,
    this.deadline,
    required this.shouldCallBack,
    required this.status,
    required this.createdAt,
  });

  factory CallLog.fromJson(Map<String, dynamic> json) => CallLog(
        id: json['id'] ?? '',
        twilioCallSid: json['twilio_call_sid'],
        callerNumber: json['caller_number'] ?? '',
        callerName: json['caller_name'],
        callerRelationship: json['caller_relationship'],
        isKnownContact: json['is_known_contact'] ?? false,
        callStartTime: DateTime.tryParse(json['call_start_time'] ?? '') ??
            DateTime.now(),
        callDurationSec: json['call_duration_sec'] ?? 0,
        callType: json['call_type'] ?? 'routine',
        aiSummary: json['ai_summary'],
        fullTranscript: (json['full_transcript'] as List<dynamic>?)
            ?.map((e) => TranscriptEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        urgencyLevel: json['urgency_level'],
        actionNeeded: json['action_needed'],
        recommendedResponse: json['recommended_response'],
        deadline: json['deadline'],
        shouldCallBack: json['should_call_back'] ?? false,
        status: json['status'] ?? 'new',
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'twilio_call_sid': twilioCallSid,
        'caller_number': callerNumber,
        'caller_name': callerName,
        'caller_relationship': callerRelationship,
        'is_known_contact': isKnownContact,
        'call_start_time': callStartTime.toIso8601String(),
        'call_duration_sec': callDurationSec,
        'call_type': callType,
        'ai_summary': aiSummary,
        'urgency_level': urgencyLevel,
        'action_needed': actionNeeded,
        'recommended_response': recommendedResponse,
        'deadline': deadline,
        'should_call_back': shouldCallBack,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };

  // Helper getters
  String get displayName => callerName ?? callerNumber;

  String get durationFormatted {
    final m = callDurationSec ~/ 60;
    final s = callDurationSec % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  bool get isNew => status == 'new';
  bool get isUrgent => urgencyLevel == 'urgent' || urgencyLevel == 'high';
  bool get isSpam => callType == 'spam';
}

class TranscriptEntry {
  final String speaker; // 'caller' | 'assistant'
  final String text;

  const TranscriptEntry({required this.speaker, required this.text});

  factory TranscriptEntry.fromJson(Map<String, dynamic> json) =>
      TranscriptEntry(
        speaker: json['speaker'] ?? 'caller',
        text: json['text'] ?? '',
      );

  Map<String, dynamic> toJson() => {'speaker': speaker, 'text': text};
}
