from django.urls import path

from .views import MyReportsView, SubmitReportView

urlpatterns = [
    path("", SubmitReportView.as_view(), name="reports-submit"),
    path("mine/", MyReportsView.as_view(), name="reports-mine"),
]
