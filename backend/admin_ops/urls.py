from django.urls import path

from .views import CampusStatusView

urlpatterns = [
    path("campus-status/", CampusStatusView.as_view(), name="campus-status"),
]
