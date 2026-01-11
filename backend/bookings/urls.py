

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BookingViewSet



router = DefaultRouter()



router.register(
    prefix='',                    # No extra prefix
    viewset=BookingViewSet,       # The ViewSet class
    basename='booking'            # URL names: booking-list, booking-detail, etc.
)



urlpatterns = router.urls



