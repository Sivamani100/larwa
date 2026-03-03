// lib/screens/reply/ai_reply_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/call_logs_provider.dart';
import '../../services/backend_service.dart';
import '../../core/constants.dart';

class AiReplyScreen extends ConsumerStatefulWidget {
  final String callLogId;

  const AiReplyScreen({super.key, required this.callLogId});

  @override
  ConsumerState<AiReplyScreen> createState() => _AiReplyScreenState();
}

class _AiReplyScreenState extends ConsumerState<AiReplyScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;
  bool _isSent = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendReply(String toNumber, String callerName) async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      await BackendService.triggerCallback(
        toNumber: toNumber,
        message: _controller.text.trim(),
        callerName: callerName,
        callLogId: widget.callLogId,
      );
      await updateCallStatus(widget.callLogId, 'replied');
      setState(() {
        _isSending = false;
        _isSent = true;
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _error = 'Failed to send: $e';
      });
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
        title: const Text('Reply via AI'),
      ),
      body: logAsync.when(
        data: (log) {
          if (log == null) {
            return const Center(
                child: Text('Call not found',
                    style: TextStyle(color: Colors.white)));
          }

          if (_isSent) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.colorSuccess)
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Color(AppConstants.colorSuccess), size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AI is calling back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI is calling ${log.displayName} with your message.',
                    style: const TextStyle(
                      color: Color(AppConstants.colorTextSecondary),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Calls'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caller info header
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.colorCardBg),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(AppConstants.colorPrimary)
                            .withOpacity(0.15),
                        child: Text(
                          log.displayName.isNotEmpty
                              ? log.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(AppConstants.colorPrimary),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              log.callerNumber,
                              style: const TextStyle(
                                color: Color(AppConstants.colorTextSecondary),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Context reminder
                if (log.actionNeeded != null && log.actionNeeded!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.colorWarning)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(AppConstants.colorWarning)
                            .withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'They called about:',
                          style: TextStyle(
                            color: Color(AppConstants.colorWarning),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // Message input
                const Text(
                  'What do you want to tell them?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  maxLength: 250,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText:
                        'e.g., Tell him I\'ll have the quote ready by Thursday...',
                    counterStyle: const TextStyle(
                        color: Color(AppConstants.colorTextSecondary)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Preview
                if (_controller.text.trim().isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.colorSurface),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI will say something like:',
                          style: TextStyle(
                            color: Color(AppConstants.colorTextSecondary),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"Hi ${log.displayName}, this is your contact\'s assistant calling back on their behalf. ${_controller.text.trim()} If you need anything else, please call back."',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Error
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style:
                        const TextStyle(color: Color(AppConstants.colorUrgent)),
                  ),
                ],
                const SizedBox(height: 24),

                // Send button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isSending || _controller.text.trim().isEmpty
                        ? null
                        : () => _sendReply(log.callerNumber, log.displayName),
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(_isSending ? 'Calling...' : 'Send via AI Call'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: Color(AppConstants.colorPrimary)),
        ),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}
