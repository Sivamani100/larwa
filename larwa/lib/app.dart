// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers/settings_provider.dart';
import 'services/ai_call_service.dart';
import 'providers/ai_mode_provider.dart';

class LarwaApp extends ConsumerStatefulWidget {
  const LarwaApp({super.key});

  @override
  ConsumerState<LarwaApp> createState() => _LarwaAppState();
}

class _LarwaAppState extends ConsumerState<LarwaApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(settingsProvider.notifier).loadSettings();
      ref.read(aiModeProvider.notifier).loadInitial();
      // Initialize AI Call Service brain
      ref.read(aiCallServiceProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Larwa',
      debugShowCheckedModeBanner: false,
      theme: LarwaTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
