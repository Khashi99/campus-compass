"""Input validation helpers for callable functions."""

from collections.abc import Mapping, Sequence
from typing import Any

from firebase_admin import firestore
from firebase_functions import https_fn


def as_dict(value: Any, field: str) -> dict[str, Any]:
    if not isinstance(value, Mapping):
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be an object.",
        )
    return dict(value)


def as_string(value: Any, field: str, max_length: int) -> str:
    if not isinstance(value, str):
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be a string.",
        )

    trimmed = value.strip()
    if not trimmed:
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} is required.",
        )

    if len(trimmed) > max_length:
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be at most {max_length} characters.",
        )

    return trimmed


def as_optional_string(value: Any, field: str, max_length: int) -> str | None:
    if value in (None, ""):
        return None
    return as_string(value, field, max_length)


def as_number(value: Any, field: str, minimum: float, maximum: float) -> float:
    if not isinstance(value, (int, float)) or isinstance(value, bool):
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be a number.",
        )

    numeric_value = float(value)
    if numeric_value < minimum or numeric_value > maximum:
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be between {minimum} and {maximum}.",
        )
    return numeric_value


def as_optional_number(
    value: Any,
    field: str,
    minimum: float,
    maximum: float,
) -> float | None:
    if value is None:
        return None
    return as_number(value, field, minimum, maximum)


def as_int(value: Any, field: str, minimum: int, maximum: int) -> int:
    numeric_value = as_number(value, field, minimum, maximum)
    if int(numeric_value) != numeric_value:
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be an integer.",
        )
    return int(numeric_value)


def as_enum(value: Any, allowed_values: Sequence[str], field: str) -> str:
    if not isinstance(value, str) or value not in allowed_values:
        allowed = ", ".join(allowed_values)
        raise https_fn.HttpsError(
            code="invalid-argument",
            message=f"{field} must be one of: {allowed}.",
        )
    return value


def as_optional_enum(
    value: Any,
    allowed_values: Sequence[str],
    field: str,
) -> str | None:
    if value is None:
        return None
    return as_enum(value, allowed_values, field)


def as_coordinates(value: Any) -> dict[str, float]:
    coordinates = as_dict(value, "coordinates")
    return {
        "latitude": as_number(
            coordinates.get("latitude"),
            "coordinates.latitude",
            -90,
            90,
        ),
        "longitude": as_number(
            coordinates.get("longitude"),
            "coordinates.longitude",
            -180,
            180,
        ),
    }


def as_quiet_hours(value: Any) -> dict[str, Any] | None:
    if value is None:
        return None

    quiet_hours = as_dict(value, "quietHours")
    enabled = bool(quiet_hours.get("enabled", False))

    result: dict[str, Any] = {"enabled": enabled}
    if "startHour" in quiet_hours and quiet_hours.get("startHour") is not None:
        result["startHour"] = as_int(
            quiet_hours.get("startHour"),
            "quietHours.startHour",
            0,
            23,
        )
    if "endHour" in quiet_hours and quiet_hours.get("endHour") is not None:
        result["endHour"] = as_int(
            quiet_hours.get("endHour"),
            "quietHours.endHour",
            0,
            23,
        )
    return result


def timestamp_or_now(value: Any) -> Any:
    return value if value is not None else firestore.SERVER_TIMESTAMP
