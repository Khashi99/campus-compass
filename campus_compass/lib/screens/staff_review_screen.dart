import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:campus_compass/support/report_review_actions.dart';
import 'package:campus_compass/theme/app_colors.dart';

class StaffReviewScreen extends StatelessWidget {
  const StaffReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Staff Review',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.darkText),
        ),
      ),
      body: user == null
          ? Center(
              child: Text(
                'Sign in required.',
                style: TextStyle(color: AppColors.mutedText),
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('incidentReports')
                  .orderBy('reportedTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Failed to load reports: ${snapshot.error}',
                        style: TextStyle(color: AppColors.mutedText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final allDocs = snapshot.data?.docs ?? const [];
                final docs = allDocs
                    .where((doc) => (doc.data()['status'] as String?) == 'submitted')
                    .toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No pending reports to review.',
                      style: TextStyle(color: AppColors.mutedText),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();

                    final title = (data['title'] as String?) ?? 'Incident report';
                    final location = (data['location'] as String?) ?? 'Unknown location';
                    final description =
                        (data['description'] as String?) ?? 'No description provided.';
                    final type = (data['type'] as String?) ?? 'maintenance';

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.statusCaution.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Submitted',
                                  style: TextStyle(
                                    color: AppColors.statusCaution,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$location • ${_prettyType(type)}',
                            style: TextStyle(
                              color: AppColors.mutedText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _dismissReport(context, doc),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.mutedText,
                                    side: BorderSide(color: AppColors.cardBorder),
                                  ),
                                  child: Text('Dismiss'),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _approveReport(context, doc),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _approveReport(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    try {
      await ReportReviewActions.approveReport(reportDoc);

      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report approved and published.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approval failed: $e')),
      );
    }
  }

  Future<void> _dismissReport(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    try {
      await ReportReviewActions.dismissReport(reportDoc);

      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report dismissed.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dismiss failed: $e')),
      );
    }
  }

  static String _prettyType(String rawType) {
    final words = rawType.split('_');
    return words
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }
}
