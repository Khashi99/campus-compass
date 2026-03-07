import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_models.dart';
import '../api/dio_client.dart';
import '../../domain/entities/emergency_incident.dart';

final incidentRepositoryProvider = Provider((ref) => IncidentRepository(createDio()));

class IncidentRepository {
  IncidentRepository(this._dio);

  final Dio _dio;

  Future<List<EmergencyIncident>> fetchActive() async {
    final response = await _dio.get<List>('/incidents/active/');
    return (response.data ?? [])
        .cast<Map<String, dynamic>>()
        .map((json) => _toEntity(IncidentApiModel.fromJson(json)))
        .toList();
  }

  Future<List<EmergencyIncident>> fetchAll() async {
    final response = await _dio.get<Map<String, dynamic>>('/incidents/');
    final results = (response.data?['results'] as List?) ?? [];
    return results
        .cast<Map<String, dynamic>>()
        .map((json) => _toEntity(IncidentApiModel.fromJson(json)))
        .toList();
  }

  EmergencyIncident _toEntity(IncidentApiModel m) => EmergencyIncident(
        id: m.id,
        title: m.title,
        incidentType: m.incidentType,
        severity: m.severity,
        status: m.status,
        description: m.description,
        instructions: m.instructions,
        startTime: m.startTime,
        endTime: m.endTime,
      );
}
