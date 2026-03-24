import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/utils/campus_time.dart';
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
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Incident Data',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.darkText),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
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
            
            // Photo gallery (if available)
            if (incident.imageUrl != null) _buildPhotoSection(),
            
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
    );
  }

  Widget _buildStatusBadges() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getStatusColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 14,
                  color: _getStatusColor(),
                ),
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
                borderRadius: BorderRadius.circular(16),
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
                    'Verified by Safety',
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            incident.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.mutedText,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Incident Time: ${_formatDateTime(incident.reportedTime)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.mutedText,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Reported ${incident.timeAgo}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.mutedText,
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${incident.userReports} User Reports',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mutedText,
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

  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.pageBackground,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              incident.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.pageBackground,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.mutedText,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.photo_library,
                  size: 16,
                  color: AppColors.mutedText,
                ),
                SizedBox(width: 6),
                Text(
                  'Incident Photo',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Map image
          const MapPlaceholder(
            showTensionZone: true,
            tensionZonePosition: Offset(60, 40),
          ),
          // View live map button
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: MiniMapButton(
                onTap: onViewLiveMap ?? () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionProgress() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
              _buildProgressStep(
                'REPORTED',
                true,
                isFirst: true,
              ),
              _buildProgressConnector(
                incident.status == IncidentStatus.investigating ||
                incident.status == IncidentStatus.resolved,
              ),
              _buildProgressStep(
                'INVESTIGATING',
                incident.status == IncidentStatus.investigating ||
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
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive, {bool isFirst = false, bool isLast = false}) {
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
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
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
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            incident.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedText,
              height: 1.6,
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

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Text(
                'Community Insights',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
              Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${incident.communityInsights.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...incident.communityInsights.map((insight) => _buildInsightCard(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(CommunityInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.quoteBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                child: Text(
                  insight.authorName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
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
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              insight.authorRole!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      insight.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            insight.content,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestUpdateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
          icon: Icon(Icons.refresh, size: 18),
          label: Text(
            'Request Alert Update',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            side: BorderSide(color: AppColors.primaryBlue),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods
  Color _getStatusColor() {
    switch (incident.status) {
      case IncidentStatus.reported:
        return AppColors.statusCaution;
      case IncidentStatus.investigating:
        return AppColors.primaryBlue;
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
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return CampusTime.formatDetailed(dateTime);
  }
}
