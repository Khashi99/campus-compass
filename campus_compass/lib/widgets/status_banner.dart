import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';

enum CampusStatus {
  normal,
  caution,
  highRisk,
}

extension CampusStatusExtension on CampusStatus {
  String get displayText {
    switch (this) {
      case CampusStatus.normal:
        return 'Normal';
      case CampusStatus.caution:
        return 'Caution';
      case CampusStatus.highRisk:
        return 'HIGH RISK';
    }
  }

  Color get color {
    switch (this) {
      case CampusStatus.normal:
        return AppColors.statusNormal;
      case CampusStatus.caution:
        return AppColors.statusCaution;
      case CampusStatus.highRisk:
        return AppColors.statusHighRisk;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CampusStatus.normal:
        return AppColors.statusNormal;
      case CampusStatus.caution:
        return AppColors.statusCaution;
      case CampusStatus.highRisk:
        return AppColors.statusHighRisk;
    }
  }

  Color get textColor {
    switch (this) {
      case CampusStatus.normal:
        return Colors.white;
      case CampusStatus.caution:
        return AppColors.darkText;
      case CampusStatus.highRisk:
        return Colors.white;
    }
  }
}

class StatusBanner extends StatelessWidget {
  final CampusStatus status;
  final VoidCallback? onMoreInfo;

  const StatusBanner({
    super.key,
    required this.status,
    this.onMoreInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: status.backgroundColor,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              _getStatusIcon(),
              color: status.textColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live Campus Status: ${status.displayText}',
                style: TextStyle(
                  color: status.textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            if (onMoreInfo != null)
              GestureDetector(
                onTap: onMoreInfo,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status.textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'More Info',
                    style: TextStyle(
                      color: status.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case CampusStatus.normal:
        return Icons.check_circle;
      case CampusStatus.caution:
        return Icons.warning_amber_rounded;
      case CampusStatus.highRisk:
        return Icons.error;
    }
  }
}

class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Map Legend',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem(AppColors.safeRoute, 'Safe Route'),
          const SizedBox(height: 4),
          _buildLegendItem(AppColors.tensionZone, 'Tension Zone'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}