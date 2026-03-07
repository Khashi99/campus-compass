// Domain entity: EmergencyIncident
class EmergencyIncident {
  const EmergencyIncident({
    required this.id,
    required this.title,
    required this.incidentType,
    required this.severity,
    required this.status,
    required this.description,
    required this.instructions,
    required this.startTime,
    this.endTime,
  });

  final int id;
  final String title;
  final String incidentType;
  final String severity;
  final String status;
  final String description;
  final String instructions;
  final DateTime startTime;
  final DateTime? endTime;

  bool get isActive => status == 'active';
  bool get isCritical => severity == 'critical' || severity == 'high';
}
