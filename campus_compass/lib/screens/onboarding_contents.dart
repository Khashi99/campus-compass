import 'package:flutter/material.dart';

class OnboardingContents {
  final String title;
  final String description;
  final String? image;
  final List<OnboardingBullet> bullets;
  final List<AlertOption> alertOptions;
  final String buttonText;
  final bool showSkip;
  final String? quote;

  const OnboardingContents({
    required this.title,
    required this.description,
    required this.buttonText,
    this.image,
    this.bullets = const [],
    this.alertOptions = const [],
    this.showSkip = true,
    this.quote,
  });
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

const List<OnboardingContents> contents = [
  OnboardingContents(
    title: 'Navigate Campus Safely',
    description:
        'Providing you with a calm and accessible tool for a user-centric safety experience.',
    buttonText: 'Get Started',
    showSkip: true,
    bullets: [
      OnboardingBullet(
        icon: Icons.shield_outlined,
        iconColor: Color(0xFF22C55E),
        text: 'Avoid high-tension zones',
      ),
      OnboardingBullet(
        icon: Icons.notifications_none_rounded,
        iconColor: Color(0xFF369DF4),
        text: 'Get calm, non-intrusive alerts',
      ),
      OnboardingBullet(
        icon: Icons.wifi_off_rounded,
        iconColor: Color(0xFF6B7280),
        text: 'Works offline for reliability',
      ),
    ],
  ),
  OnboardingContents(
    title: 'Choose Alert Style',
    description:
        'Safety is personal. Choose how you want to be notified when nearing tension zones.',
    buttonText: 'Continue',
    showSkip: false,
    alertOptions: [
      AlertOption(
        icon: Icons.notification_important_outlined,
        title: 'Haptic & Visual',
        subtitle: 'You\'d like to see and feel the alert',
      ),
      AlertOption(
        icon: Icons.remove_red_eye_outlined,
        title: 'Visual only',
        subtitle: 'Subtle banners on your screen',
      ),
      AlertOption(
        icon: Icons.vibration_rounded,
        title: 'Haptic only',
        subtitle: 'Vibrations you can feel instantly',
      ),
      AlertOption(
        icon: Icons.notifications_off_outlined,
        title: 'Silent',
        subtitle: 'Discreet alerts in your feed',
      ),
    ],
    quote:
        'We prioritize your comfort. These settings ensure you receive information in a way that reduces anxiety.',
  ),
];
