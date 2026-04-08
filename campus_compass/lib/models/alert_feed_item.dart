import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_compass/models/incident.dart';

enum AlertFeedKind {
  warning,
  success,
  neutral,
}

class AlertFeedItem {
  const AlertFeedItem({
    required this.id,
    required this.title,
    required this.location,
    required this.timestamp,
    required this.detailLine,
    required this.kind,
    this.incident,
    this.incidentDoc,
    this.reportDoc,
    this.description,
  });

  final String id;
  final String title;
  final String location;
  final DateTime timestamp;
  final String detailLine;
  final AlertFeedKind kind;
  final Incident? incident;
  final QueryDocumentSnapshot<Map<String, dynamic>>? incidentDoc;
  final QueryDocumentSnapshot<Map<String, dynamic>>? reportDoc;
  final String? description;
}
