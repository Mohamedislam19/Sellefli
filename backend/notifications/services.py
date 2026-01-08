"""Notification service layer for creating and managing notifications."""
import hashlib
from datetime import datetime
from typing import Optional, Dict, Any
from django.utils import timezone
from django.db import transaction
from .models import Notification, NotificationType


class NotificationService:
    """Service for creating and managing notifications with idempotency."""
    
    @staticmethod
    def _generate_idempotency_key(
        recipient_id: str,
        notification_type: str,
        reference_id: Optional[str] = None
    ) -> str:
        """Generate unique idempotency key to prevent duplicates."""
        components = [str(recipient_id), notification_type]
        if reference_id:
            components.append(str(reference_id))
        
        key_string = ":".join(components)
        return hashlib.sha256(key_string.encode()).hexdigest()
    
    @classmethod
    @transaction.atomic
    def create_notification(
        cls,
        recipient,
        notification_type: str,
        title: str,
        body: str,
        payload: Optional[Dict[str, Any]] = None,
        idempotency_key: Optional[str] = None,
        send_push: bool = True
    ) -> Optional[Notification]:
        """
        Create a notification with idempotency protection.
        
        Args:
            recipient: User instance who receives the notification
            notification_type: Type from NotificationType choices
            title: Notification title
            body: Notification body text
            payload: Additional metadata (booking_id, item_id, etc.)
            idempotency_key: Optional custom idempotency key
            send_push: Whether to trigger push notification
        
        Returns:
            Notification instance or None if duplicate detected
        """
        if payload is None:
            payload = {}
        
        # Check for existing notification with same idempotency key
        if idempotency_key:
            existing = Notification.objects.filter(
                idempotency_key=idempotency_key
            ).first()
            if existing:
                return existing
        
        # Create notification
        notification = Notification.objects.create(
            recipient=recipient,
            notification_type=notification_type,
            title=title,
            body=body,
            payload=payload,
            idempotency_key=idempotency_key
        )
        
        # Trigger realtime broadcast
        from .realtime import trigger_realtime_broadcast
        trigger_realtime_broadcast(notification)
        
        # Queue push notification if requested
        if send_push:
            from .tasks import send_push_notification_task
            send_push_notification_task(notification.id)
        
        return notification
    
    @classmethod
    def create_booking_created_notification(cls, booking) -> Optional[Notification]:
        """Create notification when booking request is made."""
        idempotency_key = cls._generate_idempotency_key(
            booking.owner.id,
            NotificationType.BOOKING_CREATED,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.owner,
            notification_type=NotificationType.BOOKING_CREATED,
            title=f"New Booking Request",
            body=f"{booking.borrower.username} wants to borrow your {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "borrower_id": str(booking.borrower.id),
                "start_date": booking.start_date.isoformat(),
                "return_by_date": booking.return_by_date.isoformat(),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_booking_accepted_notification(cls, booking) -> Optional[Notification]:
        """Create notification when booking is accepted."""
        idempotency_key = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.BOOKING_ACCEPTED,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.BOOKING_ACCEPTED,
            title=f"Booking Accepted!",
            body=f"{booking.owner.username} accepted your request for {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
                "booking_code": booking.booking_code,
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_booking_declined_notification(cls, booking) -> Optional[Notification]:
        """Create notification when booking is declined."""
        idempotency_key = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.BOOKING_DECLINED,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.BOOKING_DECLINED,
            title=f"Booking Declined",
            body=f"{booking.owner.username} declined your request for {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_item_returned_notification(cls, booking) -> Optional[Notification]:
        """Create notification when item is returned."""
        idempotency_key = cls._generate_idempotency_key(
            booking.owner.id,
            NotificationType.ITEM_RETURNED,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.owner,
            notification_type=NotificationType.ITEM_RETURNED,
            title=f"Item Returned",
            body=f"{booking.borrower.username} has returned your {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "borrower_id": str(booking.borrower.id),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_deposit_released_notification(cls, booking) -> Optional[Notification]:
        """Create notification when deposit is released."""
        idempotency_key = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.DEPOSIT_RELEASED,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.DEPOSIT_RELEASED,
            title=f"Deposit Released",
            body=f"Your deposit for {booking.item.title} has been released",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_rating_received_notification(cls, rating) -> Optional[Notification]:
        """Create notification when user receives a rating."""
        idempotency_key = cls._generate_idempotency_key(
            rating.target_user.id,
            NotificationType.RATING_RECEIVED,
            str(rating.id)
        )
        
        stars = "⭐" * rating.stars
        
        return cls.create_notification(
            recipient=rating.target_user,
            notification_type=NotificationType.RATING_RECEIVED,
            title=f"New Rating Received",
            body=f"{rating.rater.username} rated you {stars}",
            payload={
                "rating_id": str(rating.id),
                "rater_id": str(rating.rater.id),
                "rating_value": rating.stars,
                "booking_id": str(rating.booking.id) if rating.booking else None,
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def mark_as_read(cls, notification_id: str, user) -> bool:
        """Mark notification as read."""
        try:
            notification = Notification.objects.get(
                id=notification_id,
                recipient=user,
                is_read=False
            )
            notification.is_read = True
            notification.read_at = timezone.now()
            notification.save(update_fields=["is_read", "read_at", "updated_at"])
            return True
        except Notification.DoesNotExist:
            return False
    
    @classmethod
    def mark_all_as_read(cls, user) -> int:
        """Mark all unread notifications as read for a user."""
        count = Notification.objects.filter(
            recipient=user,
            is_read=False
        ).update(
            is_read=True,
            read_at=timezone.now()
        )
        return count
    
    @classmethod
    def delete_notification(cls, notification_id: str, user) -> bool:
        """Soft delete a notification."""
        try:
            notification = Notification.objects.get(
                id=notification_id,
                recipient=user
            )
            notification.deleted_at = timezone.now()
            notification.save(update_fields=["deleted_at", "updated_at"])
            return True
        except Notification.DoesNotExist:
            return False
    
    @classmethod
    def get_unread_count(cls, user) -> int:
        """Get count of unread notifications for a user."""
        return Notification.objects.filter(
            recipient=user,
            is_read=False,
            deleted_at__isnull=True
        ).count()
