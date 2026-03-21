"""Incident reporting and moderation workflows."""

from typing import Any

from firebase_admin import firestore
from firebase_functions import https_fn

from app.auth import require_auth_uid, require_staff
from app.campus_state import (
    compute_verification_progress,
    default_zone_radius,
    infer_verification_level,
    recompute_campus_state,
    severity_for_type,
)
from app.constants import (
    CAMPUS_IDS,
    INCIDENT_STATUSES,
    INCIDENT_TYPES,
    REGION,
    TRUST_VOTES,
    VERIFICATION_LEVELS,
)
from app.firebase_client import db
from app.validation import (
    as_coordinates,
    as_dict,
    as_enum,
    as_optional_enum,
    as_optional_number,
    as_optional_string,
    as_string,
    timestamp_or_now,
)


@https_fn.on_call(region=REGION)
def report_incident(request: https_fn.CallableRequest) -> dict[str, Any]:
    data = as_dict(request.data or {}, "data")
    uid = require_auth_uid(request)

    campus_id = as_enum(data.get("campusId", "sgw"), CAMPUS_IDS, "campusId")
    incident_type = as_enum(data.get("type"), INCIDENT_TYPES, "type")
    title = as_string(data.get("title"), "title", 120)
    description = as_string(data.get("description"), "description", 1200)
    location = as_string(data.get("location"), "location", 120)
    building_code = as_optional_string(data.get("buildingCode"), "buildingCode", 32)
    coordinates = as_coordinates(data.get("coordinates"))
    zone_radius_meters = as_optional_number(
        data.get("zoneRadiusMeters"),
        "zoneRadiusMeters",
        10,
        250,
    )

    incident_ref = db.collection("incidents").document()
    reported_time = firestore.SERVER_TIMESTAMP
    verification_progress = compute_verification_progress(
        user_reports=1,
        confirm_count=1,
        dispute_count=0,
        staff_verified=False,
    )

    batch = db.batch()
    batch.set(
        incident_ref,
        {
            "campusId": campus_id,
            "title": title,
            "description": description,
            "location": location,
            "coordinates": coordinates,
            "buildingCode": building_code,
            "type": incident_type,
            "status": "reported",
            "verificationLevel": "userReported",
            "userReports": 1,
            "verificationProgress": verification_progress,
            "confirmCount": 1,
            "disputeCount": 0,
            "updateRequestCount": 0,
            "severity": severity_for_type(incident_type),
            "zoneRadiusMeters": zone_radius_meters
            if zone_radius_meters is not None
            else default_zone_radius(incident_type),
            "isActive": True,
            "createdBy": uid,
            "reportedTime": reported_time,
            "updatedAt": reported_time,
        },
    )
    batch.set(
        incident_ref.collection("reports").document(uid),
        {
            "uid": uid,
            "title": title,
            "description": description,
            "location": location,
            "coordinates": coordinates,
            "type": incident_type,
            "buildingCode": building_code,
            "submittedAt": reported_time,
        },
    )
    batch.set(
        incident_ref.collection("trustVotes").document(uid),
        {
            "uid": uid,
            "vote": "confirm",
            "source": "reporter",
            "submittedAt": reported_time,
            "updatedAt": reported_time,
        },
    )
    batch.commit()

    recompute_campus_state(campus_id)
    return {"incidentId": incident_ref.id, "status": "reported"}


@https_fn.on_call(region=REGION)
def submit_trust_vote(request: https_fn.CallableRequest) -> dict[str, Any]:
    data = as_dict(request.data or {}, "data")
    uid = require_auth_uid(request)

    incident_id = as_string(data.get("incidentId"), "incidentId", 128)
    vote = as_enum(data.get("vote"), TRUST_VOTES, "vote")

    incident_ref = db.collection("incidents").document(incident_id)
    trust_vote_ref = incident_ref.collection("trustVotes").document(uid)
    transaction = db.transaction()

    @firestore.transactional
    def apply_vote(transaction: firestore.Transaction) -> tuple[str, int]:
        incident_snapshot = incident_ref.get(transaction=transaction)
        trust_vote_snapshot = trust_vote_ref.get(transaction=transaction)

        if not incident_snapshot.exists:
            raise https_fn.HttpsError(
                code="not-found",
                message="Incident does not exist.",
            )

        incident = incident_snapshot.to_dict() or {}
        if not incident.get("isActive", False) or incident.get("status") == "resolved":
            raise https_fn.HttpsError(
                code="failed-precondition",
                message="Trust votes are disabled for resolved incidents.",
            )

        existing_vote_data = trust_vote_snapshot.to_dict() if trust_vote_snapshot.exists else {}
        previous_vote = None
        if existing_vote_data:
            previous_vote = as_optional_enum(
                existing_vote_data.get("vote"),
                TRUST_VOTES,
                "existingVote",
            )

        confirm_delta = 0
        dispute_delta = 0
        if previous_vote == "confirm":
            confirm_delta -= 1
        if previous_vote == "dispute":
            dispute_delta -= 1
        if vote == "confirm":
            confirm_delta += 1
        if vote == "dispute":
            dispute_delta += 1

        confirm_count = max(0, int(incident.get("confirmCount", 0)) + confirm_delta)
        dispute_count = max(0, int(incident.get("disputeCount", 0)) + dispute_delta)
        staff_verified = incident.get("verificationLevel") == "verified"

        verification_progress = compute_verification_progress(
            user_reports=int(incident.get("userReports", 0)),
            confirm_count=confirm_count,
            dispute_count=dispute_count,
            staff_verified=staff_verified,
        )
        verification_level = infer_verification_level(
            user_reports=int(incident.get("userReports", 0)),
            confirm_count=confirm_count,
            staff_verified=staff_verified,
        )

        transaction.set(
            trust_vote_ref,
            {
                "uid": uid,
                "vote": vote,
                "submittedAt": timestamp_or_now(existing_vote_data.get("submittedAt")),
                "updatedAt": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )
        transaction.update(
            incident_ref,
            {
                "confirmCount": confirm_count,
                "disputeCount": dispute_count,
                "verificationProgress": verification_progress,
                "verificationLevel": verification_level,
                "updatedAt": firestore.SERVER_TIMESTAMP,
            },
        )
        return verification_level, verification_progress

    verification_level, verification_progress = apply_vote(transaction)
    return {
        "incidentId": incident_id,
        "vote": vote,
        "verificationLevel": verification_level,
        "verificationProgress": verification_progress,
    }


@https_fn.on_call(region=REGION)
def request_incident_update(request: https_fn.CallableRequest) -> dict[str, Any]:
    data = as_dict(request.data or {}, "data")
    uid = require_auth_uid(request)

    incident_id = as_string(data.get("incidentId"), "incidentId", 128)
    message = as_optional_string(data.get("message"), "message", 280)

    incident_ref = db.collection("incidents").document(incident_id)
    update_request_ref = incident_ref.collection("updateRequests").document(uid)
    transaction = db.transaction()

    @firestore.transactional
    def apply_request(transaction: firestore.Transaction) -> bool:
        incident_snapshot = incident_ref.get(transaction=transaction)
        update_request_snapshot = update_request_ref.get(transaction=transaction)

        if not incident_snapshot.exists:
            raise https_fn.HttpsError(
                code="not-found",
                message="Incident does not exist.",
            )

        existing_request = update_request_snapshot.to_dict() if update_request_snapshot.exists else {}
        transaction.set(
            update_request_ref,
            {
                "uid": uid,
                "message": message,
                "requestedAt": timestamp_or_now(existing_request.get("requestedAt")),
                "updatedAt": firestore.SERVER_TIMESTAMP,
            },
            merge=True,
        )

        if not update_request_snapshot.exists:
            transaction.update(
                incident_ref,
                {
                    "updateRequestCount": firestore.Increment(1),
                    "updatedAt": firestore.SERVER_TIMESTAMP,
                },
            )

        return True

    accepted = apply_request(transaction)
    return {"incidentId": incident_id, "accepted": accepted}


@https_fn.on_call(region=REGION)
def post_incident_update(request: https_fn.CallableRequest) -> dict[str, Any]:
    data = as_dict(request.data or {}, "data")
    require_staff(request)

    incident_id = as_string(data.get("incidentId"), "incidentId", 128)
    content = as_string(data.get("content"), "content", 1000)
    author_name = as_string(data.get("authorName"), "authorName", 80)
    author_role = as_optional_string(data.get("authorRole"), "authorRole", 40)

    incident_ref = db.collection("incidents").document(incident_id)
    update_ref = incident_ref.collection("updates").document()
    transaction = db.transaction()

    @firestore.transactional
    def apply_update(transaction: firestore.Transaction) -> tuple[str, str]:
        incident_snapshot = incident_ref.get(transaction=transaction)
        if not incident_snapshot.exists:
            raise https_fn.HttpsError(
                code="not-found",
                message="Incident does not exist.",
            )

        incident = incident_snapshot.to_dict() or {}
        campus_id = str(incident.get("campusId", "sgw"))
        next_status = (
            as_enum(data.get("status"), INCIDENT_STATUSES, "status")
            if data.get("status") is not None
            else str(incident.get("status", "reported"))
        )
        next_verification_level = (
            as_enum(
                data.get("verificationLevel"),
                VERIFICATION_LEVELS,
                "verificationLevel",
            )
            if data.get("verificationLevel") is not None
            else str(incident.get("verificationLevel", "unverified"))
        )

        verification_progress = compute_verification_progress(
            user_reports=int(incident.get("userReports", 0)),
            confirm_count=int(incident.get("confirmCount", 0)),
            dispute_count=int(incident.get("disputeCount", 0)),
            staff_verified=next_verification_level == "verified",
        )

        transaction.set(
            update_ref,
            {
                "authorName": author_name,
                "authorRole": author_role or "Staff",
                "content": content,
                "postedTime": firestore.SERVER_TIMESTAMP,
            },
        )
        transaction.update(
            incident_ref,
            {
                "status": next_status,
                "verificationLevel": next_verification_level,
                "verificationProgress": verification_progress,
                "isActive": next_status != "resolved",
                "resolvedAt": firestore.SERVER_TIMESTAMP
                if next_status == "resolved"
                else firestore.DELETE_FIELD,
                "updatedAt": firestore.SERVER_TIMESTAMP,
            },
        )

        return campus_id, next_status

    campus_id, next_status = apply_update(transaction)
    recompute_campus_state(campus_id)
    return {
        "incidentId": incident_id,
        "updateId": update_ref.id,
        "status": next_status,
    }
