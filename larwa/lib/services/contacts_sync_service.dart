// lib/services/contacts_sync_service.dart
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactsSyncService {
  /// Sync device contacts to Supabase for caller identification
  static Future<int> syncContacts() async {
    // Check permission
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      print('[CONTACTS] Permission denied');
      return 0;
    }

    // Get all contacts with phone numbers
    final contacts =
        await FlutterContacts.getContacts(withProperties: true);

    final supabase = Supabase.instance.client;
    int synced = 0;

    for (final contact in contacts) {
      if (contact.phones.isEmpty) continue;

      for (final phone in contact.phones) {
        final normalized = _normalizePhone(phone.number);
        if (normalized.isEmpty) continue;

        try {
          await supabase.from('contacts').upsert(
            {
              'phone': normalized,
              'name': contact.displayName,
            },
            onConflict: 'phone',
          );
          synced++;
        } catch (e) {
          // Skip duplicates or errors
          print('[CONTACTS] Error syncing ${contact.displayName}: $e');
        }
      }
    }

    print('[CONTACTS] Synced $synced contacts to Supabase');
    return synced;
  }

  /// Basic phone number normalization
  static String _normalizePhone(String phone) {
    // Strip all non-digit chars except +
    final hasPlus = phone.startsWith('+');
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) return '';

    if (hasPlus) return '+$digits';

    // Indian 10-digit
    if (digits.length == 10 && '6789'.contains(digits[0])) {
      return '+91$digits';
    }

    // Indian with country code
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+$digits';
    }

    // US 10-digit
    if (digits.length == 10) return '+1$digits';

    // US with country code
    if (digits.length == 11 && digits.startsWith('1')) return '+$digits';

    return '+$digits';
  }
}
