"""Notification models for Selefli."""
import uuid
from django.db import models
from django.conf import settings


class NotificationType(models.TextChoices):
    """Notification event types."""
    # Booking/Renting Lifecycle
    BOOKING_CREATED = "booking_created", "Booking Request Created"
    BOOKING_CANCELED = "booking_canceled", "Booking Request Canceled"
    BOOKING_ACCEPTED = "booking_accepted", "Booking Request Accepted"
    BOOKING_DECLINED = "booking_declined", "Booking Request Declined"
    BOOKING_EXPIRED = "booking_expired", "Booking Request Expired"
    ITEM_UNAVAILABLE = "item_unavailable", "Item Marked Unavailable"
    ITEM_DELETED = "item_deleted", "Item Deleted"
    BOOKING_STARTED = "booking_started", "Borrowing Started"
    BOOKING_COMPLETED = "booking_completed", "Borrowing Completed"
    BOOKING_OVERDUE = "booking_overdue", "Borrowing Overdue"
    DISPUTE_OPENED = "dispute_opened", "Dispute Opened"
    DISPUTE_RESOLVED = "dispute_resolved", "Dispute Resolved"
    ITEM_RETURNED = "item_returned", "Item Returned"
    
    # Trust, Safety & Reputation
    RATING_RECEIVED = "rating_received", "Rating Received"
    RATING_MODIFIED = "rating_modified", "Rating Modified"
    REPORT_SUBMITTED = "report_submitted", "Report Submitted"
    REPORT_REVIEWED = "report_reviewed", "Report Under Review"
    REPORT_RESOLVED = "report_resolved", "Report Resolved"
    WARNING_ISSUED = "warning_issued", "Warning Issued"
    RESTRICTION_APPLIED = "restriction_applied", "Restriction Applied"
    RESTRICTION_LIFTED = "restriction_lifted", "Restriction Lifted"
    
    # Deposits & Payments
    DEPOSIT_REQUIRED = "deposit_required", "Deposit Required"
    DEPOSIT_PAID = "deposit_paid", "Deposit Paid"
    DEPOSIT_HELD = "deposit_held", "Deposit Held"
    DEPOSIT_RELEASED = "deposit_released", "Deposit Released"
    DEPOSIT_PARTIAL_REFUND = "deposit_partial_refund", "Partial Deposit Refund"
    PAYMENT_FAILURE = "payment_failure", "Payment Failed"
    PAYMENT_SUCCESS = "payment_success", "Payment Successful"
    
    # Account & System Events
    ACCOUNT_VERIFIED = "account_verified", "Account Verified"
    PASSWORD_CHANGED = "password_changed", "Password Changed"
    NEW_LOGIN = "new_login", "New Login Detected"
    ACCOUNT_SUSPENDED = "account_suspended", "Account Suspended"
    ACCOUNT_REACTIVATED = "account_reactivated", "Account Reactivated"
    TERMS_UPDATE = "terms_update", "Terms & Conditions Updated"
    SYSTEM_ANNOUNCEMENT = "system_announcement", "System Announcement"
    
    # Legacy (to be removed if no chat system)
    BOOKING_REMINDER = "booking_reminder", "Booking Reminder"


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
