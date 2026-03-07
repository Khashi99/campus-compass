from rest_framework import serializers

from .models import EmergencyIncident


class EmergencyIncidentSerializer(serializers.ModelSerializer):
    created_by_username = serializers.CharField(source="created_by.username", read_only=True)

    class Meta:
        model = EmergencyIncident
        fields = [
            "id",
            "title",
            "incident_type",
            "severity",
            "status",
            "description",
            "instructions",
            "affected_buildings",
            "created_by",
            "created_by_username",
            "start_time",
            "end_time",
            "updated_at",
        ]
        read_only_fields = ["id", "start_time", "updated_at", "created_by"]


class IncidentStatusSerializer(serializers.ModelSerializer):
    """Lightweight serializer for the campus status banner."""

    class Meta:
        model = EmergencyIncident
        fields = ["id", "title", "incident_type", "severity", "status", "instructions", "start_time"]
