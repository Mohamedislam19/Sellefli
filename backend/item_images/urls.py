"""Item image routes."""
from rest_framework.routers import DefaultRouter

from .views import ItemImageViewSet

router = DefaultRouter()
router.register(r"", ItemImageViewSet, basename="item-images")

urlpatterns = router.urls
