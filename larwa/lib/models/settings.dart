// lib/models/settings.dart

class AppSettings {
  final bool aiModeEnabled;
  final String ownerName;
  final String twilioNumber;
  final String aiPersonality; // professional | friendly | strict
  final bool busyScheduleEnabled;
  final String busyFrom;
  final String busyTo;
  final List<int> busyDays; // 1=Mon, 7=Sun

  const AppSettings({
    this.aiModeEnabled = false,
    this.ownerName = 'Boss',
    this.twilioNumber = '',
    this.aiPersonality = 'professional',
    this.busyScheduleEnabled = false,
    this.busyFrom = '09:00',
    this.busyTo = '17:00',
    this.busyDays = const [1, 2, 3, 4, 5],
  });

  AppSettings copyWith({
    bool? aiModeEnabled,
    String? ownerName,
    String? twilioNumber,
    String? aiPersonality,
    bool? busyScheduleEnabled,
    String? busyFrom,
    String? busyTo,
    List<int>? busyDays,
  }) {
    return AppSettings(
      aiModeEnabled: aiModeEnabled ?? this.aiModeEnabled,
      ownerName: ownerName ?? this.ownerName,
      twilioNumber: twilioNumber ?? this.twilioNumber,
      aiPersonality: aiPersonality ?? this.aiPersonality,
      busyScheduleEnabled: busyScheduleEnabled ?? this.busyScheduleEnabled,
      busyFrom: busyFrom ?? this.busyFrom,
      busyTo: busyTo ?? this.busyTo,
      busyDays: busyDays ?? this.busyDays,
    );
  }
}
