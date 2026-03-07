import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/emergency_incident.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident});
  final EmergencyIncident incident;

  Color get _severityColor => switch (incident.severity) {
        'critical' => Colors.red.shade700,
        'high' => Colors.red,
        'medium' => Colors.orange,
        _ => Colors.amber,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _severityColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _severityColor,
          child: const Icon(Icons.warning_amber, color: Colors.white),
        ),
        title: Text(incident.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          incident.instructions.isNotEmpty
              ? incident.instructions
              : incident.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Chip(
          label: Text(incident.severity.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: _severityColor,
        ),
        onTap: () => context.push('/incident/${incident.id}'),
      ),
    );
  }
}
