"""User alert preference functions."""

from typing import Any

from firebase_admin import firestore
from firebase_functions import https_fn

from app.auth import get_role, require_auth_uid
from app.constants import ALERT_MODES, REGION
from app.firebase_client import db
from app.validation import (
    as_dict,
    as_enum,
    as_optional_string,
    as_quiet_hours,
    timestamp_or_now,
)


@https_fn.on_call(region=REGION)
def set_alert_preferences(request: https_fn.CallableRequest) -> dict[str, Any]:
    data = as_dict(request.data or {}, "data")
    uid = require_auth_uid(request)

    mode = as_enum(data.get("mode"), ALERT_MODES, "mode")
    quiet_hours = as_quiet_hours(data.get("quietHours"))
    display_name = as_optional_string(data.get("displayName"), "displayName", 80)

    user_ref = db.collection("users").document(uid)
    existing_snapshot = user_ref.get()
    existing_data = existing_snapshot.to_dict() if existing_snapshot.exists else {}

    payload: dict[str, Any] = {
        "role": get_role(request) or "student",
        "alertPreference": {
            "mode": mode,
            "quietHours": quiet_hours,
        },
        "createdAt": timestamp_or_now(existing_data.get("createdAt")),
        "updatedAt": firestore.SERVER_TIMESTAMP,
    }
    if display_name is not None:
        payload["displayName"] = display_name

    user_ref.set(payload, merge=True)
    return {"saved": True, "mode": mode}
