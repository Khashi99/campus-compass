import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_models.dart';
import '../api/dio_client.dart';
import '../../domain/entities/safe_route.dart';

final routingRepositoryProvider = Provider((ref) => RoutingRepository(createDio()));

class RoutingRepository {
  RoutingRepository(this._dio);

  final Dio _dio;

  Future<SafeRoute> fetchSafeRoute({
    required int startNodeId,
    bool accessibleOnly = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/routing/safe-route/',
      data: {
        'start_node_id': startNodeId,
        'accessible_only': accessibleOnly,
      },
    );
    final model = SafeRouteApiModel.fromJson(response.data!);
    return SafeRoute(
      destinationNodeId: model.destinationNodeId,
      destinationName: model.destinationName,
      totalCost: model.totalCost,
      pathNodeIds: model.pathNodeIds,
    );
  }
}
