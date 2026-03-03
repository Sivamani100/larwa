// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/call_logs_provider.dart';
import '../../providers/ai_mode_provider.dart';
import '../../providers/local_call_logs_provider.dart';
import '../../core/constants.dart';
import '../../services/call_control_service.dart';
import 'call_log_card.dart';
import 'ai_mode_toggle.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedFilter = 'all';
  int _currentNavIndex = 0;

  int _unreadCount(List<dynamic> logs) {
    try {
      return logs.where((l) => (l.status ?? '') == 'new').length;
    } catch (_) {
      return 0;
    }
  }

  Widget _navIconWithBadge({required IconData icon, required int badgeCount}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (badgeCount > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(AppConstants.colorUrgent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static final _dialerRoleHeldProvider = FutureProvider<bool>((ref) async {
    final cc = CallControlService();
    return cc.isRoleHeld();
  });

  Widget _buildInboxTab({required AsyncValue callLogsAsync}) {
    return callLogsAsync.when(
      data: (logs) {
        final unread = logs.where((l) => l.status == 'new').toList();

        if (unread.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.white.withOpacity(0.15),
                ),
                const SizedBox(height: 16),
                Text(
                  'Inbox is empty',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'New call summaries will appear here',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(AppConstants.colorPrimary),
          backgroundColor: const Color(AppConstants.colorCardBg),
          onRefresh: () async {
            ref.invalidate(callLogsProvider);
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: unread.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) => CallLogCard(
              log: unread[index],
              onTap: () => context.push('/detail/${unread[index].id}'),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(AppConstants.colorPrimary),
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(AppConstants.colorUrgent),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Error: $e',
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(callLogsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallsTab({
    required AsyncValue callLogsAsync,
    required AiModeState aiMode,
  }) {
    final localAsync = ref.watch(localCallLogsProvider);
    final roleAsync = ref.watch(_dialerRoleHeldProvider);
    return Column(
      children: [
        // ── AI MODE TOGGLE ──────────────────────────────
        const AiModeToggleWidget(),

        // ── LIVE CALL INDICATOR ──────────────────────────
        if (aiMode.isLiveCallActive)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1F3D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
            ),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) => Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(value),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(value * 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'AI is on a call now...',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),

        // ── FILTER CHIPS ────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'new', 'urgent', 'important', 'spam']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          filter[0].toUpperCase() + filter.substring(1),
                        ),
                        selected: _selectedFilter == filter,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                        selectedColor: const Color(AppConstants.colorPrimary),
                        backgroundColor: const Color(AppConstants.colorSurface),
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter
                              ? Colors.white
                              : const Color(AppConstants.colorTextSecondary),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        // ── DEFAULT DIALER BANNER ───────────────────────
        roleAsync.when(
          data: (held) {
            if (held) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppConstants.colorCardBg),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(
                    AppConstants.colorWarning,
                  ).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(AppConstants.colorWarning),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Set Larwa as your default phone app to enable silent answering.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => context.push('/setup'),
                    child: const Text('Setup'),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),

        // ── LOCAL EVENTS (HIVE) ──────────────────────────
        localAsync.when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            final top = items.take(3).toList();
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(AppConstants.colorSurface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(
                    AppConstants.colorTextSecondary,
                  ).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local events',
                    style: TextStyle(
                      color: Color(AppConstants.colorTextSecondary),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...top.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(AppConstants.colorTextSecondary),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${e.title} — ${e.callerNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),

        // ── CALL LOGS LIST ──────────────────────────────
        Expanded(
          child: callLogsAsync.when(
            data: (logs) {
              // Apply filter
              final filtered = _selectedFilter == 'all'
                  ? logs
                  : logs.where((l) {
                      switch (_selectedFilter) {
                        case 'new':
                          return l.status == 'new';
                        case 'urgent':
                          return l.urgencyLevel == 'urgent' ||
                              l.urgencyLevel == 'high';
                        case 'important':
                          return l.callType == 'important';
                        case 'spam':
                          return l.callType == 'spam';
                        default:
                          return true;
                      }
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.call_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFilter == 'all'
                            ? 'No calls yet'
                            : 'No $_selectedFilter calls',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Turn on AI Mode to start intercepting calls',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(AppConstants.colorPrimary),
                backgroundColor: const Color(AppConstants.colorCardBg),
                onRefresh: () async {
                  ref.invalidate(callLogsProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) => CallLogCard(
                    log: filtered[index],
                    onTap: () => context.push('/detail/${filtered[index].id}'),
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: Color(AppConstants.colorPrimary),
              ),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(AppConstants.colorUrgent),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(callLogsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final callLogsAsync = ref.watch(callLogsProvider);
    final aiMode = ref.watch(aiModeProvider);
    final unread = callLogsAsync.when(
      data: (logs) => _unreadCount(logs),
      loading: () => 0,
      error: (e, st) => 0,
    );

    return Scaffold(
      backgroundColor: const Color(AppConstants.colorBackground),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.colorCardBg),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90D9), Color(0xFF7B68EE)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Larwa',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildCallsTab(callLogsAsync: callLogsAsync, aiMode: aiMode),
          _buildInboxTab(callLogsAsync: callLogsAsync),
          const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == 2) {
            context.push('/settings');
            return;
          }
          setState(() => _currentNavIndex = index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.call_rounded),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: _navIconWithBadge(
              icon: Icons.inbox_rounded,
              badgeCount: unread,
            ),
            label: 'Inbox',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
