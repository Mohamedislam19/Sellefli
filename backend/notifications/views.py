from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone

from .models import Notification, UserDevice
from .serializers import (
    NotificationSerializer, 
    UserDeviceSerializer, 
    RegisterDeviceSerializer,
    MarkReadSerializer
)
from .services import NotificationService


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for user notifications
    
    list: Get all notifications for current user
    retrieve: Get a specific notification
    """
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user_id = self.request.user.id
        return Notification.objects.filter(user_id=user_id)
    
    @action(detail=False, methods=['get'])
    def unread(self, request):
        """Get unread notifications"""
        user_id = request.user.id
        notifications = Notification.objects.filter(user_id=user_id, is_read=False)
        serializer = self.get_serializer(notifications, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications"""
        user_id = request.user.id
        count = NotificationService.get_unread_count(user_id)
        return Response({'count': count})
    
    @action(detail=False, methods=['post'])
    def mark_read(self, request):
        """Mark notifications as read"""
        serializer = MarkReadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user_id = request.user.id
        
        if serializer.validated_data.get('mark_all'):
            count = NotificationService.mark_all_as_read(user_id)
            return Response({'marked': count})
        
        notification_ids = serializer.validated_data.get('notification_ids', [])
        marked = 0
        for nid in notification_ids:
            if NotificationService.mark_as_read(str(nid), user_id):
                marked += 1
        
        return Response({'marked': marked})
    
    @action(detail=True, methods=['post'])
    def read(self, request, pk=None):
        """Mark a single notification as read"""
        user_id = request.user.id
        success = NotificationService.mark_as_read(pk, user_id)
        if success:
            return Response({'status': 'marked as read'})
        return Response({'error': 'Notification not found'}, status=status.HTTP_404_NOT_FOUND)


class UserDeviceViewSet(viewsets.ModelViewSet):
    """
    ViewSet for managing user devices (FCM tokens)
    
    create: Register a new device
    list: Get all devices for current user
    destroy: Unregister a device
    """
    serializer_class = UserDeviceSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        user_id = self.request.user.id
        return UserDevice.objects.filter(user_id=user_id)
    
    def create(self, request, *args, **kwargs):
        """Register a device for push notifications"""
        serializer = RegisterDeviceSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user_id = request.user.id
        fcm_token = serializer.validated_data['fcm_token']
        
        # Update existing or create new
        device, created = UserDevice.objects.update_or_create(
            fcm_token=fcm_token,
            defaults={
                'user_id': user_id,
                'device_type': serializer.validated_data['device_type'],
                'device_name': serializer.validated_data.get('device_name', ''),
                'is_active': serializer.validated_data.get('is_active', True),
            }
        )
        
        response_serializer = UserDeviceSerializer(device)
        status_code = status.HTTP_201_CREATED if created else status.HTTP_200_OK
        return Response(response_serializer.data, status=status_code)
    
    @action(detail=False, methods=['post'])
    def unregister(self, request):
        """Unregister a device token"""
        fcm_token = request.data.get('fcm_token')
        if not fcm_token:
            return Response(
                {'error': 'fcm_token is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        deleted, _ = UserDevice.objects.filter(
            user_id=request.user.id,
            fcm_token=fcm_token
        ).delete()
        
        if deleted:
            return Response({'status': 'device unregistered'})
        return Response({'status': 'device not found'}, status=status.HTTP_404_NOT_FOUND)
