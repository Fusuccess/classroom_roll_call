import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/roll_call/roll_call_screen.dart';
import '../../features/class_management/class_list_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/roll-call/:classId',
        builder: (context, state) {
          final classId = state.pathParameters['classId']!;
          return RollCallScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/classes',
        builder: (context, state) => const ClassListScreen(),
      ),
      GoRoute(
        path: '/statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
