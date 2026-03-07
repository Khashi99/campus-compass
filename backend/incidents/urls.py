from django.urls import path

from .views import ActiveIncidentListView, IncidentDetailView, IncidentListCreateView

urlpatterns = [
    path("", IncidentListCreateView.as_view(), name="incident-list-create"),
    path("active/", ActiveIncidentListView.as_view(), name="incident-active"),
    path("<int:pk>/", IncidentDetailView.as_view(), name="incident-detail"),
]
