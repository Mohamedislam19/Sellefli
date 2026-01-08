"""Notification models for Selefli."""
import uuid
from django.db import models
from django.conf import settings


class NotificationType(models.TextChoices):
    """Notification event types."""
    BOOKING_CREATED = "booking_created", "Booking Request Created"
    BOOKING_ACCEPTED = "booking_accepted", "Booking Request Accepted"
    BOOKING_DECLINED = "booking_declined", "Booking Request Declined"
    ITEM_RETURNED = "item_returned", "Item Returned"
    DEPOSIT_RELEASED = "deposit_released", "Deposit Released"
    RATING_RECEIVED = "rating_received", "Rating Received"
    BOOKING_REMINDER = "booking_reminder", "Booking Reminder"
    CHAT_MESSAGE = "chat_message", "New Chat Message"


class Notification(models.Model):
    """In-app notification model with comprehensive tracking."""
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="notifications",
        db_index=True,
        help_text="User who receives this notification"
    )
    
    notification_type = models.CharField(
        max_length=50,
        choices=NotificationType.choices,
        db_index=True,
        help_text="Type of notification event"
    )
    
    title = models.CharField(
        max_length=255,
        help_text="Notification title (localized)"
    )
    
    body = models.TextField(
        help_text="Notification body text (localized)"
    )
    
    payload = models.JSONField(
        default=dict,
        blank=True,
        help_text="Additional metadata (booking_id, item_id, etc.)"
    )
    
    # Read/unread tracking
    is_read = models.BooleanField(
        default=False,
        db_index=True,
        help_text="Whether user has read this notification"
    )
    
    read_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="When notification was marked as read"
    )
    
    # Push notification tracking
    push_sent = models.BooleanField(
        default=False,
        help_text="Whether push notification was sent"
    )
    
    push_sent_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="When push notification was sent"
    )
    
    # Idempotency and deduplication
    idempotency_key = models.CharField(
        max_length=255,
        null=True,
        blank=True,
        db_index=True,
        help_text="Key to prevent duplicate notifications"
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Soft delete
    deleted_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="Soft delete timestamp"
    )
    
    class Meta:
        db_table = "notifications"
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["recipient", "-created_at"]),
            models.Index(fields=["recipient", "is_read", "-created_at"]),
            models.Index(fields=["notification_type", "-created_at"]),
            models.Index(fields=["idempotency_key"], name="notif_idempotency_idx"),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=["idempotency_key"],
                name="unique_idempotency_key",
                condition=models.Q(idempotency_key__isnull=False)
            )
        ]
    
    def __str__(self):
        return f"{self.notification_type} -> {self.recipient.username} ({self.created_at})"


class UserDevice(models.Model):
    """FCM device tokens for push notifications."""
    
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="devices",
        db_index=True,
        help_text="User who owns this device"
    )
    
    fcm_token = models.CharField(
        max_length=500,
        unique=True,
        help_text="Firebase Cloud Messaging token"
    )
    
    device_type = models.CharField(
        max_length=20,
        choices=[
            ("android", "Android"),
            ("ios", "iOS"),
            ("web", "Web"),
        ],
        help_text="Platform type"
    )
    
    device_name = models.CharField(
        max_length=255,
        blank=True,
        help_text="Device name/model"
    )
    
    is_active = models.BooleanField(
        default=True,
        db_index=True,
        help_text="Whether device is active for notifications"
    )
    
    last_used_at = models.DateTimeField(
        auto_now=True,
        help_text="Last time this token was used/refreshed"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = "user_devices"
        ordering = ["-last_used_at"]
        indexes = [
            models.Index(fields=["user", "is_active"]),
            models.Index(fields=["fcm_token"]),
        ]
    
    def __str__(self):
        return f"{self.user.username} - {self.device_type} ({self.device_name})"
