import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/home_screen.dart';
import '../presentation/screens/incident_alert_screen.dart';
import '../presentation/screens/campus_map_screen.dart';
import '../presentation/screens/safe_route_screen.dart';
import '../presentation/screens/resources_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (ctx, state) => const HomeScreen()),
      GoRoute(
        path: '/incident/:id',
        builder: (ctx, state) => IncidentAlertScreen(
          incidentId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/map', builder: (ctx, state) => const CampusMapScreen()),
      GoRoute(path: '/route', builder: (ctx, state) => const SafeRouteScreen()),
      GoRoute(path: '/resources', builder: (ctx, state) => const ResourcesScreen()),
      GoRoute(path: '/settings', builder: (ctx, state) => const SettingsScreen()),
    ],
  );
});
