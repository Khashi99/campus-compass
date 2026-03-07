from django.db import models


class AuditLog(models.Model):
    actor = models.ForeignKey(
        "users.User", null=True, on_delete=models.SET_NULL, related_name="audit_logs"
    )
    action = models.CharField(max_length=100)
    timestamp = models.DateTimeField(auto_now_add=True)
    metadata = models.JSONField(default=dict)

    class Meta:
        db_table = "audit_logs"
        ordering = ["-timestamp"]

    def __str__(self):
        return f"AuditLog({self.actor_id}, {self.action}, {self.timestamp})"
