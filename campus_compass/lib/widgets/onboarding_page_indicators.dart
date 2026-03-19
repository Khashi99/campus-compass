import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentPage ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == currentPage
                ? AppColors.primaryBlue
                : const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}