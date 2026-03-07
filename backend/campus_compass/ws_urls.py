"""WebSocket URL patterns for Django Channels."""

from django.urls import re_path

from incidents.consumers import IncidentConsumer

websocket_urlpatterns = [
    re_path(r"^ws/incidents/$", IncidentConsumer.as_asgi()),
]
