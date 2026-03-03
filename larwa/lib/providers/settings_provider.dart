// lib/providers/settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/settings.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  /// Load settings from Supabase
  Future<void> loadSettings() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('settings').select();

      final map = <String, String>{};
      for (final row in response) {
        map[row['key']] = row['value'] ?? '';
      }

      state = AppSettings(
        aiModeEnabled: map['ai_mode'] == 'on',
        ownerName: map['owner_name'] ?? 'Boss',
        twilioNumber: map['twilio_number'] ?? '',
        aiPersonality: map['ai_personality'] ?? 'professional',
        busyScheduleEnabled: map['busy_schedule_enabled'] == 'true',
      );
    } catch (e) {
      print('[SETTINGS] Error loading: $e');
    }
  }

  /// Save a single setting to Supabase
  Future<void> updateSetting(String key, String value) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('settings')
          .upsert({'key': key, 'value': value}, onConflict: 'key');

      // Update local state
      switch (key) {
        case 'owner_name':
          state = state.copyWith(ownerName: value);
          break;
        case 'twilio_number':
          state = state.copyWith(twilioNumber: value);
          break;
        case 'ai_personality':
          state = state.copyWith(aiPersonality: value);
          break;
        case 'ai_mode':
          state = state.copyWith(aiModeEnabled: value == 'on');
          break;
        case 'busy_schedule_enabled':
          state = state.copyWith(busyScheduleEnabled: value == 'true');
          break;
      }
    } catch (e) {
      print('[SETTINGS] Error saving $key: $e');
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
