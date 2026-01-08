"""Permissions for notification endpoints."""
from rest_framework import permissions


class IsNotificationRecipient(permissions.BasePermission):
    """
    Permission to ensure users can only access their own notifications.
    """
    
    def has_object_permission(self, request, view, obj):
        """Check if user is the notification recipient."""
        return obj.recipient == request.user


class IsDeviceOwner(permissions.BasePermission):
    """
    Permission to ensure users can only manage their own devices.
    """
    
    def has_object_permission(self, request, view, obj):
        """Check if user owns the device."""
        return obj.user == request.user
