"""Shared constants for the backend."""

REGION = "northamerica-northeast1"

CAMPUS_IDS = ("sgw", "loyola")
INCIDENT_TYPES = (
    "protest",
    "construction",
    "gathering",
    "blockage",
    "emergency",
    "maintenance",
)
INCIDENT_STATUSES = ("reported", "investigating", "resolved")
VERIFICATION_LEVELS = ("unverified", "userReported", "verified")
ALERT_MODES = ("visual", "haptic", "silent")
TRUST_VOTES = ("confirm", "dispute")
