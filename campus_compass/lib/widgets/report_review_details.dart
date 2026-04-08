import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:campus_compass/theme/app_colors.dart';

class ReportReviewDetails extends StatelessWidget {
  final String? title;
  final String? typeLabel;
  final String? location;
  final String? description;
  final String? incidentTimeLabel;
  final List<Map<String, dynamic>>? evidence;

  const ReportReviewDetails({
    super.key,
    this.title,
    this.typeLabel,
    this.location,
    this.description,
    this.incidentTimeLabel,
    this.evidence,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8),
          ],

          _buildReviewCard(
            icon: Icons.warning_amber_rounded,
            label: 'INCIDENT TYPE',
            value: typeLabel ?? 'Not specified',
          ),
          SizedBox(height: 12),

          _buildReviewCard(
            icon: Icons.location_on_outlined,
            label: 'LOCATION',
            value: location ?? 'Not specified',
          ),
          SizedBox(height: 12),

          _buildReviewCard(
            icon: Icons.description_outlined,
            label: 'DESCRIPTION',
            value: description ?? '',
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildSmallReviewCard(
                  icon: Icons.photo_outlined,
                  label: 'ATTACHMENTS',
                  value: '${(evidence ?? const []).length} Evidence',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSmallReviewCard(
                  icon: Icons.access_time_outlined,
                  label: 'INCIDENT TIME',
                  value: incidentTimeLabel ?? 'Not set',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          if ((evidence ?? []).isNotEmpty) ...[
            Text(
              'Evidence Preview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: evidence!.length,
                itemBuilder: (context, index) {
                  final e = evidence![index];
                  final url = e['downloadUrl'] as String?;
                  final isVideo = (e['type'] as String?) == 'video';
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                      color: AppColors.white,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: url != null
                              ? (isVideo
                                  ? Center(
                                      child: Icon(
                                        Icons.videocam,
                                        color: AppColors.primaryBlue,
                                        size: 40,
                                      ),
                                    )
                                  : Image.network(url, fit: BoxFit.cover))
                              : Center(
                                  child: Icon(
                                    Icons.photo,
                                    color: AppColors.primaryBlue,
                                    size: 40,
                                  ),
                                ),
                        ),
                        if (isVideo)
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallReviewCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 16),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
