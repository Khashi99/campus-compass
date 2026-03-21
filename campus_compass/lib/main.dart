import 'package:campus_compass/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme.dart';
import 'package:campus_compass/screens/map_screen.dart';
import 'package:campus_compass/screens/login_Screen.dart';
import 'package:campus_compass/screens/incident_detail_screen.dart';
import 'package:campus_compass/models/incident.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes:{
        '/login': (context) => const LoginScreen(),
        '/map': (context) => const MapScreen(),
      },
      title: 'Campus Compass',
      debugShowCheckedModeBanner: false,
      // AppTheme holds elevatedButtonTheme, textButtonTheme, textTheme, etc.
      theme: AppTheme.appTheme.copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
        ),
      ),
      home: const OnboardingScreen(),
      
      // For testing: Use MapScreen directly
      // For production: Use OnboardingScreen and navigate to MapScreen after
      //home: const MapScreen(),

    );
  }
}

