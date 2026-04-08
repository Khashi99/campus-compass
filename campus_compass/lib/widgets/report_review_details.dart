import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  value: (() {
                    final list = evidence ?? const <Map<String, dynamic>>[];
                    final imageCount = list.where((e) => (e['type'] as String?) != 'video').length;
                    final videoCount = list.where((e) => (e['type'] as String?) == 'video').length;
                    return '${imageCount} image evidence, ${videoCount} video evidence';
                  })(),
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
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: evidence!.length,
              separatorBuilder: (context, i) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = evidence![index];
                final url = e['downloadUrl'] as String?;
                final isVideo = (e['type'] as String?) == 'video';

                // Determine per-type index (Image 1, Image 2, Video 1, ...)
                final prior = evidence!.sublist(0, index);
                final typeIndex = prior.where((x) => ((x['type'] as String?) == 'video') == isVideo).length + 1;
                final label = isVideo ? 'Video $typeIndex' : 'Image $typeIndex';

                return InkWell(
                  onTap: url != null
                      ? () async {
                          try {
                            await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
                          } catch (_) {}
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 50,
                          decoration: BoxDecoration(
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
                                              size: 24,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) => Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: AppColors.primaryBlue,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ))
                                    : Center(
                                        child: Icon(
                                          Icons.photo,
                                          color: AppColors.primaryBlue,
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${isVideo ? 'Video' : 'Image'} Evidence ${typeIndex}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.darkText,
                                ),
                              ),
                              IconButton(
                                onPressed: url != null
                                    ? () async {
                                        try {
                                          await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
                                        } catch (_) {}
                                      }
                                    : null,
                                icon: Icon(Icons.open_in_new),
                                tooltip: 'Open',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
