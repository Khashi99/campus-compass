import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final String buttonText;
  final bool showSkip;
  final bool showBackTitle;
  final List<OnboardingBullet> bullets;
  final List<AlertOption> alertOptions;
  final String? quote;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    required this.buttonText,
    this.showSkip = false,
    this.showBackTitle = false,
    this.bullets = const [],
    this.alertOptions = const [],
    this.quote,
  });

  bool get isAlertPage => alertOptions.isNotEmpty;
  bool get isBulletPage => bullets.isNotEmpty;
}

class OnboardingBullet {
  final IconData icon;
  final Color iconColor;
  final String text;

  const OnboardingBullet({
    required this.icon,
    required this.iconColor,
    required this.text,
  });
}

class AlertOption {
  final IconData icon;
  final String title;
  final String subtitle;

  const AlertOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}