"""Derived campus-state calculations and Firestore sync helpers."""

from typing import Any

from firebase_admin import firestore
from google.cloud.firestore_v1.base_query import FieldFilter

from app.firebase_client import db


def severity_for_type(incident_type: str) -> int:
    if incident_type in {"emergency", "protest", "blockage"}:
        return 2
    return 1


def default_zone_radius(incident_type: str) -> int:
    if incident_type == "emergency":
        return 120
    if incident_type == "protest":
        return 100
    if incident_type == "blockage":
        return 60
    return 45


def compute_verification_progress(
    *,
    user_reports: int,
    confirm_count: int,
    dispute_count: int,
    staff_verified: bool,
) -> int:
    base = 25 if user_reports > 0 else 10
    community_boost = min(confirm_count * 12, 40)
    dispute_penalty = min(dispute_count * 10, 35)
    staff_boost = 35 if staff_verified else 0
    return clamp(base + community_boost + staff_boost - dispute_penalty, 0, 100)


def infer_verification_level(
    *,
    user_reports: int,
    confirm_count: int,
    staff_verified: bool,
) -> str:
    if staff_verified:
        return "verified"
    if user_reports > 0 or confirm_count > 0:
        return "userReported"
    return "unverified"


def recompute_campus_state(campus_id: str) -> None:
    query = (
        db.collection("incidents")
        .where(filter=FieldFilter("campusId", "==", campus_id))
        .where(filter=FieldFilter("isActive", "==", True))
        .order_by("updatedAt", direction=firestore.Query.DESCENDING)
        .limit(25)
    )
    incident_snapshots = list(query.get())

    active_incidents: list[dict[str, Any]] = []
    for snapshot in incident_snapshots:
        data = snapshot.to_dict() or {}
        active_incidents.append({"id": snapshot.id, **data})

    highest_severity = 0
    for incident in active_incidents:
        highest_severity = max(highest_severity, int(incident.get("severity", 0)))

    if not active_incidents:
        status = "normal"
    elif highest_severity >= 2:
        status = "highRisk"
    else:
        status = "caution"

    headline = "No active incidents reported at this time."
    if active_incidents:
        headline = str(active_incidents[0].get("title") or headline)

    db.collection("campusState").document(campus_id).set(
        {
            "campusId": campus_id,
            "status": status,
            "headline": headline,
            "activeIncidentCount": len(active_incidents),
            "activeIncidentIds": [incident["id"] for incident in active_incidents[:5]],
            "updatedAt": firestore.SERVER_TIMESTAMP,
        },
        merge=True,
    )


def clamp(value: int, minimum: int, maximum: int) -> int:
    return max(minimum, min(maximum, value))
