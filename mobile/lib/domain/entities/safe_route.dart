// Domain entity: SafeRoute returned by the routing API
class SafeRoute {
  const SafeRoute({
    required this.destinationNodeId,
    required this.destinationName,
    required this.totalCost,
    required this.pathNodeIds,
  });

  final int destinationNodeId;
  final String destinationName;
  final double totalCost;
  final List<int> pathNodeIds;
}
