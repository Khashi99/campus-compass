from django.db import models


class EmergencyIncident(models.Model):
    class IncidentType(models.TextChoices):
        FIRE = "fire", "Fire"
        LOCKDOWN = "lockdown", "Lockdown"
        MEDICAL = "medical", "Medical Emergency"
        HAZMAT = "hazmat", "Hazardous Material"
        WEATHER = "weather", "Severe Weather"
        EVACUATION = "evacuation", "Evacuation"
        OTHER = "other", "Other"

    class Severity(models.TextChoices):
        LOW = "low", "Low"
        MEDIUM = "medium", "Medium"
        HIGH = "high", "High"
        CRITICAL = "critical", "Critical"

    class Status(models.TextChoices):
        ACTIVE = "active", "Active"
        MONITORING = "monitoring", "Monitoring"
        RESOLVED = "resolved", "Resolved"

    title = models.CharField(max_length=200)
    incident_type = models.CharField(max_length=30, choices=IncidentType.choices)
    severity = models.CharField(max_length=20, choices=Severity.choices)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.ACTIVE)
    description = models.TextField()
    instructions = models.TextField(
        blank=True, help_text="Plain-language safety instructions shown to students."
    )
    affected_buildings = models.ManyToManyField(
        "locations.Building", blank=True, related_name="incidents"
    )
    created_by = models.ForeignKey(
        "users.User",
        null=True,
        on_delete=models.SET_NULL,
        related_name="created_incidents",
    )
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = "incidents"
        ordering = ["-start_time"]

    def __str__(self):
        return f"[{self.severity.upper()}] {self.title} ({self.status})"
