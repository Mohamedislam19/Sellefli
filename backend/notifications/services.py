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
    def create_booking_canceled_notification(cls, booking) -> Optional[Notification]:
        """Create notification when booking request is canceled by requester."""
        idempotency_key = cls._generate_idempotency_key(
            booking.owner.id,
            NotificationType.BOOKING_CANCELED,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.owner,
            notification_type=NotificationType.BOOKING_CANCELED,
            title=f"Booking Request Canceled",
            body=f"{booking.borrower.username} canceled their request for {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "borrower_id": str(booking.borrower.id),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_booking_started_notification(cls, booking) -> Optional[Notification]:
        """Create notification when borrowing period starts (deposit received)."""
        # Notify borrower
        idempotency_key_borrower = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.BOOKING_STARTED,
            str(booking.id)
        )
        
        cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.BOOKING_STARTED,
            title=f"Borrowing Started",
            body=f"Your borrowing of {booking.item.title} has started. Return by {booking.return_by_date.strftime('%B %d, %Y')}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
                "return_by_date": booking.return_by_date.isoformat(),
            },
            idempotency_key=idempotency_key_borrower
        )
        
        # Notify owner
        idempotency_key_owner = cls._generate_idempotency_key(
            booking.owner.id,
            NotificationType.BOOKING_STARTED,
            str(booking.id) + "_owner"
        )
        
        return cls.create_notification(
            recipient=booking.owner,
            notification_type=NotificationType.BOOKING_STARTED,
            title=f"Item Lending Started",
            body=f"{booking.borrower.username} has started borrowing your {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "borrower_id": str(booking.borrower.id),
                "return_by_date": booking.return_by_date.isoformat(),
            },
            idempotency_key=idempotency_key_owner
        )
    
    @classmethod
    def create_booking_completed_notification(cls, booking) -> Optional[Notification]:
        """Create notification when booking is completed."""
        # Notify both owner and borrower
        idempotency_key_borrower = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.BOOKING_COMPLETED,
            str(booking.id)
        )
        
        cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.BOOKING_COMPLETED,
            title=f"Booking Completed",
            body=f"Your borrowing of {booking.item.title} is now complete. Please rate your experience!",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
            },
            idempotency_key=idempotency_key_borrower
        )
        
        idempotency_key_owner = cls._generate_idempotency_key(
            booking.owner.id,
            NotificationType.BOOKING_COMPLETED,
            str(booking.id) + "_owner"
        )
        
        return cls.create_notification(
            recipient=booking.owner,
            notification_type=NotificationType.BOOKING_COMPLETED,
            title=f"Lending Completed",
            body=f"{booking.borrower.username} has completed borrowing your {booking.item.title}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "borrower_id": str(booking.borrower.id),
            },
            idempotency_key=idempotency_key_owner
        )
    
    @classmethod
    def create_deposit_paid_notification(cls, booking) -> Optional[Notification]:
        """Create notification when deposit is marked as received."""
        idempotency_key = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.DEPOSIT_PAID,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.DEPOSIT_PAID,
            title=f"Deposit Confirmed",
            body=f"Your deposit for {booking.item.title} has been confirmed by {booking.owner.username}",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_deposit_held_notification(cls, booking) -> Optional[Notification]:
        """Create notification when deposit is kept by owner."""
        idempotency_key = cls._generate_idempotency_key(
            booking.borrower.id,
            NotificationType.DEPOSIT_HELD,
            str(booking.id)
        )
        
        return cls.create_notification(
            recipient=booking.borrower,
            notification_type=NotificationType.DEPOSIT_HELD,
            title=f"Deposit Kept",
            body=f"Your deposit for {booking.item.title} has been kept due to damage or loss",
            payload={
                "booking_id": str(booking.id),
                "item_id": str(booking.item.id),
                "owner_id": str(booking.owner.id),
            },
            idempotency_key=idempotency_key
        )
    
    @classmethod
    def create_item_deleted_notification(cls, item, affected_bookings) -> None:
        """Create notifications when item is deleted while bookings exist."""
        for booking in affected_bookings:
            if booking.status in [BookingStatus.PENDING, BookingStatus.ACCEPTED]:
                idempotency_key = cls._generate_idempotency_key(
                    booking.borrower.id,
                    NotificationType.ITEM_DELETED,
                    str(booking.id)
                )
                
                cls.create_notification(
                    recipient=booking.borrower,
                    notification_type=NotificationType.ITEM_DELETED,
                    title=f"Item Deleted",
                    body=f"The item '{item.title}' you requested has been removed by the owner",
                    payload={
                        "booking_id": str(booking.id),
                        "item_id": str(item.id),
                        "owner_id": str(item.owner.id),
                    },
                    idempotency_key=idempotency_key
                )
    
    @classmethod
    def create_item_unavailable_notification(cls, item, affected_bookings) -> None:
        """Create notifications when item is marked unavailable while bookings exist."""
        for booking in affected_bookings:
            if booking.status == BookingStatus.PENDING:
                idempotency_key = cls._generate_idempotency_key(
                    booking.borrower.id,
                    NotificationType.ITEM_UNAVAILABLE,
                    str(booking.id)
                )
                
                cls.create_notification(
                    recipient=booking.borrower,
                    notification_type=NotificationType.ITEM_UNAVAILABLE,
                    title=f"Item Unavailable",
                    body=f"The item '{item.title}' you requested is no longer available",
                    payload={
                        "booking_id": str(booking.id),
                        "item_id": str(item.id),
                        "owner_id": str(item.owner.id),
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
