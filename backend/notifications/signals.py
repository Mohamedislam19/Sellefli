"""Django signals for automatic notification creation."""
from django.db.models.signals import post_save
from django.dispatch import receiver
from bookings.models import Booking, BookingStatus, DepositStatus
from ratings.models import Rating
from .services import NotificationService


@receiver(post_save, sender=Booking)
def booking_notification_handler(sender, instance, created, **kwargs):
    """Handle notification creation for booking events."""
    
    # New booking created (PENDING status)
    if created and instance.status == BookingStatus.PENDING:
        NotificationService.create_booking_created_notification(instance)
    
    # Booking status changed (not on creation)
    elif not created:
        # Track previous status using a field or check manually
        # For now, we'll trigger on status changes
        
        if instance.status == BookingStatus.ACCEPTED:
            NotificationService.create_booking_accepted_notification(instance)
        
        elif instance.status == BookingStatus.DECLINED:
            NotificationService.create_booking_declined_notification(instance)
        
        elif instance.status == BookingStatus.COMPLETED:
            NotificationService.create_item_returned_notification(instance)
        
        # Deposit released
        if instance.deposit_status == DepositStatus.RETURNED:
            NotificationService.create_deposit_released_notification(instance)


@receiver(post_save, sender=Rating)
def rating_notification_handler(sender, instance, created, **kwargs):
    """Handle notification creation when rating is received."""
    if created:
        # Note: Rating model uses 'target_user' and 'stars' fields
        NotificationService.create_rating_received_notification(instance)
