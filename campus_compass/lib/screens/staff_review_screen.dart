import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:campus_compass/support/report_review_actions.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:campus_compass/utils/incident_haptics.dart';
import 'package:campus_compass/utils/incident_sounds.dart';

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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Pending Reports',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                _buildPendingReportsSection(context),
                SizedBox(height: 24),
                Text(
                  'Active Incidents',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                _buildIncidentStatusSection(context),
                SizedBox(height: 24),
                Text(
                  'Incident History',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                _buildIncidentHistorySection(context),
              ],
            ),
    );
  }

  Widget _buildPendingReportsSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('incidentReports')
          .orderBy('reportedTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load reports: ${snapshot.error}',
            style: TextStyle(color: AppColors.mutedText),
          );
        }

        final allDocs = snapshot.data?.docs ?? const [];
        final docs = allDocs
            .where((doc) => (doc.data()['status'] as String?) == 'reported')
            .where((doc) => doc.data()['linkedIncidentId'] == null)
            .toList();

        if (docs.isEmpty) {
          return _buildEmptyState('No pending reports to review.');
        }

        return Column(
          children: docs
              .map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReportCard(context, doc),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildIncidentStatusSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load incidents: ${snapshot.error}',
            style: TextStyle(color: AppColors.mutedText),
          );
        }

        final allDocs = snapshot.data?.docs ?? const [];
        final docs = allDocs.where((doc) {
          final status = (doc.data()['status'] as String?) ?? 'reported';
          return status == 'reported' ||
              status == 'investigating' ||
              status == 'verified';
        }).toList();

        if (docs.isEmpty) {
          return _buildEmptyState('No open incidents to update.');
        }

        return Column(
          children: docs
              .map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildIncidentCard(context, doc),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildIncidentHistorySection(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('incidents')
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text(
            'Failed to load incident history: ${snapshot.error}',
            style: TextStyle(color: AppColors.mutedText),
          );
        }

        final allDocs = snapshot.data?.docs ?? const [];
        final docs = allDocs.where((doc) {
          final status = (doc.data()['status'] as String?) ?? 'reported';
          return status == 'resolved';
        }).toList();

        if (docs.isEmpty) {
          return _buildEmptyState('No resolved incidents to remove.');
        }

        return Column(
          children: docs
              .map(
                (doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildResolvedIncidentCard(context, doc),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
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
              _buildStatusChip('Submitted'),
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
              SizedBox(width: 8),
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
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _resolveReport(context, doc),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusNormal,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Resolved'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = (data['title'] as String?) ?? 'Campus incident';
    final location = (data['location'] as String?) ?? 'Unknown location';
    final type = (data['type'] as String?) ?? 'maintenance';
    final status = (data['status'] as String?) ?? 'reported';
    final description =
        (data['description'] as String?) ?? 'No description provided.';

    final String actionLabel = switch (status) {
      'reported' => 'Move to Investigating',
      'investigating' => 'Mark as Verified',
      'verified' => 'Mark as Resolved',
      _ => 'Update Status',
    };

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
              _buildStatusChip(_prettyStatus(status)),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _advanceIncidentStatus(context, doc),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedIncidentCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = (data['title'] as String?) ?? 'Campus incident';
    final location = (data['location'] as String?) ?? 'Unknown location';
    final type = (data['type'] as String?) ?? 'maintenance';
    final description =
        (data['description'] as String?) ?? 'No description provided.';

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
              _buildStatusChip('Resolved'),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.darkText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _removeIncident(context, doc),
              icon: Icon(Icons.delete_outline),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.statusHighRisk,
                side: BorderSide(color: AppColors.statusHighRisk),
              ),
              label: Text('Remove from History'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusCaution.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.statusCaution,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(message, style: TextStyle(color: AppColors.mutedText)),
    );
  }

  Future<void> _approveReport(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    try {
      await ReportReviewActions.approveReport(reportDoc);
      await IncidentHaptics.playForEvent(IncidentHapticEvent.reportApproved);
      await IncidentSounds.playForEvent(IncidentSoundEvent.reportApproved);

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Approval failed: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Report dismissed.')));
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dismiss failed: $e')));
    }
  }

  Future<void> _resolveReport(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    try {
      await ReportReviewActions.resolveReport(reportDoc);

      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report marked as resolved.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Resolve failed: $e')));
    }
  }

  Future<void> _advanceIncidentStatus(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> incidentDoc,
  ) async {
    final currentStatus =
        (incidentDoc.data()['status'] as String?) ?? 'reported';

    try {
      if (currentStatus == 'reported') {
        await incidentDoc.reference.update({
          'status': 'investigating',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateLinkedReports(
          incidentId: incidentDoc.id,
          status: 'investigating',
        );
        await IncidentHaptics.playForEvent(
          IncidentHapticEvent.reportedToInvestigating,
        );
        await IncidentSounds.playForEvent(
          IncidentSoundEvent.reportedToInvestigating,
        );

        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident moved to investigating.')),
        );
        return;
      }

      if (currentStatus == 'investigating') {
        await incidentDoc.reference.update({
          'status': 'verified',
          'isActive': true,
          'resolvedAt': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateLinkedReports(
          incidentId: incidentDoc.id,
          status: 'verified',
        );
        await IncidentHaptics.playForEvent(
          IncidentHapticEvent.escalatedToVerifiedOrResolved,
        );
        await IncidentSounds.playForEvent(
          IncidentSoundEvent.escalatedToVerifiedOrResolved,
        );

        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident marked as verified.')),
        );
        return;
      }

      if (currentStatus == 'verified') {
        await incidentDoc.reference.update({
          'status': 'resolved',
          'isActive': false,
          'resolvedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateLinkedReports(
          incidentId: incidentDoc.id,
          status: 'resolved',
        );
        await IncidentHaptics.playForEvent(
          IncidentHapticEvent.escalatedToVerifiedOrResolved,
        );
        await IncidentSounds.playForEvent(
          IncidentSoundEvent.escalatedToVerifiedOrResolved,
        );

        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident marked as resolved.')),
        );
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status update failed: $e')));
    }
  }

  Future<void> _updateLinkedReports({
    required String incidentId,
    required String status,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final linkedReports = await firestore
        .collection('incidentReports')
        .where('linkedIncidentId', isEqualTo: incidentId)
        .get();

    if (linkedReports.docs.isEmpty) {
      return;
    }

    final batch = firestore.batch();
    for (final report in linkedReports.docs) {
      batch.update(report.reference, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _removeIncident(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> incidentDoc,
  ) async {
    final data = incidentDoc.data();
    final title = (data['title'] as String?) ?? 'this incident';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Remove incident?'),
          content: Text(
            'This will permanently remove "$title" from incident history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await incidentDoc.reference.delete();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident removed from history.')),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove incident: $e')));
    }
  }

  static String _prettyType(String rawType) {
    final words = rawType.split('_');
    return words
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  static String _prettyStatus(String status) {
    if (status == 'investigating') {
      return 'Investigating';
    }
    if (status == 'verified') {
      return 'Verified';
    }
    if (status == 'resolved') {
      return 'Resolved';
    }
    return 'Reported';
  }
}
