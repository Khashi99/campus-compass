import 'package:campus_compass/firebase_options.dart';
import 'package:campus_compass/screens/login_screen.dart';
import 'package:campus_compass/screens/map_screen.dart';
import 'package:campus_compass/screens/onboarding_screen.dart';
import 'package:campus_compass/screens/safety_route_screen.dart';
import 'package:campus_compass/support/app_prefs_keys.dart';
import 'package:campus_compass/theme/app_theme.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:campus_compass/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.instance.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          routes: {
            '/login': (context) => const LoginScreen(),
            '/map': (context) => const MapScreen(),
            '/safety-route': (context) => const SafetyRouteScreen(),
            '/home': (context) => const HomeScreen(),
          },
          title: 'Campus Compass',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: const _StartupGate(),
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

