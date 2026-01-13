from django.db import models
from django.conf import settings
import uuid


class NotificationType(models.TextChoices):
    """Types of notifications"""
    # Booking related
    BOOKING_REQUEST = 'booking_request', 'Booking Request'
    BOOKING_APPROVED = 'booking_approved', 'Booking Approved'
    BOOKING_REJECTED = 'booking_rejected', 'Booking Rejected'
    BOOKING_CANCELLED = 'booking_cancelled', 'Booking Cancelled'
    BOOKING_COMPLETED = 'booking_completed', 'Booking Completed'
    BOOKING_REMINDER = 'booking_reminder', 'Booking Reminder'
    
    # Item related
    ITEM_LIKED = 'item_liked', 'Item Liked'
    ITEM_REVIEW = 'item_review', 'Item Review'
    ITEM_AVAILABLE = 'item_available', 'Item Available'
    
    # Rating related
    NEW_RATING = 'new_rating', 'New Rating'
    
    # Account related
    ACCOUNT_UPDATE = 'account_update', 'Account Update'
    PAYMENT_RECEIVED = 'payment_received', 'Payment Received'
    
    # General
    GENERAL = 'general', 'General'


class Notification(models.Model):
    """Store notifications for users"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user_id = models.CharField(max_length=255, db_index=True)  # Supabase user ID
    title = models.CharField(max_length=255)
    body = models.TextField()
    notification_type = models.CharField(
        max_length=50,
        choices=NotificationType.choices,
        default=NotificationType.GENERAL
    )
    data = models.JSONField(default=dict, blank=True)  # Extra data payload
    is_read = models.BooleanField(default=False)
    is_sent = models.BooleanField(default=False)  # Whether FCM was sent
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user_id', 'is_read']),
            models.Index(fields=['user_id', 'created_at']),
        ]
    
    def __str__(self):
        return f"{self.notification_type}: {self.title}"


class UserDevice(models.Model):
    """Store user device tokens for push notifications"""
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user_id = models.CharField(max_length=255, db_index=True)  # Supabase user ID
    fcm_token = models.TextField(unique=True)
    device_type = models.CharField(max_length=20, choices=[
        ('android', 'Android'),
        ('ios', 'iOS'),
        ('web', 'Web'),
    ])
    device_name = models.CharField(max_length=255, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['user_id', 'fcm_token']
        indexes = [
            models.Index(fields=['user_id', 'is_active']),
        ]
    
    def __str__(self):
        return f"{self.user_id} - {self.device_type}"
