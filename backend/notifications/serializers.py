from rest_framework import serializers
from .models import Notification, UserDevice


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = [
            'id', 'user_id', 'title', 'body', 'notification_type',
            'data', 'is_read', 'created_at', 'read_at'
        ]
        read_only_fields = ['id', 'user_id', 'created_at']


class UserDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserDevice
        fields = [
            'id', 'user_id', 'fcm_token', 'device_type', 
            'device_name', 'is_active', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'user_id', 'created_at', 'updated_at']


class RegisterDeviceSerializer(serializers.Serializer):
    fcm_token = serializers.CharField(max_length=500)
    device_type = serializers.ChoiceField(choices=['android', 'ios', 'web'])
    device_name = serializers.CharField(max_length=255, required=False, default='')
    is_active = serializers.BooleanField(default=True)


class MarkReadSerializer(serializers.Serializer):
    notification_ids = serializers.ListField(
        child=serializers.UUIDField(),
        required=False
    )
    mark_all = serializers.BooleanField(default=False)
