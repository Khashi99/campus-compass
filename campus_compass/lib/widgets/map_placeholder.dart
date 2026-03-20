import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';

class MapPlaceholder extends StatelessWidget {
  final bool showTensionZone;
  final String? tensionZoneLabel;
  final Offset? tensionZonePosition;

  const MapPlaceholder({
    super.key,
    this.showTensionZone = false,
    this.tensionZoneLabel,
    this.tensionZonePosition,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mapBackground,
      child: Stack(
        children: [
          // Actual campus map image
          Positioned.fill(
            child: Image.asset(
              'assets/images/floor_plan.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Tension zone overlay
          if (showTensionZone)
            Positioned(
              left: tensionZonePosition?.dx ?? 80,
              top: tensionZonePosition?.dy ?? 200,
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.tensionZone.withOpacity(0.25),
                      border: Border.all(
                        color: AppColors.tensionZone.withOpacity(0.7),
                        width: 3,
                      ),
                    ),
                  ),
                  if (tensionZoneLabel != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusHighRisk,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tensionZoneLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Current location marker (blue dot)
          Positioned(
            right: 100,
            bottom: 150,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Zoom controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                _buildZoomButton(Icons.add),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove),
              ],
            ),
          ),
          // Compass
          Positioned(
            right: 16,
            top: 100,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation,
                color: AppColors.statusHighRisk,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.darkText,
        size: 20,
      ),
    );
  }
}

class MiniMapButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniMapButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              'View Live Map',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}