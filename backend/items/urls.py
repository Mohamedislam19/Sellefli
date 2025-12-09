"""Item routes."""
from rest_framework.routers import DefaultRouter

from .views import ItemViewSet

router = DefaultRouter()
router.register(r"", ItemViewSet, basename="items")

urlpatterns = router.urls
