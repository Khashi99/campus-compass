import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'onboarding_page_indicators.dart';

class OnboardingAppBar extends StatelessWidget {
  final bool showSkip;
  final bool showBackTitle;
  final VoidCallback? onSkip;
  final VoidCallback? onBack;

  const OnboardingAppBar({
    super.key,
    required this.showSkip,
    required this.showBackTitle,
    this.onSkip,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          if (showBackTitle)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onBack,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
            )
          else
            const SizedBox(width: 32),
          Expanded(
            child: Center(
              child: Text(
                showBackTitle ? 'Personalize Alerts' : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkText,
                ),
              ),
            ),
          ),
          showSkip
              ? TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                )
              : SizedBox(width: 52),
        ],
      ),
    );
  }
}


class OnboardingBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String buttonText;
  final bool showArrow;
  final VoidCallback onPressed;

  const OnboardingBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.buttonText,
    required this.showArrow,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageIndicator(
          currentPage: currentPage,
          totalPages: totalPages,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (showArrow) ...[
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}