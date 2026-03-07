from rest_framework import permissions, serializers, status
from rest_framework.response import Response
from rest_framework.views import APIView

from locations.models import RouteNode

from .service import find_nearest_safe_node


class SafeRouteRequestSerializer(serializers.Serializer):
    start_node_id = serializers.IntegerField()
    accessible_only = serializers.BooleanField(default=False)


class SafeRouteView(APIView):
    """
    POST /api/v1/routing/safe-route/
    Body: { "start_node_id": 42, "accessible_only": false }
    Returns the safest path from the given node to the nearest safe point.
    """

    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        req_serializer = SafeRouteRequestSerializer(data=request.data)
        req_serializer.is_valid(raise_exception=True)

        start_id = req_serializer.validated_data["start_node_id"]
        accessible_only = req_serializer.validated_data["accessible_only"]

        if not RouteNode.objects.filter(pk=start_id).exists():
            return Response({"detail": "Start node not found."}, status=status.HTTP_404_NOT_FOUND)

        route = find_nearest_safe_node(start_id, accessible_only=accessible_only)
        if route is None:
            return Response(
                {"detail": "No safe route found from the given location."},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(route)
