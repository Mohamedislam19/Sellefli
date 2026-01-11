"""Signals for ratings app."""
from django.db.models import Sum
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver

from .models import Rating


def update_user_rating_stats(user):
    """Recalculate and save user rating statistics."""
    ratings = Rating.objects.filter(target_user=user)
    count = ratings.count()
    total_stars = ratings.aggregate(Sum("stars"))["stars__sum"] or 0
    
    user.rating_count = count
    user.rating_sum = total_stars
    user.save(update_fields=["rating_count", "rating_sum"])


@receiver(post_save, sender=Rating)
def rating_saved(sender, instance, created, **kwargs):
    """Update stats when a rating is created or updated."""
    update_user_rating_stats(instance.target_user)


@receiver(post_delete, sender=Rating)
def rating_deleted(sender, instance, **kwargs):
    """Update stats when a rating is deleted."""
    update_user_rating_stats(instance.target_user)
