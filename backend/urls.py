"""Project URL router placeholder."""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/items/", include("items.urls")),
    path("api/users/", include("users.urls")),
    path("api/item-images/", include("item_images.urls")),
    path("api/bookings/", include("bookings.urls")),
    path("api/ratings/", include("ratings.urls")),
]
