import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/incident_providers.dart';
import '../../domain/entities/emergency_incident.dart';

class IncidentAlertScreen extends ConsumerWidget {
  const IncidentAlertScreen({super.key, required this.incidentId});

  final int incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(activeIncidentsProvider);

    return incidentsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (incidents) {
        final incident = incidents.cast<EmergencyIncident?>().firstWhere(
              (i) => i?.id == incidentId,
              orElse: () => null,
            );

        if (incident == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert')),
            body: const Center(child: Text('Incident not found.')),
          );
        }

        return _AlertBody(incident: incident);
      },
    );
  }
}

class _AlertBody extends StatelessWidget {
  const _AlertBody({required this.incident});
  final EmergencyIncident incident;

  Color get _severityColor => switch (incident.severity) {
        'critical' => Colors.red.shade900,
        'high' => Colors.red,
        'medium' => Colors.orange,
        _ => Colors.yellow.shade800,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _severityColor,
      appBar: AppBar(
        backgroundColor: _severityColor,
        foregroundColor: Colors.white,
        title: const Text('EMERGENCY ALERT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                incident.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _Chip(label: incident.incidentType.toUpperCase()),
              const SizedBox(height: 16),
              Text(
                incident.description,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const Divider(color: Colors.white30, height: 32),
              const Text('INSTRUCTIONS',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text(
                incident.instructions,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: _severityColor,
                  ),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Safe Route'),
                  onPressed: () => context.push('/route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
