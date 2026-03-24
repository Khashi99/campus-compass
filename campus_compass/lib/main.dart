import 'package:campus_compass/firebase_options.dart';
import 'package:campus_compass/screens/login_screen.dart';
import 'package:campus_compass/screens/map_screen.dart';
import 'package:campus_compass/screens/onboarding_screen.dart';
import 'package:campus_compass/screens/safety_route_screen.dart';
import 'package:campus_compass/theme/app_theme.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppThemeController.instance.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

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
          },
          title: 'Campus Compass',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          home: const OnboardingScreen(),

          // For testing: Use MapScreen directly
          // For production: Use OnboardingScreen and navigate to MapScreen after
          //home: const MapScreen(),
        );
      },
    );
  }
}

