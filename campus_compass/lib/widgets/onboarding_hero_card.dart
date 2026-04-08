import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingHeroCard extends StatelessWidget {
  const OnboardingHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 255,
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 38,
            top: 48,
            child: Transform.rotate(
              angle: 0.06,
              child: const _MapCard(width: 92, height: 62),
            ),
          ),
          Positioned(
            right: 42,
            top: 95,
            child: Transform.rotate(
              angle: -0.03,
              child: const _MapCard(width: 92, height: 96),
            ),
          ),
          Positioned(
            left: 78,
            top: 120,
            child: Transform.rotate(
              angle: 0.08,
              child: const _MapCard(width: 92, height: 62),
            ),
          ),
          Positioned(
            left: 36,
            top: 142,
            child: Icon(Icons.location_on_outlined,
                size: 26, color: Color(0xFF111827)),
          ),
          Positioned(
            right: 64,
            top: 36,
            child:
                Icon(Icons.place_outlined, size: 24, color: Color(0xFF4ADE80)),
          ),
          Positioned(
            top: 24,
            left: 42,
            child: SizedBox(
              width: 220,
              height: 90,
              child: CustomPaint(
                painter: _DashedCurvePainter(
                  color: const Color(0xFFBFDBFE),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 36,
            child: SizedBox(
              width: 250,
              height: 60,
              child: CustomPaint(
                painter: _DashedCurvePainter(
                  color: const Color(0xFFBBF7D0),
                  flip: true,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Secure Campus',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final double width;
  final double height;

  const _MapCard({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.quoteBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
    );
  }
}

class _DashedCurvePainter extends CustomPainter {
  final Color color;
  final bool flip;

  _DashedCurvePainter({
    required this.color,
    this.flip = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (!flip) {
      path.moveTo(0, size.height * 0.35);
      path.quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.95,
        size.width,
        size.height * 0.15,
      );
    } else {
      path.moveTo(0, size.height * 0.8);
      path.quadraticBezierTo(
        size.width * 0.45,
        0,
        size.width,
        size.height * 0.55,
      );
    }

    final dashed = _createDashedPath(path, dashLength: 7, gapLength: 6);
    canvas.drawPath(dashed, paint);
  }

  Path _createDashedPath(
    Path source, {
    required double dashLength,
    required double gapLength,
  }) {
    final dashedPath = Path();

    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
