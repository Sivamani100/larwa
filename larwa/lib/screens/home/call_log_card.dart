// lib/screens/home/call_log_card.dart
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/call_log.dart';
import '../../core/constants.dart';

class CallLogCard extends StatelessWidget {
  final CallLog log;
  final VoidCallback onTap;

  const CallLogCard({super.key, required this.log, required this.onTap});

  Color get _urgencyColor {
    switch (log.urgencyLevel) {
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

  IconData get _typeIcon {
    switch (log.callType) {
      case 'spam':
        return Icons.block_rounded;
      case 'urgent':
        return Icons.priority_high_rounded;
      case 'important':
        return Icons.star_rounded;
      case 'event':
        return Icons.event_rounded;
      default:
        return Icons.phone_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppConstants.colorCardBg),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: _urgencyColor, width: 3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar w/ urgency dot
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _urgencyColor.withOpacity(0.15),
                    child: Text(
                      log.displayName.isNotEmpty
                          ? log.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: _urgencyColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (log.isNew)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.colorPrimary),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(AppConstants.colorCardBg),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              // Name + summary
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            log.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeago.format(log.callStartTime, locale: 'en_short'),
                          style: const TextStyle(
                            color: Color(AppConstants.colorTextSecondary),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (log.aiSummary != null)
                      Text(
                        log.aiSummary!,
                        style: const TextStyle(
                          color: Color(AppConstants.colorTextSecondary),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Call type chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _urgencyColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_typeIcon,
                                  size: 12, color: _urgencyColor),
                              const SizedBox(width: 4),
                              Text(
                                (log.urgencyLevel ?? 'low').toUpperCase(),
                                style: TextStyle(
                                  color: _urgencyColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined,
                            size: 12,
                            color:
                                const Color(AppConstants.colorTextSecondary)),
                        const SizedBox(width: 3),
                        Text(
                          log.durationFormatted,
                          style: const TextStyle(
                            color: Color(AppConstants.colorTextSecondary),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: const Color(AppConstants.colorTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
