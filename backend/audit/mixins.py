"""Mixin that views can inherit to write to the audit log."""

from .models import AuditLog


class AuditMixin:
    def record_action(self, action: str, metadata: dict = None):
        user = getattr(self.request, "user", None)
        AuditLog.objects.create(
            actor=user if (user and user.is_authenticated) else None,
            action=action,
            metadata=metadata or {},
        )
