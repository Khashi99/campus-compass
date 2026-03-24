import 'package:campus_compass/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:campus_compass/models/safety_route_step.dart';
import 'package:campus_compass/theme/app_colors.dart';

class SafetyRouteStepTile extends StatelessWidget {
  final SafetyRouteStep step;

  const SafetyRouteStepTile({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Center(
              child: Icon(
                step.icon,
                size: 34,
                color: AppColors.darkText,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTheme.optionTitleStyle,
                ),
                SizedBox(height: 4),
                Text(
                  step.subtitle,
                  style: AppTheme.optionSubtitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}