from rest_framework import serializers

from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    incident_title = serializers.CharField(source="incident.title", read_only=True)

    class Meta:
        model = Notification
        fields = ["id", "incident", "incident_title", "message", "sent_at", "delivery_status"]
