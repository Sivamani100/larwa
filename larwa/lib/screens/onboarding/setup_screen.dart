// lib/screens/onboarding/setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/call_control_service.dart';
import '../../core/constants.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _callControl = CallControlService();
  int _currentStep = 0;
  bool _isPermissionLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.colorBackground),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    _buildStepRole(),
                    _buildStepPermissions(),
                    _buildStepDone(),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4A90D9), Color(0xFF7B68EE)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.security_rounded, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        const Text('Secure Setup', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Larwa needs these to protect your calls.', 
          style: TextStyle(color: Color(AppConstants.colorTextSecondary), fontSize: 14)),
      ],
    );
  }

  Widget _buildStepRole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Set as Default Phone App', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'To silently answer and handle your calls, Larwa must be your default phone app. This is the "Brain" of the operation.',
          style: TextStyle(color: Color(AppConstants.colorTextSecondary), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          label: 'Set Default Dialer',
          icon: Icons.phone_forwarded_rounded,
          onPressed: () async {
            await _callControl.requestRole();
          },
        ),
      ],
    );
  }

  Widget _buildStepPermissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enable Audio Access', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Larwa needs Microphone access to hear callers and Phone status to know when someone is calling.',
          style: TextStyle(color: Color(AppConstants.colorTextSecondary), fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 30),
        _buildActionButton(
          label: 'Grant Permissions',
          icon: Icons.mic_rounded,
          onPressed: () async {
            setState(() => _isPermissionLoading = true);
            await [Permission.microphone, Permission.phone].request();
            setState(() => _isPermissionLoading = false);
            setState(() => _currentStep = 2);
          },
        ),
      ],
    );
  }

  Widget _buildStepDone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: Color(AppConstants.colorSuccess), size: 100),
        const SizedBox(height: 20),
        const Text('You\'re all set!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Larwa is now ready to protect your attention.', 
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(AppConstants.colorTextSecondary), fontSize: 15)),
      ],
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.colorPrimary),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentStep ? 24 : 8, height: 8,
            decoration: BoxDecoration(
              color: i == _currentStep ? const Color(AppConstants.colorPrimary) : const Color(0xFF252836),
              borderRadius: BorderRadius.circular(4),
            ),
          )),
        ),
        const SizedBox(height: 24),
        if (_currentStep == 0) 
          TextButton(onPressed: () => setState(() => _currentStep = 1), 
            child: const Text('Already set? Continue', style: TextStyle(color: Color(AppConstants.colorTextSecondary)))),
        if (_currentStep == 2)
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(AppConstants.colorSuccess), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Finish Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}
