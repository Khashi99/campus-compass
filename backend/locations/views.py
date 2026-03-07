from rest_framework import generics, permissions

from .models import Building, HazardZone, RouteEdge, RouteNode, SafetyResource, SafeZone
from .serializers import (
    BuildingSerializer,
    HazardZoneSerializer,
    RouteEdgeSerializer,
    RouteNodeSerializer,
    SafetyResourceSerializer,
    SafeZoneSerializer,
)


class BuildingListView(generics.ListAPIView):
    queryset = Building.objects.all()
    serializer_class = BuildingSerializer
    permission_classes = [permissions.IsAuthenticated]


class SafeZoneListView(generics.ListAPIView):
    queryset = SafeZone.objects.filter(is_active=True)
    serializer_class = SafeZoneSerializer
    permission_classes = [permissions.IsAuthenticated]


class ActiveHazardZoneListView(generics.ListAPIView):
    queryset = HazardZone.objects.filter(is_active=True).select_related("incident")
    serializer_class = HazardZoneSerializer
    permission_classes = [permissions.IsAuthenticated]


class RouteNodeListView(generics.ListAPIView):
    queryset = RouteNode.objects.all()
    serializer_class = RouteNodeSerializer
    permission_classes = [permissions.IsAuthenticated]


class RouteEdgeListView(generics.ListAPIView):
    queryset = RouteEdge.objects.filter(is_blocked=False)
    serializer_class = RouteEdgeSerializer
    permission_classes = [permissions.IsAuthenticated]


class SafetyResourceListView(generics.ListAPIView):
    queryset = SafetyResource.objects.all()
    serializer_class = SafetyResourceSerializer
    permission_classes = [permissions.IsAuthenticated]
    filterset_fields = ["resource_type"]
