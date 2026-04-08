import 'package:campus_compass/models/incident.dart';
import 'package:campus_compass/utils/campus_time.dart';
import 'package:campus_compass/models/alert_feed_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? asDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

String formatClock(DateTime timestamp) {
  final hour = timestamp.hour == 0
      ? 12
      : timestamp.hour > 12
          ? timestamp.hour - 12
          : timestamp.hour;
  final minute = timestamp.minute.toString().padLeft(2, '0');
  final suffix = timestamp.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

String monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String monthNameShort(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

String prettyStatus(String status) {
  if (status == 'investigating') return 'Investigating';
  if (status == 'verified') return 'Verified';
  if (status == 'resolved') return 'Resolved';
  return 'Reported';
}

AlertFeedKind kindForIncident(Incident incident) {
  if (incident.status == IncidentStatus.resolved) return AlertFeedKind.success;
  if (incident.type == IncidentType.maintenance && incident.severity <= 1) {
    return AlertFeedKind.neutral;
  }
  return AlertFeedKind.warning;
}

String incidentActionLabel(Incident incident) {
  if (incident.status == IncidentStatus.resolved) {
    switch (incident.type) {
      case IncidentType.maintenance:
      case IncidentType.construction:
        return 'Maintenance completed';
      case IncidentType.blockage:
        return 'Route reopened';
      case IncidentType.gathering:
      case IncidentType.protest:
        return 'Crowd dispersed';
      case IncidentType.emergency:
        return 'Hazard cleared';
    }
  }

  if (incident.status == IncidentStatus.verified) return 'Incident verified by staff';

  switch (incident.type) {
    case IncidentType.protest:
    case IncidentType.gathering:
      return 'Suspicious activity';
    case IncidentType.blockage:
      return 'Access issue reported';
    case IncidentType.maintenance:
      return 'Routine patrol scheduled';
    case IncidentType.construction:
      return 'Incident reported';
    case IncidentType.emergency:
      return 'Incident reported';
  }
}

String groupLabel(DateTime timestamp) {
  final easternTimestamp = CampusTime.toEastern(timestamp);
  final nowEastern = CampusTime.toEastern(DateTime.now());
  final today = DateTime(nowEastern.year, nowEastern.month, nowEastern.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final itemDate = DateTime(
    easternTimestamp.year,
    easternTimestamp.month,
    easternTimestamp.day,
  );

  if (itemDate == today) return 'TODAY';
  if (itemDate == yesterday) return 'YESTERDAY';
  return '${easternTimestamp.day} ${monthName(easternTimestamp.month).toUpperCase()} ${easternTimestamp.year}';
}

String detailLineForTimestamp(DateTime timestamp) {
  final easternTimestamp = CampusTime.toEastern(timestamp);
  final nowEastern = CampusTime.toEastern(DateTime.now());
  final today = DateTime(nowEastern.year, nowEastern.month, nowEastern.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final itemDate = DateTime(
    easternTimestamp.year,
    easternTimestamp.month,
    easternTimestamp.day,
  );

  final formattedTime = formatClock(easternTimestamp);
  if (itemDate == today) return formattedTime;
  if (itemDate == yesterday) return 'Yesterday, $formattedTime';
  return '${monthNameShort(easternTimestamp.month)} ${easternTimestamp.day}, $formattedTime';
}
