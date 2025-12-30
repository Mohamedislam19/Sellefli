"""Signals for ratings app."""
from django.db.models import Sum
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver

from .models import Rating


def update_user_rating_stats(user):
    """Recalculate and save user rating statistics."""
    stats = Rating.objects.filter(target_user=user).aggregate(
        total_stars=Sum("stars"),
        count=models.Count("id"),  # Use Count from django.db.models if needed, or just count()
    )
    # aggregate returns None for Sum if no rows, so handle that
    # Actually, let's use a simpler approach or ensure imports are correct.
    # Re-importing models inside function to avoid circular imports if any, though signals usually fine.
    
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
