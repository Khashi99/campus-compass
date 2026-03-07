from django.db import models


class RouteRequest(models.Model):
    """Persisted log of routing queries for analytics."""

    user = models.ForeignKey("users.User", on_delete=models.SET_NULL, null=True)
    start_node = models.ForeignKey(
        "locations.RouteNode", on_delete=models.SET_NULL, null=True, related_name="+"
    )
    destination_node = models.ForeignKey(
        "locations.RouteNode", on_delete=models.SET_NULL, null=True, related_name="+"
    )
    total_cost = models.FloatField(null=True)
    path_node_ids = models.JSONField(default=list)
    accessible_only = models.BooleanField(default=False)
    requested_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "route_requests"
        ordering = ["-requested_at"]
