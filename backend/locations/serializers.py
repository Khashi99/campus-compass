from rest_framework_gis.serializers import GeoFeatureModelSerializer

from .models import Building, HazardZone, RouteEdge, RouteNode, SafetyResource, SafeZone


class BuildingSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = Building
        geo_field = "geometry"
        fields = ["id", "name", "code", "address", "is_accessible"]


class SafeZoneSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = SafeZone
        geo_field = "geometry"
        fields = ["id", "name", "description", "capacity", "is_active"]


class HazardZoneSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = HazardZone
        geo_field = "geometry"
        fields = ["id", "incident", "risk_level", "is_active"]


class RouteNodeSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = RouteNode
        geo_field = "geometry"
        fields = ["id", "name", "node_type", "building", "is_accessible"]


class RouteEdgeSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = RouteEdge
        geo_field = None  # edges have no geometry column; expose as plain JSON
        fields = ["id", "from_node", "to_node", "distance", "risk_weight", "is_blocked", "is_accessible"]


class SafetyResourceSerializer(GeoFeatureModelSerializer):
    class Meta:
        model = SafetyResource
        geo_field = "location"
        fields = ["id", "resource_type", "name", "phone", "building"]
