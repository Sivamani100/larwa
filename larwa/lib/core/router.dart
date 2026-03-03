// lib/core/router.dart
import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/detail/call_detail_screen.dart';
import '../screens/reply/ai_reply_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/onboarding/setup_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final callLogId = state.pathParameters['id']!;
        return CallDetailScreen(callLogId: callLogId);
      },
    ),
    GoRoute(
      path: '/reply/:id',
      builder: (context, state) {
        final callLogId = state.pathParameters['id']!;
        return AiReplyScreen(callLogId: callLogId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
  ],
);
