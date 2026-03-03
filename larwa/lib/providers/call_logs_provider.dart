// lib/providers/call_logs_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/call_log.dart';

/// Stream provider — auto-updates when Supabase Realtime fires
final callLogsProvider = StreamProvider<List<CallLog>>((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('call_logs')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .limit(50)
      .map((rows) => rows.map((row) => CallLog.fromJson(row)).toList());
});

/// Provider for a single call log by ID
final callLogByIdProvider =
    FutureProvider.family<CallLog?, String>((ref, id) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('call_logs').select().eq('id', id).single();
  return CallLog.fromJson(response);
});

/// Update call status
Future<void> updateCallStatus(String id, String status) async {
  final supabase = Supabase.instance.client;
  await supabase
      .from('call_logs')
      .update({'status': status}).eq('id', id);
}
