import 'package:campus_compass/firebase_options.dart';
import 'package:campus_compass/screens/login_screen.dart';
import 'package:campus_compass/screens/map_screen.dart';
import 'package:campus_compass/screens/onboarding_screen.dart';
import 'package:campus_compass/screens/safety_route_screen.dart';
import 'package:campus_compass/screens/report_incident_screen.dart';
import 'package:campus_compass/screens/alerts_screen.dart';
import 'package:campus_compass/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_compass/support/app_prefs_keys.dart';
import 'package:campus_compass/theme/app_theme.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:campus_compass/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_compass/utils/notification_service.dart';
import 'package:campus_compass/services/incident_status_monitor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.instance.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications and start status monitor.
  await NotificationService.instance.init();
  // Start monitoring incident status changes while the app is running.
  IncidentStatusMonitor.instance.start();

  // No automatic anonymous sign-in. Only proceed if user is authenticated.
  await _ensureUserProfileDocument();

  runApp(const MyApp());
}

Future<void> _ensureUserProfileDocument() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return;
  }

  final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snapshot = await usersRef.get();
  final now = FieldValue.serverTimestamp();

  if (!snapshot.exists) {
    await usersRef.set({
      'displayName': 'Anonymous User',
      'alertPreference': {
        'mode': 'haptic',
        'quietHours': null,
      },
      'createdAt': now,
      'updatedAt': now,
    });
    return;
  }

  await usersRef.set({
    'updatedAt': now,
  }, SetOptions(merge: true));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/onboarding',
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        final loc = state.uri.toString();
        final loggingIn = loc == '/login' || loc == '/onboarding';
        final goingHome = loc == '/home' || loc.startsWith('/home/');

        // If logged in, don't allow visiting onboarding or login
        if (user != null && loggingIn) {
          return '/home/map';
        }

        // If not logged in, don't allow visiting home routes
        if (user == null && goingHome) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/home',
          redirect: (context, state) => '/home/map',
        ),

        ShellRoute(
          builder: (context, state, child) {
            // Compute the active tab index from the current URI path and
            // pass it into the HomeScreen so the shell highlights correctly
            // on forward/back navigation.
            final path = state.uri.path;
            var tabIndex = 0;
            if (path.startsWith('/home/report')) {
              tabIndex = 1;
            } else if (path.startsWith('/home/alerts')) {
              tabIndex = 2;
            } else if (path.startsWith('/home/profile')) {
              tabIndex = 3;
            } else if (path.startsWith('/home/map') || path.startsWith('/map')) {
              tabIndex = 0;
            }

            return HomeScreen(key: ValueKey(state.uri.toString()), tabIndex: tabIndex, child: child);
          },
          routes: [
            GoRoute(
              path: '/home/map',
              builder: (context, state) => const MapScreen(),
            ),
            GoRoute(
              path: '/home/report',
              builder: (context, state) => const ReportIncidentScreen(),
            ),
            GoRoute(
              path: '/home/alerts',
              builder: (context, state) => const AlertsScreen(),
            ),
            GoRoute(
              path: '/home/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/safety-route',
          builder: (context, state) => const SafetyRouteScreen(),
        ),
      ],
    );

    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Campus Compass',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          routerConfig: _router,
        );
      },
    );
  }
}

class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<Widget> _resolveInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool(kOnboardingCompletedKey) ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    if (user == null) {
      return const LoginScreen();
    }

    await _ensureUserProfileDocument();
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _resolveInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const LoginScreen();
        }

        return snapshot.data ?? const LoginScreen();
      },
    );
  }
}

