from django.urls import path

from .views import SafeRouteView

urlpatterns = [
    path("safe-route/", SafeRouteView.as_view(), name="safe-route"),
]
