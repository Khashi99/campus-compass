import 'package:campus_compass/theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../models/onboarding_models.dart';
import '../theme/app_colors.dart';

class OnboardingBulletTile extends StatelessWidget {
  final OnboardingBullet bullet;

  const OnboardingBulletTile({
    super.key,
    required this.bullet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lightCircle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              bullet.icon,
              color: bullet.iconColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              bullet.text,
              style: AppTheme.bulletStyle,
            ),
          ),
        ],
      ),
    );
  }
}