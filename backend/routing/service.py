"""
Safe-route computation service.

Uses Dijkstra's algorithm on the RouteNode/RouteEdge graph.
Edges that are blocked or have high risk_weight are avoided.
"""

import heapq
from typing import Optional

from locations.models import RouteEdge, RouteNode


def _build_graph(accessible_only: bool) -> dict:
    """Load the current edge graph from the database."""
    edges = RouteEdge.objects.filter(is_blocked=False).select_related("from_node", "to_node")
    if accessible_only:
        edges = edges.filter(is_accessible=True)

    graph: dict[int, list[tuple[float, int]]] = {}
    for edge in edges:
        cost = edge.distance * edge.risk_weight
        graph.setdefault(edge.from_node_id, []).append((cost, edge.to_node_id))
        # Treat edges as bidirectional for pedestrian paths
        graph.setdefault(edge.to_node_id, []).append((cost, edge.from_node_id))
    return graph


def find_nearest_safe_node(start_node_id: int, accessible_only: bool = False) -> Optional[dict]:
    """
    Run Dijkstra from *start_node_id* and return the nearest RouteNode
    of type SAFE_POINT or ASSEMBLY together with the reconstructed path.

    Returns None if no safe node is reachable.
    """
    safe_types = {RouteNode.NodeType.SAFE_POINT, RouteNode.NodeType.ASSEMBLY}
    safe_node_ids = set(
        RouteNode.objects.filter(node_type__in=safe_types).values_list("id", flat=True)
    )

    graph = _build_graph(accessible_only)

    dist: dict[int, float] = {start_node_id: 0.0}
    prev: dict[int, Optional[int]] = {start_node_id: None}
    heap: list[tuple[float, int]] = [(0.0, start_node_id)]

    while heap:
        cost, node_id = heapq.heappop(heap)
        if cost > dist.get(node_id, float("inf")):
            continue

        if node_id in safe_node_ids:
            # Reconstruct path
            path = []
            current: Optional[int] = node_id
            while current is not None:
                path.append(current)
                current = prev.get(current)
            path.reverse()
            destination = RouteNode.objects.get(pk=node_id)
            return {
                "destination_node_id": node_id,
                "destination_name": destination.name or str(destination.node_type),
                "total_cost": cost,
                "path_node_ids": path,
            }

        for edge_cost, neighbor_id in graph.get(node_id, []):
            new_cost = cost + edge_cost
            if new_cost < dist.get(neighbor_id, float("inf")):
                dist[neighbor_id] = new_cost
                prev[neighbor_id] = node_id
                heapq.heappush(heap, (new_cost, neighbor_id))

    return None
