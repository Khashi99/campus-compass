"""
Celery tasks for sending Firebase Cloud Messaging push notifications
and broadcasting WebSocket events via Django Channels.
"""

import logging
from datetime import datetime, timezone

from asgiref.sync import async_to_sync
from celery import shared_task
from channels.layers import get_channel_layer

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=10)
def dispatch_incident_alert(self, incident_id: int) -> dict:
    """
    1. Load the incident.
    2. Send FCM push notification to all users that have a device token.
    3. Broadcast a WebSocket event to active app clients.
    4. Record Notification rows for each recipient.
    """
    # Import here to avoid circular imports at module load time
    from incidents.models import EmergencyIncident
    from users.models import User

    from .models import Notification

    try:
        incident = EmergencyIncident.objects.get(pk=incident_id)
    except EmergencyIncident.DoesNotExist:
        logger.error("Incident %s not found — skipping alert.", incident_id)
        return {"sent": 0}

    title = f"[{incident.severity.upper()}] {incident.title}"
    body = incident.instructions or incident.description

    # ── FCM push ────────────────────────────────────────────────────────────
    recipients = User.objects.exclude(device_token="").values_list("id", "device_token")
    sent = 0

    try:
        import firebase_admin
        from firebase_admin import messaging

        if not firebase_admin._apps:
            from django.conf import settings

            cred = firebase_admin.credentials.Certificate(settings.FIREBASE_CREDENTIALS_PATH)
            firebase_admin.initialize_app(cred)

        notifications_to_create = []
        for user_id, token in recipients:
            try:
                message = messaging.Message(
                    notification=messaging.Notification(title=title, body=body),
                    data={
                        "incident_id": str(incident_id),
                        "severity": incident.severity,
                        "incident_type": incident.incident_type,
                    },
                    token=token,
                )
                response = messaging.send(message)
                notifications_to_create.append(
                    Notification(
                        user_id=user_id,
                        incident_id=incident_id,
                        message=body,
                        sent_at=datetime.now(tz=timezone.utc),
                        delivery_status=Notification.DeliveryStatus.SENT,
                        fcm_message_id=response,
                    )
                )
                sent += 1
            except Exception as exc:
                logger.warning("FCM send failed for user %s: %s", user_id, exc)
                notifications_to_create.append(
                    Notification(
                        user_id=user_id,
                        incident_id=incident_id,
                        message=body,
                        delivery_status=Notification.DeliveryStatus.FAILED,
                    )
                )

        Notification.objects.bulk_create(notifications_to_create)

    except Exception as exc:
        logger.error("FCM dispatch error: %s", exc)
        raise self.retry(exc=exc)

    # ── WebSocket broadcast ──────────────────────────────────────────────────
    channel_layer = get_channel_layer()
    payload = {
        "type": "incident_update",
        "data": {
            "incident_id": incident_id,
            "title": incident.title,
            "severity": incident.severity,
            "status": incident.status,
            "instructions": incident.instructions,
        },
    }
    async_to_sync(channel_layer.group_send)("incidents", payload)

    logger.info("Alert dispatched for incident %s — %d FCM sent.", incident_id, sent)
    return {"sent": sent}
