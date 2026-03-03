// lib/providers/ai_mode_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/call_control_service.dart';

class AiModeState {
  final bool isEnabled;
  final bool isLoading;
  final bool isLiveCallActive;
  final String? error;

  const AiModeState({
    this.isEnabled = false,
    this.isLoading = false,
    this.isLiveCallActive = false,
    this.error,
  });

  AiModeState copyWith({
    bool? isEnabled,
    bool? isLoading,
    bool? isLiveCallActive,
    String? error,
  }) {
    return AiModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      isLiveCallActive: isLiveCallActive ?? this.isLiveCallActive,
      error: error,
    );
  }
}

class AiModeNotifier extends StateNotifier<AiModeState> {
  final _callControl = CallControlService();

  AiModeNotifier() : super(const AiModeState());

  Future<void> loadInitial() async {
    try {
      final enabled = await _callControl.getAiMode();
      state = state.copyWith(isEnabled: enabled);
    } catch (_) {
      // ignore
    }
  }

  Future<void> toggle() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    final newEnabled = !state.isEnabled;
    try {
      await _callControl.toggleAiMode(newEnabled);
      state = state.copyWith(isEnabled: newEnabled, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to toggle AI mode: $e',
      );
    }
  }

  void setLiveCall(bool active) {
    state = state.copyWith(isLiveCallActive: active);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final aiModeProvider = StateNotifierProvider<AiModeNotifier, AiModeState>((
  ref,
) {
  return AiModeNotifier();
});
