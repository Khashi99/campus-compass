from rest_framework import generics, permissions

from audit.mixins import AuditMixin
from notifications.tasks import dispatch_incident_alert

from .models import EmergencyIncident
from .serializers import EmergencyIncidentSerializer, IncidentStatusSerializer


class IsStaffOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role in ("staff", "admin")


class ActiveIncidentListView(generics.ListAPIView):
    """
    GET /api/v1/incidents/active/
    Returns all currently active incidents — used for the campus status banner.
    """

    serializer_class = IncidentStatusSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return EmergencyIncident.objects.filter(status=EmergencyIncident.Status.ACTIVE)


class IncidentListCreateView(AuditMixin, generics.ListCreateAPIView):
    serializer_class = EmergencyIncidentSerializer
    filterset_fields = ["status", "severity", "incident_type"]
    search_fields = ["title", "description"]

    def get_permissions(self):
        if self.request.method == "POST":
            return [IsStaffOrAdmin()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        return EmergencyIncident.objects.select_related("created_by").prefetch_related("affected_buildings")

    def perform_create(self, serializer):
        incident = serializer.save(created_by=self.request.user)
        # Fire push notification asynchronously via Celery
        dispatch_incident_alert.delay(incident.id)
        self.record_action("create_incident", {"incident_id": incident.id})


class IncidentDetailView(AuditMixin, generics.RetrieveUpdateDestroyAPIView):
    queryset = EmergencyIncident.objects.all()
    serializer_class = EmergencyIncidentSerializer

    def get_permissions(self):
        if self.request.method in ("PUT", "PATCH", "DELETE"):
            return [IsStaffOrAdmin()]
        return [permissions.IsAuthenticated()]

    def perform_update(self, serializer):
        incident = serializer.save()
        # Re-notify on status or severity change
        if "status" in serializer.validated_data or "severity" in serializer.validated_data:
            dispatch_incident_alert.delay(incident.id)
        self.record_action("update_incident", {"incident_id": incident.id})
