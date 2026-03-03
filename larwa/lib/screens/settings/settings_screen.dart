// lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/settings_provider.dart';
import '../../services/call_control_service.dart';
import '../../providers/local_call_logs_provider.dart';
import '../../core/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _callControl = CallControlService();
  List<String> _vipNumbers = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vips = await _callControl.getVipNumbers();
      if (mounted) setState(() => _vipNumbers = vips);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(AppConstants.colorBackground),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.colorCardBg),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── MY PROFILE ───────────────────────────────
          _sectionHeader('My Profile'),
          _settingsCard(
            children: [
              _editableTile(
                icon: Icons.person_rounded,
                title: 'Your Name',
                subtitle: settings.ownerName,
                onTap: () => _showEditDialog(
                  context,
                  'Your Name',
                  settings.ownerName,
                  (value) =>
                      settingsNotifier.updateSetting('owner_name', value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── AI BEHAVIOUR ─────────────────────────────
          _sectionHeader('AI Behaviour'),
          _settingsCard(
            children: [
              _selectTile(
                icon: Icons.psychology_rounded,
                title: 'AI Personality',
                value: settings.aiPersonality,
                options: ['professional', 'friendly', 'strict'],
                onChanged: (v) =>
                    settingsNotifier.updateSetting('ai_personality', v),
              ),
              ListTile(
                leading: const Icon(
                  Icons.star_rounded,
                  color: Color(AppConstants.colorWarning),
                ),
                title: const Text(
                  'VIP Contacts',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _vipNumbers.isEmpty
                      ? 'None set — VIP callers will ring normally'
                      : '${_vipNumbers.length} number(s) will bypass AI Mode',
                  style: const TextStyle(
                    color: Color(AppConstants.colorTextSecondary),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(AppConstants.colorTextSecondary),
                ),
                onTap: () => _showVipDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── SYSTEM ───────────────────────────────────
          _sectionHeader('System'),
          _settingsCard(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.settings_phone_rounded,
                  color: Color(AppConstants.colorPrimary),
                ),
                title: const Text(
                  'Default Dialer Setup',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Ensure Larwa is your default phone app',
                  style: TextStyle(
                    color: Color(AppConstants.colorTextSecondary),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(AppConstants.colorTextSecondary),
                ),
                onTap: () => context.push('/setup'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── NOTIFICATIONS ────────────────────────────
          _sectionHeader('Inbox'),
          _settingsCard(
            children: [
              ListTile(
                leading: Icon(
                  Icons.notifications_active_rounded,
                  color: const Color(AppConstants.colorWarning),
                ),
                title: const Text(
                  'Send Test Inbox Item',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Adds a fake item to your Inbox for testing',
                  style: TextStyle(
                    color: Color(AppConstants.colorTextSecondary),
                  ),
                ),
                onTap: () async {
                  final supabase = Supabase.instance.client;
                  await supabase.from('call_logs').insert({
                    'caller_number': '+910000000000',
                    'caller_name': 'Test Caller',
                    'is_known_contact': false,
                    'call_duration_sec': 12,
                    'call_type': 'routine',
                    'ai_summary':
                        'This is a test inbox item created from Settings.',
                    'full_transcript': [
                      {'speaker': 'assistant', 'text': 'Test message'},
                    ],
                    'urgency_level': 'low',
                    'action_needed': 'No action needed',
                    'recommended_response': '',
                    'should_call_back': false,
                    'status': 'new',
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test item added to Inbox')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── DANGER ZONE ──────────────────────────────
          _sectionHeader('Danger Zone'),
          _settingsCard(
            borderColor: const Color(AppConstants.colorUrgent).withOpacity(0.3),
            children: [
              ListTile(
                leading: Icon(
                  Icons.cleaning_services_rounded,
                  color: const Color(AppConstants.colorWarning),
                ),
                title: const Text(
                  'Clear Local Events',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Clears local-only hangup/error events stored on this device',
                  style: TextStyle(
                    color: Color(AppConstants.colorTextSecondary),
                  ),
                ),
                onTap: () => _showConfirmDialog(
                  context,
                  'Clear local events?',
                  () async {
                    final store = ref.read(localCallLogStoreProvider);
                    await store.init();
                    await store.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Local events cleared')),
                      );
                    }
                  },
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever_rounded,
                  color: const Color(AppConstants.colorUrgent),
                ),
                title: const Text(
                  'Clear All Call Logs',
                  style: TextStyle(color: Color(AppConstants.colorUrgent)),
                ),
                subtitle: const Text(
                  'This cannot be undone',
                  style: TextStyle(
                    color: Color(AppConstants.colorTextSecondary),
                  ),
                ),
                onTap: () => _showConfirmDialog(
                  context,
                  'Clear all call logs?',
                  () async {
                    final supabase = Supabase.instance.client;
                    await supabase.from('call_logs').delete().neq('id', '');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All logs cleared')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // App version
          Center(
            child: Text(
              'Larwa v1.0.0',
              style: TextStyle(
                color: const Color(
                  AppConstants.colorTextSecondary,
                ).withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: const Color(AppConstants.colorTextSecondary).withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _settingsCard({required List<Widget> children, Color? borderColor}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(AppConstants.colorCardBg),
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: Column(children: children),
    );
  }

  Widget _editableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(AppConstants.colorPrimary)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Color(AppConstants.colorTextSecondary)),
      ),
      trailing: const Icon(
        Icons.edit_rounded,
        size: 18,
        color: Color(AppConstants.colorTextSecondary),
      ),
      onTap: onTap,
    );
  }

  Widget _selectTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(AppConstants.colorPrimary)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(AppConstants.colorSurface),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        underline: const SizedBox.shrink(),
        items: options
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o[0].toUpperCase() + o.substring(1)),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    ValueChanged<String> onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppConstants.colorCardBg),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppConstants.colorCardBg),
        title: Text(message, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.colorUrgent),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showVipDialog(BuildContext context) {
    final controller = TextEditingController(text: _vipNumbers.join(','));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(AppConstants.colorCardBg),
        title: const Text('VIP Numbers', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '+91XXXXXXXXXX,+91YYYYYYYYYY',
            hintStyle: TextStyle(color: Color(AppConstants.colorTextSecondary)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final raw = controller.text;
              final list = raw
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toSet()
                  .toList();
              await _callControl.setVipNumbers(list);
              if (mounted) {
                setState(() => _vipNumbers = list);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
