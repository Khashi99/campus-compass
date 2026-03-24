import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/models/incident.dart';

/// Card shown when campus is calm (Screen 1)
class CalmStatusCard extends StatelessWidget {
  final VoidCallback? onTap;

  const CalmStatusCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.statusNormal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.statusNormal,
                size: 28,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus is Calm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.verifiedBadge.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 12,
                              color: AppColors.verifiedBadge,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified by Campus Safety',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.verifiedBadge,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for incident preview (Screen 2) - WITH ANIMATED PROGRESS BAR
class IncidentPreviewCard extends StatefulWidget {
  final Incident incident;
  final VoidCallback? onViewDetails;

  const IncidentPreviewCard({
    super.key,
    required this.incident,
    this.onViewDetails,
  });

  @override
  State<IncidentPreviewCard> createState() => _IncidentPreviewCardState();
}

class _IncidentPreviewCardState extends State<IncidentPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller - runs for 3 seconds, repeats
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Animate from current progress to current progress + 15%, then back
    // This creates a "pulsing" effect like it's actively verifying
    _progressAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.incident.verificationProgress / 100,
          end: (widget.incident.verificationProgress + 15).clamp(0, 100) / 100,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: (widget.incident.verificationProgress + 15).clamp(0, 100) / 100,
          end: widget.incident.verificationProgress / 100,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Start the animation and repeat
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.statusCaution.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.statusCaution,
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.incident.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${widget.incident.userReports} reports • ${widget.incident.timeAgo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Animated verification progress
          Row(
            children: [
              // Pulsing verification icon
              _buildPulsingIcon(),
              SizedBox(width: 6),
              Text(
                'Verifying...',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.verifiedBadge,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 12),
              // Animated progress bar
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.verifiedBadge,
                        ),
                        minHeight: 6,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 8),
              // Animated percentage
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onViewDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'View Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pulsing green dot indicator
  Widget _buildPulsingIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.verifiedBadge.withOpacity(
              0.5 + (_controller.value * 0.5), // Pulses between 0.5 and 1.0 opacity
            ),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.verifiedBadge,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// High risk alert card (Screen 3)
class HighRiskAlertCard extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onViewDetails;
  final VoidCallback? onNavigateToSafety;
  final VoidCallback? onReportTrust;

  const HighRiskAlertCard({
    super.key,
    required this.incident,
    this.onViewDetails,
    this.onNavigateToSafety,
    this.onReportTrust,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.statusHighRisk,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'VERIFIED BY ${incident.userReports} STUDENTS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 16),
                // Reliability indicator
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.statusNormal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 14,
                            color: AppColors.statusNormal,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${incident.verificationProgress}% RELIABILITY',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.statusNormal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: onViewDetails,
                      child: Text(
                        'View Details & Live Updates',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReportTrust,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mutedText,
                          side: BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'REPORT TRUST',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onNavigateToSafety,
                        icon: Icon(Icons.directions, size: 18),
                        label: Text(
                          'Navigate to Safety',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusNormal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}