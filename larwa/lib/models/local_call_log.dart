class LocalCallLog {
  final String id;
  final String callerNumber;
  final DateTime createdAt;
  final String title;
  final String message;

  const LocalCallLog({
    required this.id,
    required this.callerNumber,
    required this.createdAt,
    required this.title,
    required this.message,
  });

  factory LocalCallLog.fromJson(Map<String, dynamic> json) => LocalCallLog(
        id: json['id'] ?? '',
        callerNumber: json['caller_number'] ?? '',
        createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        title: json['title'] ?? '',
        message: json['message'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'caller_number': callerNumber,
        'created_at': createdAt.toIso8601String(),
        'title': title,
        'message': message,
      };
}
