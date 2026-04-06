import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int alertBadgeCount;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.alertBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
    return AnimatedBuilder(
      animation: AppThemeController.instance,
      builder: (context, _) {
        final isDark = AppColors.white.computeLuminance() < 0.5;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.map_outlined, Icons.map, 'Map'),
                  if (!isGuest)
                    _buildNavItem(
                      1,
                      Icons.add_circle_outline,
                      Icons.add_circle,
                      'Report',
                    ),
                  _buildNavItem(
                    2,
                    Icons.notifications_outlined,
                    Icons.notifications,
                    'Alerts',
                    badgeCount: alertBadgeCount,
                  ),
                  _buildNavItem(
                    3,
                    Icons.person_outline,
                    Icons.person,
                    'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label, {
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.mutedText,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.statusHighRisk,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        badgeCount > 9 ? '9+' : badgeCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
