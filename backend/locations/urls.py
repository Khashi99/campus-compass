from django.urls import path

from .views import (
    ActiveHazardZoneListView,
    BuildingListView,
    RouteEdgeListView,
    RouteNodeListView,
    SafetyResourceListView,
    SafeZoneListView,
)

urlpatterns = [
    path("buildings/", BuildingListView.as_view(), name="buildings-list"),
    path("safe-zones/", SafeZoneListView.as_view(), name="safe-zones-list"),
    path("hazard-zones/", ActiveHazardZoneListView.as_view(), name="hazard-zones-list"),
    path("route-nodes/", RouteNodeListView.as_view(), name="route-nodes-list"),
    path("route-edges/", RouteEdgeListView.as_view(), name="route-edges-list"),
    path("safety-resources/", SafetyResourceListView.as_view(), name="safety-resources-list"),
]
