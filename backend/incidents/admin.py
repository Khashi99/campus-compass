from django.contrib import admin

from .models import EmergencyIncident


@admin.register(EmergencyIncident)
class EmergencyIncidentAdmin(admin.ModelAdmin):
    list_display = ["title", "incident_type", "severity", "status", "start_time"]
    list_filter = ["status", "severity", "incident_type"]
    search_fields = ["title", "description"]
    readonly_fields = ["start_time", "updated_at"]
