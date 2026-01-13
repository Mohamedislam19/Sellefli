"""Project URL router for Sellefli Backend."""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse


def health_check(request):
    """Health check endpoint for Render."""
    return JsonResponse({"status": "healthy", "service": "sellefli-backend"})


urlpatterns = [
    path("api/health/", health_check, name="health_check"),
    path("admin/", admin.site.urls),
    path("api/items/", include("items.urls")),
    path("api/users/", include("users.urls")),
    path("api/item-images/", include("item_images.urls")),
    path("api/bookings/", include("bookings.urls")),
    path("api/ratings/", include("ratings.urls")),
    path("api/", include("notifications.urls")),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
