import 'package:flutter/material.dart';
import '../models/onboarding_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AlertOptionCard extends StatelessWidget {
  final AlertOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const AlertOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF8FBFF) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue
                  : AppColors.cardBorder,
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withValues(alpha: 0.14)
                      : AppColors.lightCircle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.mutedText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.title, style: AppTheme.optionTitleStyle),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: AppTheme.optionSubtitleStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.cardBorder,
                    width: 1.5,
                  ),
                  color: isSelected
                      ? AppColors.primaryBlue.withValues(alpha: 0.08)
                      : Colors.white,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primaryBlue,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}