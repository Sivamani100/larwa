// lib/screens/detail/transcript_view.dart
import 'package:flutter/material.dart';
import '../../models/call_log.dart';
import '../../core/constants.dart';

class TranscriptView extends StatelessWidget {
  final List<TranscriptEntry> transcript;

  const TranscriptView({super.key, required this.transcript});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transcript.map((entry) {
        final isCaller = entry.speaker == 'caller';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment:
                isCaller ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCaller) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      const Color(AppConstants.colorPrimary).withOpacity(0.2),
                  child: const Icon(Icons.person, size: 16, color: Color(AppConstants.colorPrimary)),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCaller
                        ? const Color(AppConstants.colorSurface)
                        : const Color(AppConstants.colorPrimary)
                            .withOpacity(0.15),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isCaller ? 2 : 12),
                      bottomRight: Radius.circular(isCaller ? 12 : 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCaller ? 'Caller' : 'AI Assistant',
                        style: TextStyle(
                          color: isCaller
                              ? const Color(AppConstants.colorWarning)
                              : const Color(AppConstants.colorPrimary),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isCaller) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(AppConstants.colorPrimary)
                      .withOpacity(0.2),
                  child: const Icon(Icons.smart_toy,
                      size: 16, color: Color(AppConstants.colorPrimary)),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}
