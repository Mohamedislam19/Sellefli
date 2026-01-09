"""User routes."""

from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import UserViewSet, RegisterView, LoginView

router = DefaultRouter()
router.register(r"", UserViewSet, basename="users")

urlpatterns = [
    path("signup/", RegisterView.as_view(), name="signup"),
    path("login/", LoginView.as_view(), name="login"),
] + router.urls
