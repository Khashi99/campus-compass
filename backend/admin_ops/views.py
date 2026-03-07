"""
admin_ops: staff-facing dashboard helpers.
Provides aggregated campus status and incident summary endpoints
for use in the admin portal.
"""

from rest_framework import permissions, serializers
from rest_framework.response import Response
from rest_framework.views import APIView

from incidents.models import EmergencyIncident
from reports.models import StudentReport


class IsStaffOrAdmin(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in ("staff", "admin")


class CampusStatusView(APIView):
    """
    GET /api/v1/admin-ops/campus-status/
    Returns a single summary object used by the staff dashboard.
    """

    permission_classes = [IsStaffOrAdmin]

    def get(self, request):
        active = EmergencyIncident.objects.filter(status=EmergencyIncident.Status.ACTIVE)
        highest_severity = None
        severity_order = ["critical", "high", "medium", "low"]
        for sev in severity_order:
            if active.filter(severity=sev).exists():
                highest_severity = sev
                break

        return Response(
            {
                "campus_status": "emergency" if active.exists() else "normal",
                "active_incident_count": active.count(),
                "highest_severity": highest_severity,
                "pending_reports": StudentReport.objects.filter(
                    incident__status=EmergencyIncident.Status.ACTIVE
                ).count(),
            }
        )
