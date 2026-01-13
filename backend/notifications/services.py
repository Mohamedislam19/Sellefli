from .models import Notification, UserDevice, NotificationType
from .fcm import fcm_service
from django.utils import timezone


class NotificationService:
    """Service for creating and sending notifications"""
    
    @staticmethod
    def create_and_send(user_id: str, title: str, body: str, 
                        notification_type: str = NotificationType.GENERAL,
                        data: dict = None) -> Notification:
        """
        Create a notification and send push to user's devices
        
        Args:
            user_id: The Supabase user ID
            title: Notification title
            body: Notification body
            notification_type: Type of notification
            data: Extra data payload
            
        Returns:
            Notification: The created notification object
        """
        # Create notification in database
        notification = Notification.objects.create(
            user_id=user_id,
            title=title,
            body=body,
            notification_type=notification_type,
            data=data or {}
        )
        
        # Get user's active devices
        devices = UserDevice.objects.filter(user_id=user_id, is_active=True)
        tokens = [d.fcm_token for d in devices]
        
        # Send push notification
        if tokens:
            payload_data = {
                'notification_id': str(notification.id),
                'type': notification_type,
                **(data or {})
            }
            
            if len(tokens) == 1:
                success = fcm_service.send_notification(tokens[0], title, body, payload_data)
            else:
                result = fcm_service.send_to_multiple(tokens, title, body, payload_data)
                success = result.get('success', 0) > 0
            
            notification.is_sent = success
            notification.save(update_fields=['is_sent'])
        
        return notification
    
    @staticmethod
    def send_booking_request(owner_id: str, renter_name: str, item_name: str, 
                            booking_id: str) -> Notification:
        """Send notification when someone requests to book an item"""
        return NotificationService.create_and_send(
            user_id=owner_id,
            title="New Booking Request",
            body=f"{renter_name} wants to rent your {item_name}",
            notification_type=NotificationType.BOOKING_REQUEST,
            data={'booking_id': booking_id}
        )
    
    @staticmethod
    def send_booking_approved(renter_id: str, item_name: str, 
                             booking_id: str) -> Notification:
        """Send notification when booking is approved"""
        return NotificationService.create_and_send(
            user_id=renter_id,
            title="Booking Approved! 🎉",
            body=f"Your booking for {item_name} has been approved",
            notification_type=NotificationType.BOOKING_APPROVED,
            data={'booking_id': booking_id}
        )
    
    @staticmethod
    def send_booking_rejected(renter_id: str, item_name: str, 
                             booking_id: str) -> Notification:
        """Send notification when booking is rejected"""
        return NotificationService.create_and_send(
            user_id=renter_id,
            title="Booking Declined",
            body=f"Your booking for {item_name} was not approved",
            notification_type=NotificationType.BOOKING_REJECTED,
            data={'booking_id': booking_id}
        )
    
    @staticmethod
    def send_booking_cancelled(recipient_id: str, item_name: str, 
                              booking_id: str, cancelled_by: str) -> Notification:
        """Send notification when booking is cancelled"""
        return NotificationService.create_and_send(
            user_id=recipient_id,
            title="Booking Cancelled",
            body=f"The booking for {item_name} has been cancelled by {cancelled_by}",
            notification_type=NotificationType.BOOKING_CANCELLED,
            data={'booking_id': booking_id}
        )
    
    @staticmethod
    def send_new_rating(owner_id: str, rater_name: str, item_name: str, 
                       rating: int, rating_id: str) -> Notification:
        """Send notification when someone rates an item"""
        stars = "⭐" * rating
        return NotificationService.create_and_send(
            user_id=owner_id,
            title="New Rating",
            body=f"{rater_name} rated your {item_name} {stars}",
            notification_type=NotificationType.NEW_RATING,
            data={'rating_id': rating_id}
        )
    
    @staticmethod
    def mark_as_read(notification_id: str, user_id: str) -> bool:
        """Mark a notification as read"""
        try:
            notification = Notification.objects.get(id=notification_id, user_id=user_id)
            notification.is_read = True
            notification.read_at = timezone.now()
            notification.save(update_fields=['is_read', 'read_at'])
            return True
        except Notification.DoesNotExist:
            return False
    
    @staticmethod
    def mark_all_as_read(user_id: str) -> int:
        """Mark all notifications as read for a user"""
        return Notification.objects.filter(
            user_id=user_id, 
            is_read=False
        ).update(is_read=True, read_at=timezone.now())
    
    @staticmethod
    def get_unread_count(user_id: str) -> int:
        """Get count of unread notifications"""
        return Notification.objects.filter(user_id=user_id, is_read=False).count()
