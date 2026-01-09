"""Signals for bookings app."""
from django.db.models.signals import pre_delete
from django.dispatch import receiver
from .models import Booking, BookingStatus


@receiver(pre_delete, sender=Booking)
def booking_deleted_handler(sender, instance, **kwargs):
    """Handle notifications when booking is deleted/canceled."""
    from notifications.services import NotificationService
    
    # Only send notification if booking was pending or accepted
    if instance.status in [BookingStatus.PENDING, BookingStatus.ACCEPTED]:
        # Notify the owner that borrower canceled
        NotificationService.create_booking_canceled_notification(instance)
