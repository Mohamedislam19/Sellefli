# Signals to auto-send notifications on certain events
from django.db.models.signals import post_save
from django.dispatch import receiver
from .services import NotificationService


# Import models that trigger notifications
# Uncomment these when the models are available:
# from bookings.models import Booking
# from ratings.models import Rating


# Example signal handlers - uncomment and adapt as needed:

# @receiver(post_save, sender=Booking)
# def booking_notification(sender, instance, created, **kwargs):
#     """Send notification when booking status changes"""
#     if created:
#         # New booking request
#         NotificationService.send_booking_request(
#             owner_id=instance.item.owner_id,
#             renter_name=instance.renter_name,
#             item_name=instance.item.title,
#             booking_id=str(instance.id)
#         )
#     elif instance.status == 'approved':
#         NotificationService.send_booking_approved(
#             renter_id=instance.renter_id,
#             item_name=instance.item.title,
#             booking_id=str(instance.id)
#         )
#     elif instance.status == 'rejected':
#         NotificationService.send_booking_rejected(
#             renter_id=instance.renter_id,
#             item_name=instance.item.title,
#             booking_id=str(instance.id)
#         )


# @receiver(post_save, sender=Rating)
# def rating_notification(sender, instance, created, **kwargs):
#     """Send notification when item receives a new rating"""
#     if created:
#         NotificationService.send_new_rating(
#             owner_id=instance.item.owner_id,
#             rater_name=instance.rater_name,
#             item_name=instance.item.title,
#             rating=instance.rating,
#             rating_id=str(instance.id)
#         )
