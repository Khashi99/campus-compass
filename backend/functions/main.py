"""Firebase Functions entrypoint.

The decorated functions live in feature modules under app/.
This file re-exports them so Firebase can discover them from main.py.
"""

from app.preferences import set_alert_preferences
from app.reporting import (
    post_incident_update,
    report_incident,
    request_incident_update,
    submit_trust_vote,
)
from app.triggers import sync_campus_state_on_incident_write

__all__ = [
    "post_incident_update",
    "report_incident",
    "request_incident_update",
    "set_alert_preferences",
    "submit_trust_vote",
    "sync_campus_state_on_incident_write",
]
