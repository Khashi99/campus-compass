import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/routing_providers.dart';
import '../../domain/entities/safe_route.dart';

class SafeRouteScreen extends ConsumerStatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  ConsumerState<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends ConsumerState<SafeRouteScreen> {
  // In a real build this comes from the nearest matched route node to GPS coords
  static const int _mockStartNodeId = 1;
  bool _accessibleOnly = false;

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(safeRouteProvider(
      RouteRequest(startNodeId: _mockStartNodeId, accessibleOnly: _accessibleOnly),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Route'),
        actions: [
          Row(
            children: [
              const Text('Accessible'),
              Switch(
                value: _accessibleOnly,
                onChanged: (v) => setState(() => _accessibleOnly = v),
              ),
            ],
          ),
        ],
      ),
      body: routeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Route unavailable: $e')),
        data: (route) => route == null
            ? const Center(child: Text('No safe route found.'))
            : _RouteDetails(route: route),
      ),
    );
  }
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails({required this.route});
  final SafeRoute route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, size: 56, color: Colors.green),
          const SizedBox(height: 12),
          Text('Go to: ${route.destinationName}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Estimated distance: ${route.totalCost.toStringAsFixed(0)} m',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text('Path', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: route.pathNodeIds.length,
              separatorBuilder: (_, __) =>
                  const Divider(indent: 16, endIndent: 16),
              itemBuilder: (_, i) => ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text('Node ${route.pathNodeIds[i]}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
