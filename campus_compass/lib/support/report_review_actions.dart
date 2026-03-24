import 'package:cloud_firestore/cloud_firestore.dart';

class ReportReviewActions {
  ReportReviewActions._();

  static Future<void> approveReport(
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    final data = reportDoc.data();
    final firestore = FirebaseFirestore.instance;
    final incidentsRef = firestore.collection('incidents').doc();
    final now = FieldValue.serverTimestamp();

    final campusId = (data['campusId'] as String?) ?? 'sgw';
    final title = (data['title'] as String?) ?? 'Reported incident';
    final description =
        (data['description'] as String?) ?? 'No description provided.';
    final location = (data['location'] as String?) ?? 'Unknown location';
    final coordinates = (data['coordinates'] as Map<String, dynamic>?) ??
        <String, dynamic>{'latitude': 45.4973, 'longitude': -73.5790};
    final buildingCode = (data['buildingCode'] as String?) ?? 'GEN';
    final type = (data['type'] as String?) ?? 'maintenance';
    final createdBy = (data['createdBy'] as String?) ?? '';
    final reportedTime = data['reportedTime'] ?? now;

    final batch = firestore.batch();

    batch.set(incidentsRef, {
      'campusId': campusId,
      'title': title,
      'description': description,
      'location': location,
      'coordinates': coordinates,
      'buildingCode': buildingCode,
      'type': type,
      'status': 'reported',
      'verificationLevel': 'verified',
      'severity': 1,
      'zoneRadiusMeters': 120,
      'isActive': true,
      'userReports': 1,
      'createdBy': createdBy,
      'reportedTime': reportedTime,
      'updatedAt': now,
      'resolvedAt': null,
    });

    batch.update(reportDoc.reference, {
      'status': 'investigating',
      'linkedIncidentId': incidentsRef.id,
      'updatedAt': now,
    });

    await batch.commit();
  }

  static Future<void> dismissReport(
    QueryDocumentSnapshot<Map<String, dynamic>> reportDoc,
  ) async {
    await reportDoc.reference.update({
      'status': 'dismissed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
