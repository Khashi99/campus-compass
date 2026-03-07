"""
Root URL configuration for Campus Compass API.
"""

from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

api = [
    path("users/", include("users.urls")),
    path("incidents/", include("incidents.urls")),
    path("locations/", include("locations.urls")),
    path("routing/", include("routing.urls")),
    path("notifications/", include("notifications.urls")),
    path("reports/", include("reports.urls")),
    path("admin-ops/", include("admin_ops.urls")),
    # OpenAPI schema
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
    path("docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include(api)),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
