// lib/screens/home/ai_mode_toggle.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_mode_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants.dart';

class AiModeToggleWidget extends ConsumerWidget {
  const AiModeToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiMode = ref.watch(aiModeProvider);
    final settings = ref.watch(settingsProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: aiMode.isEnabled
            ? LinearGradient(
                colors: [
                  const Color(0xFF1B5E20).withOpacity(0.3),
                  const Color(0xFF2E7D32).withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: aiMode.isEnabled ? null : const Color(AppConstants.colorCardBg),
        border: Border.all(
          color: aiMode.isEnabled
              ? const Color(AppConstants.colorSuccess).withOpacity(0.4)
              : const Color(0xFF2A2D3E),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Status icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: aiMode.isEnabled
                        ? const Color(
                            AppConstants.colorSuccess,
                          ).withOpacity(0.2)
                        : const Color(AppConstants.colorSurface),
                  ),
                  child: Icon(
                    aiMode.isEnabled
                        ? Icons.shield_rounded
                        : Icons.shield_outlined,
                    color: aiMode.isEnabled
                        ? const Color(AppConstants.colorSuccess)
                        : const Color(AppConstants.colorTextSecondary),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aiMode.isEnabled ? 'AI Active' : 'AI Inactive',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        aiMode.isEnabled
                            ? 'All calls being intercepted'
                            : 'Calls will ring normally',
                        style: TextStyle(
                          color: aiMode.isEnabled
                              ? const Color(
                                  AppConstants.colorSuccess,
                                ).withOpacity(0.8)
                              : const Color(AppConstants.colorTextSecondary),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggle
                Transform.scale(
                  scale: 1.2,
                  child: Switch(
                    value: aiMode.isEnabled,
                    onChanged: aiMode.isLoading
                        ? null
                        : (_) => ref.read(aiModeProvider.notifier).toggle(),
                    activeColor: const Color(AppConstants.colorSuccess),
                    activeTrackColor: const Color(AppConstants.colorSuccess).withOpacity(0.3),
                    inactiveThumbColor: const Color(AppConstants.colorTextSecondary),
                    inactiveTrackColor: const Color(AppConstants.colorSurface),
                  ),
                ),
              ],
            ),
            // Loading indicator
            if (aiMode.isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                color: Color(AppConstants.colorPrimary),
                backgroundColor: Color(AppConstants.colorSurface),
              ),
            ],
            // Error message
            if (aiMode.error != null) ...[
              const SizedBox(height: 8),
              Text(
                aiMode.error!,
                style: const TextStyle(
                  color: Color(AppConstants.colorUrgent),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
