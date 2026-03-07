import json

from channels.generic.websocket import AsyncWebsocketConsumer


class IncidentConsumer(AsyncWebsocketConsumer):
    """
    WebSocket consumer that pushes incident updates to connected Flutter clients.
    All connected clients join the "incidents" group. When a new incident is
    created or updated, the backend broadcasts to this group.
    """

    GROUP_NAME = "incidents"

    async def connect(self):
        await self.channel_layer.group_add(self.GROUP_NAME, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(self.GROUP_NAME, self.channel_name)

    # Messages pushed by the backend (via channel_layer.group_send)
    async def incident_update(self, event):
        await self.send(text_data=json.dumps(event["data"]))
