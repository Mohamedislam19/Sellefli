"""Signals for items app."""
from django.db.models.signals import pre_delete, pre_save
from django.dispatch import receiver
from .models import Item
from bookings.models import Booking, BookingStatus


@receiver(pre_delete, sender=Item)
def item_deleted_handler(sender, instance, **kwargs):
    """Handle notifications when item is deleted."""
    from notifications.services import NotificationService
    
    # Get all active bookings for this item
    affected_bookings = Booking.objects.filter(
        item=instance,
        status__in=[BookingStatus.PENDING, BookingStatus.ACCEPTED, BookingStatus.ACTIVE]
    ).select_related('borrower', 'owner')
    
    if affected_bookings.exists():
        NotificationService.create_item_deleted_notification(instance, affected_bookings)


@receiver(pre_save, sender=Item)
def item_availability_changed_handler(sender, instance, **kwargs):
    """Handle notifications when item availability changes."""
    from notifications.services import NotificationService
    
    # Check if this is an update (not creation)
    if instance.pk:
        try:
            old_instance = Item.objects.get(pk=instance.pk)
            # If item is being marked unavailable
            if old_instance.is_available and not instance.is_available:
                # Get pending bookings
                affected_bookings = Booking.objects.filter(
                    item=instance,
                    status=BookingStatus.PENDING
                ).select_related('borrower', 'owner')
                
                if affected_bookings.exists():
                    NotificationService.create_item_unavailable_notification(instance, affected_bookings)
        except Item.DoesNotExist:
            pass
