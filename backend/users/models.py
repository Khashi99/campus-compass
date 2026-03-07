from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """Extended user model for Campus Compass."""

    class Role(models.TextChoices):
        STUDENT = "student", "Student"
        STAFF = "staff", "Staff"
        ADMIN = "admin", "Admin"

    role = models.CharField(max_length=20, choices=Role.choices, default=Role.STUDENT)
    device_token = models.CharField(
        max_length=255,
        blank=True,
        help_text="FCM device registration token for push notifications.",
    )
    accessibility_preferences = models.JSONField(default=dict, blank=True)

    class Meta:
        db_table = "users"

    def __str__(self):
        return f"{self.username} ({self.role})"
