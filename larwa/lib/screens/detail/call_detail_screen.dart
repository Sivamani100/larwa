// lib/screens/detail/call_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/call_logs_provider.dart';
import '../../services/call_control_service.dart';
import '../../core/constants.dart';
import 'transcript_view.dart';

class CallDetailScreen extends ConsumerStatefulWidget {
  final String callLogId;

  const CallDetailScreen({super.key, required this.callLogId});

  @override
  ConsumerState<CallDetailScreen> createState() => _CallDetailScreenState();
}

class _CallDetailScreenState extends ConsumerState<CallDetailScreen> {
  bool _showTranscript = false;
  final _callControl = CallControlService();

  @override
  void initState() {
    super.initState();
    // Mark as read
    Future.microtask(() => updateCallStatus(widget.callLogId, 'read'));
  }

  Color _urgencyColor(String? level) {
    switch (level) {
      case 'urgent':
        return const Color(AppConstants.colorUrgent);
      case 'high':
        return const Color(0xFFE67E22);
      case 'medium':
        return const Color(AppConstants.colorWarning);
      default:
        return const Color(AppConstants.colorSuccess);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logAsync = ref.watch(callLogByIdProvider(widget.callLogId));

    return Scaffold(
      backgroundColor: const Color(AppConstants.colorBackground),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.colorCardBg),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Call Details'),
      ),
      body: logAsync.when(
        data: (log) {
          if (log == null) {
            return const Center(
              child: Text(
                'Call not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final urgencyColor = _urgencyColor(log.urgencyLevel);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Caller Header ──────────────────────────
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: urgencyColor.withOpacity(0.15),
                        child: Text(
                          log.displayName.isNotEmpty
                              ? log.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: urgencyColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        log.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        log.callerNumber,
                        style: const TextStyle(
                          color: Color(AppConstants.colorTextSecondary),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(log.callType.toUpperCase(), urgencyColor),
                          const SizedBox(width: 8),
                          _buildBadge(
                            DateFormat(
                              'MMM d, h:mm a',
                            ).format(log.callStartTime),
                            const Color(AppConstants.colorTextSecondary),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            log.durationFormatted,
                            const Color(AppConstants.colorTextSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── AI Summary Card ────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.colorCardBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(
                        AppConstants.colorPrimary,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.smart_toy_rounded,
                            color: const Color(AppConstants.colorPrimary),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AI Summary',
                            style: TextStyle(
                              color: Color(AppConstants.colorPrimary),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        log.aiSummary ?? 'No summary available.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      if (log.actionNeeded != null &&
                          log.actionNeeded!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: urgencyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.task_alt_rounded,
                                color: urgencyColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'What to do',
                                      style: TextStyle(
                                        color: urgencyColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      log.actionNeeded!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (log.deadline != null && log.deadline!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: Color(AppConstants.colorTextSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Deadline: ${log.deadline}',
                              style: const TextStyle(
                                color: Color(AppConstants.colorWarning),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Urgency Row ────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.colorCardBg),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoChip(
                        'Urgency',
                        (log.urgencyLevel ?? 'low').toUpperCase(),
                        urgencyColor,
                      ),
                      _infoChip(
                        'Duration',
                        log.durationFormatted,
                        const Color(AppConstants.colorTextPrimary),
                      ),
                      _infoChip(
                        'Type',
                        log.callType.toUpperCase(),
                        const Color(AppConstants.colorPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Transcript Section ─────────────────────
                if (log.fullTranscript != null &&
                    log.fullTranscript!.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showTranscript = !_showTranscript),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.colorCardBg),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(AppConstants.colorTextSecondary),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Full Transcript (${log.fullTranscript!.length} messages)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            _showTranscript
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: const Color(AppConstants.colorTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showTranscript) ...[
                    const SizedBox(height: 12),
                    TranscriptView(transcript: log.fullTranscript!),
                  ],
                ],
                const SizedBox(height: 100), // Bottom padding for action bar
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(AppConstants.colorPrimary),
          ),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
        ),
      ),
      // ── Action Buttons ────────────────────────────────────
      bottomSheet: logAsync.when(
        data: (log) {
          if (log == null) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(AppConstants.colorCardBg),
              border: Border(
                top: BorderSide(color: const Color(0xFF2A2D3E), width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  _actionButton(
                    icon: Icons.phone_rounded,
                    label: 'Call Back',
                    color: const Color(AppConstants.colorSuccess),
                    onTap: () async {
                      final uri = Uri(scheme: 'tel', path: log.callerNumber);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    icon: Icons.smart_toy_rounded,
                    label: 'AI Reply',
                    color: const Color(AppConstants.colorPrimary),
                    onTap: () => context.push('/reply/${log.id}'),
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    icon: Icons.check_circle_rounded,
                    label: 'Done',
                    color: const Color(AppConstants.colorTextSecondary),
                    onTap: () async {
                      await updateCallStatus(log.id, 'done');
                      if (context.mounted) context.pop();
                    },
                  ),
                  const SizedBox(width: 8),
                  _actionButton(
                    icon: Icons.block_rounded,
                    label: 'Block',
                    color: const Color(AppConstants.colorUrgent),
                    onTap: () async {
                      final existing = await _callControl.getBlockedNumbers();
                      final updated = <String>{
                        ...existing,
                        log.callerNumber,
                      }.toList();
                      await _callControl.setBlockedNumbers(updated);
                      await updateCallStatus(log.id, 'blocked');
                      if (context.mounted) context.pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(AppConstants.colorTextSecondary),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
