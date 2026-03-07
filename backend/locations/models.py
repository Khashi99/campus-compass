from django.contrib.gis.db import models as gis_models
from django.db import models


class Building(models.Model):
    name = models.CharField(max_length=200)
    code = models.CharField(max_length=20, unique=True, help_text="e.g. H, EV, MB")
    address = models.CharField(max_length=300, blank=True)
    geometry = gis_models.PolygonField(srid=4326, null=True, blank=True)
    entrance_points = gis_models.MultiPointField(srid=4326, null=True, blank=True)
    is_accessible = models.BooleanField(default=True)

    class Meta:
        db_table = "buildings"
        ordering = ["name"]

    def __str__(self):
        return f"{self.code} – {self.name}"


class SafeZone(models.Model):
    name = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    geometry = gis_models.PolygonField(srid=4326, null=True, blank=True)
    capacity = models.PositiveIntegerField(default=0)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "safe_zones"

    def __str__(self):
        return self.name


class HazardZone(models.Model):
    class RiskLevel(models.TextChoices):
        LOW = "low", "Low"
        MEDIUM = "medium", "Medium"
        HIGH = "high", "High"

    incident = models.ForeignKey(
        "incidents.EmergencyIncident", on_delete=models.CASCADE, related_name="hazard_zones"
    )
    geometry = gis_models.PolygonField(srid=4326)
    risk_level = models.CharField(max_length=20, choices=RiskLevel.choices, default=RiskLevel.MEDIUM)
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = "hazard_zones"

    def __str__(self):
        return f"HazardZone({self.incident_id}, {self.risk_level})"


class RouteNode(models.Model):
    class NodeType(models.TextChoices):
        ENTRANCE = "entrance", "Building Entrance"
        EXIT = "exit", "Emergency Exit"
        SAFE_POINT = "safe_point", "Safe Point"
        ASSEMBLY = "assembly", "Assembly Area"
        JUNCTION = "junction", "Path Junction"

    name = models.CharField(max_length=200, blank=True)
    geometry = gis_models.PointField(srid=4326)
    node_type = models.CharField(max_length=30, choices=NodeType.choices, default=NodeType.JUNCTION)
    building = models.ForeignKey(Building, null=True, blank=True, on_delete=models.SET_NULL)
    is_accessible = models.BooleanField(default=True)

    class Meta:
        db_table = "route_nodes"

    def __str__(self):
        return f"{self.node_type} – {self.name or self.id}"


class RouteEdge(models.Model):
    from_node = models.ForeignKey(RouteNode, on_delete=models.CASCADE, related_name="outgoing_edges")
    to_node = models.ForeignKey(RouteNode, on_delete=models.CASCADE, related_name="incoming_edges")
    distance = models.FloatField(help_text="Distance in metres.")
    # Higher risk_weight means this edge is avoided during emergencies
    risk_weight = models.FloatField(default=1.0)
    is_blocked = models.BooleanField(default=False)
    is_accessible = models.BooleanField(default=True)

    class Meta:
        db_table = "route_edges"
        unique_together = [("from_node", "to_node")]

    def __str__(self):
        return f"Edge {self.from_node_id} → {self.to_node_id} ({self.distance}m)"


class SafetyResource(models.Model):
    class ResourceType(models.TextChoices):
        FIRST_AID = "first_aid", "First Aid Kit"
        AED = "aed", "AED Defibrillator"
        FIRE_EXTINGUISHER = "fire_extinguisher", "Fire Extinguisher"
        EMERGENCY_PHONE = "emergency_phone", "Emergency Phone"
        SECURITY_OFFICE = "security_office", "Security Office"

    resource_type = models.CharField(max_length=40, choices=ResourceType.choices)
    name = models.CharField(max_length=200, blank=True)
    phone = models.CharField(max_length=30, blank=True)
    location = gis_models.PointField(srid=4326, null=True, blank=True)
    building = models.ForeignKey(Building, null=True, blank=True, on_delete=models.SET_NULL)

    class Meta:
        db_table = "safety_resources"

    def __str__(self):
        return f"{self.resource_type} – {self.name or self.building}"
