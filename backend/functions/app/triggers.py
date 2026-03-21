"""Firestore event handlers."""

from firebase_functions import firestore_fn

from app.campus_state import recompute_campus_state
from app.constants import CAMPUS_IDS, REGION


@firestore_fn.on_document_written(
    document="incidents/{incidentId}",
    region=REGION,
)
def sync_campus_state_on_incident_write(event) -> None:
    if event.data is None:
        return

    affected_campuses: set[str] = set()
    for snapshot in (event.data.before, event.data.after):
        if snapshot is None or not snapshot.exists:
            continue

        snapshot_data = snapshot.to_dict() or {}
        campus_id = snapshot_data.get("campusId")
        if isinstance(campus_id, str) and campus_id in CAMPUS_IDS:
            affected_campuses.add(campus_id)

    for campus_id in affected_campuses:
        recompute_campus_state(campus_id)
