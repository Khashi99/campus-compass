import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:campus_compass/utils/incident_haptics.dart';
import 'package:campus_compass/utils/notification_service.dart';

/// Monitors incident documents and notifies when `status` changes.
class IncidentStatusMonitor {
  IncidentStatusMonitor._();
  static final IncidentStatusMonitor instance = IncidentStatusMonitor._();

  final _firestore = FirebaseFirestore.instance;
  final Map<String, String> _knownStatuses = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  Future<void> start() async {
    // Prime current statuses once to avoid spamming notifications on startup.
    final snapshot = await _firestore.collection('incidents').get();
    for (final doc in snapshot.docs) {
      final status = (doc.data()['status'] as String?) ?? '';
      _knownStatuses[doc.id] = status;
    }

    // Listen for subsequent changes.
    _sub = _firestore.collection('incidents').snapshots().listen((qs) {
      for (final change in qs.docChanges) {
        final id = change.doc.id;
        final Map<String, dynamic> data = change.doc.data() ?? <String, dynamic>{};
        final newStatus = (data['status'] as String?) ?? '';

        final oldStatus = _knownStatuses[id];
        if (oldStatus == null) {
          _knownStatuses[id] = newStatus;
          continue;
        }

        if (oldStatus != newStatus) {
          _knownStatuses[id] = newStatus;
          _handleStatusChange(change.doc.id, oldStatus, newStatus, data);
        }
      }
    });
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  Future<void> _handleStatusChange(String id, String from, String to, Map<String, dynamic> data) async {
    final title = (data['title'] as String?) ?? 'Incident update';
    final body = 'Status changed: ${_readableStatus(from)} → ${_readableStatus(to)}';

    try {
      await NotificationService.instance.showNotification(title: title, body: body);
    } catch (_) {}

    try {
      await IncidentHaptics.playForEvent(IncidentHapticEvent.campusStatusChanged);
    } catch (_) {}
  }

  String _readableStatus(String s) {
    switch (s) {
      case 'reported':
        return 'Reported';
      case 'investigating':
        return 'Investigating';
      case 'verified':
        return 'Verified';
      case 'resolved':
        return 'Resolved';
      default:
        return s;
    }
  }
}
