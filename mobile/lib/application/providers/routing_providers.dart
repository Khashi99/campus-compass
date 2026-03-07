import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/routing_repository.dart';
import '../../domain/entities/safe_route.dart';

class RouteRequest {
  const RouteRequest({required this.startNodeId, this.accessibleOnly = false});
  final int startNodeId;
  final bool accessibleOnly;
}

final safeRouteProvider =
    FutureProvider.autoDispose.family<SafeRoute?, RouteRequest>((ref, req) async {
  if (req.startNodeId <= 0) return null;
  return ref.watch(routingRepositoryProvider).fetchSafeRoute(
        startNodeId: req.startNodeId,
        accessibleOnly: req.accessibleOnly,
      );
});
