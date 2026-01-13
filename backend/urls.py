"""Project URL router for Sellefli Backend."""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.http import JsonResponse


def health_check(request):
    """Health check endpoint for Render."""
    # Check Supabase configuration status
    supabase_url = getattr(settings, 'SUPABASE_URL', None)
    supabase_key = getattr(settings, 'SUPABASE_SERVICE_ROLE_KEY', None)
    jwt_secret = getattr(settings, 'SUPABASE_JWT_SECRET', None)
    
    supabase_status = "configured" if supabase_url and supabase_key else "missing"
    
    return JsonResponse({
        "status": "healthy",
        "service": "sellefli-backend",
        "supabase_auth": supabase_status,
        "supabase_url_set": bool(supabase_url),
        "supabase_key_set": bool(supabase_key),
        "jwt_secret_set": bool(jwt_secret),
        "jwt_secret_length": len(jwt_secret) if jwt_secret else 0,
    })


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
