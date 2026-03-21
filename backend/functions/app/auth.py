"""Authentication and authorization helpers.

Firebase Authentication handles sign-in. This module only validates
the auth context attached to callable requests and checks staff roles.
"""

from firebase_functions import https_fn


def require_auth_uid(request: https_fn.CallableRequest) -> str:
    auth = request.auth
    if auth is None or not auth.uid:
        raise https_fn.HttpsError(
            code="unauthenticated",
            message="Authentication is required for this operation.",
        )
    return auth.uid


def get_role(request: https_fn.CallableRequest) -> str | None:
    auth = request.auth
    if auth is None or auth.token is None:
        return None
    role = auth.token.get("role")
    return role if isinstance(role, str) else None


def require_staff(request: https_fn.CallableRequest) -> None:
    role = get_role(request)
    if role not in {"staff", "admin"}:
        raise https_fn.HttpsError(
            code="permission-denied",
            message="Only staff or admin users can perform this operation.",
        )
