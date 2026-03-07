from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView

from .views import LoginView, MeView, RegisterView, UpdateDeviceTokenView

urlpatterns = [
    path("register/", RegisterView.as_view(), name="users-register"),
    path("login/", LoginView.as_view(), name="users-login"),
    path("token/refresh/", TokenRefreshView.as_view(), name="users-token-refresh"),
    path("me/", MeView.as_view(), name="users-me"),
    path("me/device-token/", UpdateDeviceTokenView.as_view(), name="users-device-token"),
]
