"""
ASGI config for Campus Compass.

Exposes the ASGI callable as module-level ``application``.
Supports both HTTP (via Django) and WebSocket (via Django Channels).
"""

import os

from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.security.websocket import AllowedHostsOriginValidator
from django.core.asgi import get_asgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "campus_compass.settings")

django_asgi_app = get_asgi_application()

# Import websocket_urlpatterns after Django is set up
from campus_compass.ws_urls import websocket_urlpatterns  # noqa: E402

application = ProtocolTypeRouter(
    {
        "http": django_asgi_app,
        "websocket": AllowedHostsOriginValidator(
            AuthMiddlewareStack(URLRouter(websocket_urlpatterns))
        ),
    }
)
