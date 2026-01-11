"""Views for notification API endpoints."""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone

from .models import Notification, UserDevice
from .serializers import (
    NotificationSerializer,
    NotificationListSerializer,
    MarkAsReadSerializer,
    UserDeviceSerializer,
    UnreadCountSerializer,
)
from .permissions import IsNotificationRecipient, IsDeviceOwner
from .services import NotificationService


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for user notifications.
    
    Provides:
    - List notifications (GET /api/notifications/)
    - Retrieve notification (GET /api/notifications/{id}/)
    - Mark as read (POST /api/notifications/mark_as_read/)
    - Mark all as read (POST /api/notifications/mark_all_as_read/)
    - Delete notification (DELETE /api/notifications/{id}/)
    - Get unread count (GET /api/notifications/unread_count/)
    """
    
    permission_classes = [IsAuthenticated, IsNotificationRecipient]
    
    def get_queryset(self):
        """Return notifications for current user, excluding soft-deleted."""
        return Notification.objects.filter(
            recipient=self.request.user,
            deleted_at__isnull=True
        ).order_by('-created_at')
    
    def get_serializer_class(self):
        """Use lightweight serializer for list view."""
        if self.action == 'list':
            return NotificationListSerializer
        return NotificationSerializer
    
    def destroy(self, request, *args, **kwargs):
        """Soft delete a notification."""
        notification = self.get_object()
        success = NotificationService.delete_notification(
            notification.id,
            request.user
        )
        
        if success:
            return Response(status=status.HTTP_204_NO_CONTENT)
        return Response(
            {"error": "Failed to delete notification"},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    @action(detail=False, methods=['post'])
    def mark_as_read(self, request):
        """
        Mark specific notifications as read.
        
        Body:
        {
            "notification_ids": ["uuid1", "uuid2", ...]
        }
        """
        serializer = MarkAsReadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        notification_ids = serializer.validated_data.get('notification_ids', [])
        
        if not notification_ids:
            return Response(
                {"error": "No notification IDs provided"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Mark notifications as read
        updated = Notification.objects.filter(
            id__in=notification_ids,
            recipient=request.user,
            is_read=False
        ).update(
            is_read=True,
            read_at=timezone.now()
        )
        
        return Response({
            "marked_as_read": updated
        })
    
    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        """Mark all notifications as read for current user."""
        count = NotificationService.mark_all_as_read(request.user)
        
        return Response({
            "marked_as_read": count
        })
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications."""
        count = NotificationService.get_unread_count(request.user)
        serializer = UnreadCountSerializer({"unread_count": count})
        
        return Response(serializer.data)


class UserDeviceViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing user FCM device tokens.
    
    Provides:
    - Register device (POST /api/devices/)
    - List devices (GET /api/devices/)
    - Update device (PUT/PATCH /api/devices/{id}/)
    - Delete device (DELETE /api/devices/{id}/)
    """
    
    serializer_class = UserDeviceSerializer
    permission_classes = [IsAuthenticated, IsDeviceOwner]
    
    def get_queryset(self):
        """Return devices for current user."""
        return UserDevice.objects.filter(user=self.request.user)
    
    def perform_create(self, serializer):
        """Associate device with current user."""
        serializer.save(user=self.request.user)
