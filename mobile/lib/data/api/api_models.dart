import 'package:dio/dio.dart';

class IncidentApiModel {
  const IncidentApiModel({
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

  factory IncidentApiModel.fromJson(Map<String, dynamic> json) =>
      IncidentApiModel(
        id: json['id'] as int,
        title: json['title'] as String,
        incidentType: json['incident_type'] as String,
        severity: json['severity'] as String,
        status: json['status'] as String,
        description: json['description'] as String? ?? '',
        instructions: json['instructions'] as String? ?? '',
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'] as String)
            : null,
      );
}

class SafeRouteApiModel {
  const SafeRouteApiModel({
    required this.destinationNodeId,
    required this.destinationName,
    required this.totalCost,
    required this.pathNodeIds,
  });

  final int destinationNodeId;
  final String destinationName;
  final double totalCost;
  final List<int> pathNodeIds;

  factory SafeRouteApiModel.fromJson(Map<String, dynamic> json) =>
      SafeRouteApiModel(
        destinationNodeId: json['destination_node_id'] as int,
        destinationName: json['destination_name'] as String,
        totalCost: (json['total_cost'] as num).toDouble(),
        pathNodeIds: (json['path_node_ids'] as List).cast<int>(),
      );
}
