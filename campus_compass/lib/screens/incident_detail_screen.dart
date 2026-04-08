import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_compass/screens/alerts_screen.dart';
import 'package:campus_compass/screens/profile_screen.dart';
import 'package:campus_compass/screens/report_incident_screen.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/utils/map_highlight_position.dart';
import 'package:campus_compass/widgets/bottom_nav_bar.dart';
import 'package:campus_compass/screens/home_screen.dart';
import 'package:campus_compass/widgets/map_placeholder.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Incident incident;
  final VoidCallback? onRequestUpdate;
  final VoidCallback? onViewLiveMap;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
    this.onRequestUpdate,
    this.onViewLiveMap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
          leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.darkText,
            size: 18,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              context.pop();
            } else {
              context.go('/home/map');
            }
          },
        ),
        title: Text(
          'Incident Data',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.verified_user_outlined, color: AppColors.darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badges
            _buildStatusBadges(),

            // Incident title and time
            _buildTitleSection(),

            // Map preview
            _buildMapPreview(context),

            // Resolution progress
            _buildResolutionProgress(),

            // Description
            _buildDescription(),

            // Community insights
            _buildCommunityInsights(),

            // Request update button
            _buildRequestUpdateButton(context),

            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: (context.findAncestorWidgetOfExactType<HomeScreen>()
              ==
          null)
          ? BottomNavBar(
              currentIndex: 0,
              onTap: (index) => _handleBottomNavTap(context, index),
            )
          : null,
    );
  }

  Widget _buildStatusBadges() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getStatusColor().withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusIcon(), size: 14, color: _getStatusColor()),
                SizedBox(width: 4),
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          // Verified badge
          if (incident.verificationLevel == VerificationLevel.verified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.verifiedBadge.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 14,
                    color: AppColors.verifiedBadge,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Verified by Campus Safety',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.verifiedBadge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            incident.title,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.08,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.mutedText),
              SizedBox(width: 6),
              Text(
                'Reported ${incident.timeAgo}',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 18),
              Icon(Icons.people_outline, size: 16, color: AppColors.mutedText),
              SizedBox(width: 6),
              Text(
                '${incident.userReports} User Reports',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (incident.imageUrl != null)
            Positioned.fill(
              child: Image.network(
                incident.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return MapPlaceholder(
                    showTensionZone: true,
                    tensionZonePosition:
                        MapHighlightPosition.forIncidentLocation(
                          incident.location,
                        ),
                  );
                },
              ),
            )
          else
            Positioned.fill(
              child: MapPlaceholder(
                showTensionZone: true,
                tensionZonePosition: MapHighlightPosition.forIncidentLocation(
                  incident.location,
                ),
              ),
            ),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    incident.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // View live map button
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Center(
              child: MiniMapButton(
                onTap: () => _openLiveMap(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionProgress() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resolution Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildProgressStep('REPORTED', true, isFirst: true),
              _buildProgressConnector(
                incident.status == IncidentStatus.investigating ||
                    incident.status == IncidentStatus.verified ||
                    incident.status == IncidentStatus.resolved,
              ),
              _buildProgressStep(
                'INVESTIGATING',
                incident.status == IncidentStatus.investigating ||
                    incident.status == IncidentStatus.verified ||
                    incident.status == IncidentStatus.resolved,
              ),
              _buildProgressConnector(
                incident.status == IncidentStatus.verified ||
                    incident.status == IncidentStatus.resolved,
              ),
              _buildProgressStep(
                'VERIFIED',
                incident.status == IncidentStatus.verified ||
                    incident.status == IncidentStatus.resolved,
              ),
              _buildProgressConnector(
                incident.status == IncidentStatus.resolved,
              ),
              _buildProgressStep(
                'RESOLVED',
                incident.status == IncidentStatus.resolved,
                isLast: true,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _resolutionSubtitle(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(
    String label,
    bool isActive, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBlue : AppColors.lightCircle,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primaryBlue : AppColors.cardBorder,
                width: 2,
              ),
            ),
            child: isActive
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primaryBlue : AppColors.mutedText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Container(
      height: 3,
      width: 40,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.cardBorder,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 10),
          Text(
            incident.description,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mutedText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityInsights() {
    if (incident.communityInsights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Community Insights',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${incident.communityInsights.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Add Update',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...incident.communityInsights.map(
            (insight) => _buildInsightCard(insight),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(CommunityInsight insight) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder.withOpacity(0.9)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              _buildInsightAvatar(insight),
              SizedBox(width: 8),
              // Name and role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          insight.authorName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkText,
                          ),
                        ),
                        if (insight.authorRole != null) ...[
                          SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              insight.authorRole!,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                insight.timeAgo,
                style: TextStyle(fontSize: 12, color: AppColors.mutedText),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            insight.content,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Helpful',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'Flag',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightAvatar(CommunityInsight insight) {
    if (insight.avatarUrl != null && insight.avatarUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 19,
        backgroundImage: NetworkImage(insight.avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 19,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
      child: Text(
        insight.authorName[0].toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildRequestUpdateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            onRequestUpdate?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Update request submitted!'),
                backgroundColor: AppColors.statusNormal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          icon: Icon(Icons.warning_amber_rounded, size: 18),
          label: Text(
            'Request Alert Update',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkText,
            side: BorderSide(color: AppColors.cardBorder, width: 1.0),
            backgroundColor: AppColors.white,
            minimumSize: Size.fromHeight(50),
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        _openLiveMap(context);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportIncidentScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlertsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  void _openLiveMap(BuildContext context) {
    onViewLiveMap?.call();
    context.go('/home/map');
  }

  // Helper methods
  Color _getStatusColor() {
    switch (incident.status) {
      case IncidentStatus.reported:
        return AppColors.statusCaution;
      case IncidentStatus.investigating:
        return AppColors.primaryBlue;
      case IncidentStatus.verified:
        return const Color(0xFF0F766E);
      case IncidentStatus.resolved:
        return AppColors.statusNormal;
    }
  }

  IconData _getStatusIcon() {
    switch (incident.status) {
      case IncidentStatus.reported:
        return Icons.flag_outlined;
      case IncidentStatus.investigating:
        return Icons.search;
      case IncidentStatus.verified:
        return Icons.verified_outlined;
      case IncidentStatus.resolved:
        return Icons.check_circle_outline;
    }
  }

  String _getStatusText() {
    switch (incident.status) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.investigating:
        return 'Under Review';
      case IncidentStatus.verified:
        return 'Verified';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  String _resolutionSubtitle() {
    switch (incident.status) {
      case IncidentStatus.reported:
        return 'Campus safety has received this report and is validating details.';
      case IncidentStatus.investigating:
        return 'Security personnel are currently assessing the duration of this incident.';
      case IncidentStatus.verified:
        return 'Campus safety has verified this incident and is preparing final closure.';
      case IncidentStatus.resolved:
        return 'This incident has been resolved and normal access has resumed.';
    }
  }
}
