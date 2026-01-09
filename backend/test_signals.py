import sys
import os
import django

# Setup Django environment
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
django.setup()

from django.contrib.auth import get_user_model
from items.models import Item
from bookings.models import Booking
from ratings.models import Rating
from datetime import date
from django.utils import timezone

User = get_user_model()

def run_test():
    print("--- Starting Rating Signals Test ---")

    # 1. Create Users
    target_user, _ = User.objects.get_or_create(
        username="target_test",
        defaults={"phone": "1234567890", "email": "target@test.com"}
    )
    rater_user, _ = User.objects.get_or_create(
        username="rater_test",
        defaults={"phone": "0987654321", "email": "rater@test.com"}
    )
    
    # Reset stats just in case
    target_user.rating_sum = 0
    target_user.rating_count = 0
    target_user.save()
    
    print(f"Initial Stats: Sum={target_user.rating_sum}, Count={target_user.rating_count}")

    # 2. Create Item
    item, _ = Item.objects.get_or_create(
        owner=target_user,
        title="Test Item",
        defaults={
            "category": "Test",
            "description": "Test Desc",
            "estimated_value": 100,
            "deposit_amount": 10
        }
    )

    # 3. Create Booking
    booking, _ = Booking.objects.get_or_create(
        item=item,
        borrower=rater_user,
        owner=target_user,
        defaults={
            "start_date": timezone.now(),
            "return_by_date": timezone.now()
        }
    )

    # 4. Create Rating (Should trigger signal)
    print("\nCreating Rating (4 stars)...")
    rating = Rating.objects.create(
        booking=booking,
        rater=rater_user,
        target_user=target_user,
        stars=4
    )

    target_user.refresh_from_db()
    print(f"Stats after creation: Sum={target_user.rating_sum}, Count={target_user.rating_count}")
    
    if target_user.rating_sum == 4 and target_user.rating_count == 1:
        print("✅ SUCCESS: Creation signal worked.")
    else:
        print("❌ FAILURE: Creation signal failed.")

    # 5. Update Rating (Should trigger signal)
    print("\nUpdating Rating to 5 stars...")
    rating.stars = 5
    rating.save()

    target_user.refresh_from_db()
    print(f"Stats after update: Sum={target_user.rating_sum}, Count={target_user.rating_count}")

    if target_user.rating_sum == 5 and target_user.rating_count == 1:
        print("✅ SUCCESS: Update signal worked.")
    else:
        print("❌ FAILURE: Update signal failed.")

    # 6. Delete Rating (Should trigger signal)
    print("\nDeleting Rating...")
    rating.delete()

    target_user.refresh_from_db()
    print(f"Stats after deletion: Sum={target_user.rating_sum}, Count={target_user.rating_count}")

    if target_user.rating_sum == 0 and target_user.rating_count == 0:
        print("✅ SUCCESS: Deletion signal worked.")
    else:
        print("❌ FAILURE: Deletion signal failed.")

    # Cleanup
    print("\nCleaning up test data...")
    booking.delete()
    item.delete()
    target_user.delete()
    rater_user.delete()
    print("Done.")

if __name__ == "__main__":
    run_test()
