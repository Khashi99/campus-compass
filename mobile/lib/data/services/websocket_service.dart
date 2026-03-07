import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/emergency_incident.dart';

const String _wsUrl = String.fromEnvironment(
  'WS_BASE_URL',
  defaultValue: 'ws://10.0.2.2:8000/ws/incidents/',
);

final incidentWsProvider =
    StreamProvider.autoDispose<EmergencyIncident>((ref) {
  final channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
  ref.onDispose(channel.sink.close);

  return channel.stream.map((raw) {
    final data = jsonDecode(raw as String) as Map<String, dynamic>;
    return EmergencyIncident(
      id: data['incident_id'] as int,
      title: data['title'] as String,
      incidentType: '',
      severity: data['severity'] as String,
      status: data['status'] as String,
      description: '',
      instructions: data['instructions'] as String? ?? '',
      startTime: DateTime.now(),
    );
  });
});
