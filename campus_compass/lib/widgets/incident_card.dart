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
  final VoidCallback? onNavigateToSafety;

  const IncidentPreviewCard({
    super.key,
    required this.incident,
    this.onViewDetails,
    this.onNavigateToSafety,
  });

  @override
  State<IncidentPreviewCard> createState() => _IncidentPreviewCardState();
}

class _IncidentPreviewCardState extends State<IncidentPreviewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // Animation controller - runs for 3 seconds, repeats
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _syncVerificationAnimation();
  }

  @override
  void didUpdateWidget(covariant IncidentPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncVerificationAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = _isVerified(widget.incident);

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
              isVerified
                  ? Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.verifiedBadge,
                    )
                  : _buildPulsingIcon(),
              SizedBox(width: 6),
              Text(
                isVerified ? 'Verified' : 'Reported',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.verifiedBadge,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _IncidentResolutionProgressMini(
            status: widget.incident.status,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
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
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onNavigateToSafety,
                  icon: Icon(Icons.directions, size: 16),
                  label: Text(
                    'Route',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusNormal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
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

  bool _isVerified(Incident incident) {
    return incident.status == IncidentStatus.verified ||
      incident.status == IncidentStatus.resolved;
  }

  void _syncVerificationAnimation() {
    if (_isVerified(widget.incident)) {
      _controller.stop();
      _controller.value = 1;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
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
                SizedBox(height: 14),
                _IncidentResolutionProgressMini(
                  status: incident.status,
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

class _IncidentResolutionProgressMini extends StatelessWidget {
  const _IncidentResolutionProgressMini({required this.status});

  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final currentStep = _currentStepIndex();
    final progressPercent = _progressPercent();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'RESOLUTION PROGRESS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.mutedText,
                ),
              ),
              Spacer(),
              Text(
                '$progressPercent%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              _buildStep(
                label: 'REPORTED',
                icon: Icons.near_me_rounded,
                stepIndex: 0,
                currentStep: currentStep,
              ),
              _buildConnector(currentStep >= 1),
              _buildStep(
                label: 'INVESTIGATING',
                icon: Icons.manage_search_rounded,
                stepIndex: 1,
                currentStep: currentStep,
              ),
              _buildConnector(currentStep >= 2),
              _buildStep(
                label: 'VERIFIED',
                icon: Icons.verified_outlined,
                stepIndex: 2,
                currentStep: currentStep,
              ),
              _buildConnector(currentStep >= 3),
              _buildStep(
                label: 'RESOLVED',
                icon: Icons.check_circle_outline,
                stepIndex: 3,
                currentStep: currentStep,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            _subtitleForStatus(),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.mutedText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required String label,
    required IconData icon,
    required int stepIndex,
    required int currentStep,
  }) {
    final isCompleted = stepIndex < currentStep;
    final isCurrent = stepIndex == currentStep;
    final isActive = isCompleted || isCurrent;

    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primaryBlue : AppColors.cardBorder,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : (isCurrent ? icon : Icons.circle),
            size: isCompleted
                ? 13
                : (isCurrent ? 13 : 6),
            color: isCompleted
                ? Colors.white
                : (isCurrent ? Colors.white : AppColors.cardBorder),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.primaryBlue : AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool active) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 2.5,
        color: active ? AppColors.primaryBlue : AppColors.cardBorder,
      ),
    );
  }

  String _subtitleForStatus() {
    switch (status) {
      case IncidentStatus.reported:
        return 'Campus safety is validating this report.';
      case IncidentStatus.investigating:
        return 'Security personnel are currently assessing this incident.';
      case IncidentStatus.verified:
        return 'Campus safety has verified this incident and is closing it out.';
      case IncidentStatus.resolved:
        return 'This incident has been resolved.';
    }
  }

  int _currentStepIndex() {
    switch (status) {
      case IncidentStatus.reported:
        return 0;
      case IncidentStatus.investigating:
        return 1;
      case IncidentStatus.verified:
        return 2;
      case IncidentStatus.resolved:
        return 3;
    }
  }

  int _progressPercent() {
    switch (status) {
      case IncidentStatus.reported:
        return 25;
      case IncidentStatus.investigating:
        return 50;
      case IncidentStatus.verified:
        return 75;
      case IncidentStatus.resolved:
        return 100;
    }
  }
}