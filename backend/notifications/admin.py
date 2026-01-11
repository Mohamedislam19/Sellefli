"""Admin configuration for notifications."""
from django.contrib import admin
from .models import Notification, UserDevice


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    """Admin interface for Notification model."""
    
    list_display = [
        'id',
        'recipient',
        'notification_type',
        'title',
        'is_read',
        'push_sent',
        'created_at',
    ]
    list_filter = [
        'notification_type',
        'is_read',
        'push_sent',
        'created_at',
    ]
    search_fields = [
        'recipient__username',
        'title',
        'body',
    ]
    readonly_fields = [
        'id',
        'created_at',
        'updated_at',
        'read_at',
        'push_sent_at',
    ]
    date_hierarchy = 'created_at'


@admin.register(UserDevice)
class UserDeviceAdmin(admin.ModelAdmin):
    """Admin interface for UserDevice model."""
    
    list_display = [
        'id',
        'user',
        'device_type',
        'device_name',
        'is_active',
        'last_used_at',
    ]
    list_filter = [
        'device_type',
        'is_active',
        'last_used_at',
    ]
    search_fields = [
        'user__username',
        'device_name',
        'fcm_token',
    ]
    readonly_fields = [
        'id',
        'created_at',
        'updated_at',
        'last_used_at',
    ]
