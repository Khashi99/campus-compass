from django.db import models


class StudentReport(models.Model):
    class ReportType(models.TextChoices):
        HAZARD = "hazard", "Hazard Spotted"
        ASSISTANCE = "assistance", "Assistance Needed"
        CHECKIN = "checkin", "Safe Check-in"
        OTHER = "other", "Other"

    user = models.ForeignKey("users.User", on_delete=models.SET_NULL, null=True)
    incident = models.ForeignKey(
        "incidents.EmergencyIncident", null=True, blank=True, on_delete=models.SET_NULL
    )
    report_type = models.CharField(max_length=30, choices=ReportType.choices)
    description = models.TextField(blank=True)
    submitted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "student_reports"
        ordering = ["-submitted_at"]

    def __str__(self):
        return f"Report({self.report_type}, {self.user_id})"
