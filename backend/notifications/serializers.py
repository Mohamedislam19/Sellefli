"""Serializers for notification API."""
from rest_framework import serializers
from .models import Notification, UserDevice, NotificationType


class NotificationSerializer(serializers.ModelSerializer):
    """Serializer for Notification model."""
    
    class Meta:
        model = Notification
        fields = [
            "id",
            "notification_type",
            "title",
            "body",
            "payload",
            "is_read",
            "read_at",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "notification_type",
            "title",
            "body",
            "payload",
            "read_at",
            "created_at",
            "updated_at",
        ]


class NotificationListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for notification list."""
    
    class Meta:
        model = Notification
        fields = [
            "id",
            "notification_type",
            "title",
            "body",
            "is_read",
            "created_at",
        ]


class MarkAsReadSerializer(serializers.Serializer):
    """Serializer for marking notifications as read."""
    notification_ids = serializers.ListField(
        child=serializers.UUIDField(),
        required=False,
        help_text="List of notification IDs to mark as read. If empty, marks all as read."
    )


class UserDeviceSerializer(serializers.ModelSerializer):
    """Serializer for UserDevice model."""
    
    class Meta:
        model = UserDevice
        fields = [
            "id",
            "fcm_token",
            "device_type",
            "device_name",
            "is_active",
            "last_used_at",
            "created_at",
        ]
        read_only_fields = ["id", "last_used_at", "created_at"]
    
    def create(self, validated_data):
        """Create or update device token for user."""
        user = self.context['request'].user
        fcm_token = validated_data['fcm_token']
        
        # Check if token already exists
        device, created = UserDevice.objects.update_or_create(
            fcm_token=fcm_token,
            defaults={
                'user': user,
                'device_type': validated_data.get('device_type', 'android'),
                'device_name': validated_data.get('device_name', ''),
                'is_active': True,
            }
        )
        return device


class UnreadCountSerializer(serializers.Serializer):
    """Serializer for unread notification count."""
    unread_count = serializers.IntegerField(read_only=True)
