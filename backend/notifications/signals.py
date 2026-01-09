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
        # Use update_fields to track what changed
        # For now, we'll trigger on status changes
        
        if instance.status == BookingStatus.ACCEPTED:
            NotificationService.create_booking_accepted_notification(instance)
        
        elif instance.status == BookingStatus.DECLINED:
            NotificationService.create_booking_declined_notification(instance)
        
        elif instance.status == BookingStatus.ACTIVE:
            NotificationService.create_booking_started_notification(instance)
        
        elif instance.status == BookingStatus.COMPLETED:
            NotificationService.create_booking_completed_notification(instance)
        
        # Deposit status changes
        if instance.deposit_status == DepositStatus.RECEIVED:
            NotificationService.create_deposit_paid_notification(instance)
        
        if instance.deposit_status == DepositStatus.RETURNED:
            NotificationService.create_deposit_released_notification(instance)
        
        if instance.deposit_status == DepositStatus.KEPT:
            NotificationService.create_deposit_held_notification(instance)


@receiver(post_save, sender=Rating)
def rating_notification_handler(sender, instance, created, **kwargs):
    """Handle notification creation when rating is received."""
    if created:
        # Note: Rating model uses 'target_user' and 'stars' fields
        NotificationService.create_rating_received_notification(instance)
