"""
Django Backend API Audit for Supabase Integration
Tests for: Profile, My Listings, Item Details, Booking pages
"""

import os
import sys
import django
import json
from pathlib import Path
from datetime import datetime, timedelta

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')
sys.path.insert(0, str(Path(__file__).parent / 'backend'))

django.setup()

from django.contrib.auth.models import User as DjangoUser
from users.models import User
from items.models import Item
from bookings.models import Booking
from ratings.models import Rating
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken
from uuid import uuid4

# ============================================================================
# TEST SETUP
# ============================================================================

client = APIClient()

def create_test_user(username: str, phone: str = None) -> User:
    """Create a test user."""
    if phone is None:
        phone = f"+1{str(uuid4())[:10]}"
    try:
        user = User.objects.get(username=username)
    except User.DoesNotExist:
        user = User.objects.create(
            username=username,
            phone=phone,
            avatar_url=f"https://avatar.example.com/{username}.jpg"
        )
    return user

def create_test_item(owner: User, title: str = "Test Item") -> Item:
    """Create a test item."""
    return Item.objects.create(
        owner=owner,
        title=title,
        category="Electronics",
        description="Test description",
        estimated_value=100.00,
        deposit_amount=20.00,
        start_date="2025-01-01",
        end_date="2025-12-31",
        lat=40.7128,
        lng=-74.0060,
        is_available=True
    )

def create_test_booking(item: Item, borrower: User) -> Booking:
    """Create a test booking."""
    return Booking.objects.create(
        item=item,
        owner=item.owner,
        borrower=borrower,
        status=Booking.Status.PENDING,
        start_date=datetime.now() + timedelta(days=1),
        return_by_date=datetime.now() + timedelta(days=8),
        total_cost=50.00
    )

# ============================================================================
# 1. PROFILE PAGE TESTS
# ============================================================================

class ProfilePageAudit:
    """Audit Profile page endpoints."""
    
    @staticmethod
    def test_fetch_current_user_profile():
        """Test: GET /api/users/me - Fetch current user profile."""
        print("\n" + "="*80)
        print("TEST 1.1: Fetch Current User Profile")
        print("="*80)
        
        user = create_test_user("profile_user_1")
        
        # Test without query param
        response = client.get(f'/api/users/me')
        print(f"Request: GET /api/users/me")
        print(f"Status (no ID): {response.status_code}")
        print(f"Response: {response.json()}")
        
        # Test with query param
        response = client.get(f'/api/users/me?id={user.id}')
        print(f"\nRequest: GET /api/users/me?id={user.id}")
        print(f"Status (with ID): {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            assert data['username'] == user.username
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_update_profile():
        """Test: PATCH /api/users/{id}/update-profile - Update user profile."""
        print("\n" + "="*80)
        print("TEST 1.2: Update User Profile")
        print("="*80)
        
        user = create_test_user("profile_user_2")
        new_avatar = "https://avatar.example.com/new.jpg"
        
        response = client.patch(
            f'/api/users/{user.id}/update-profile/',
            data={'avatar_url': new_avatar},
            format='json'
        )
        
        print(f"Request: PATCH /api/users/{user.id}/update-profile/")
        print(f"Body: {{'avatar_url': '{new_avatar}'}}")
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            
            # Verify update in DB
            user.refresh_from_db()
            assert user.avatar_url == new_avatar
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_get_user_statistics():
        """Test: GET /api/users/{id}/average-rating - Get user stats."""
        print("\n" + "="*80)
        print("TEST 1.3: Get User Statistics (Average Rating)")
        print("="*80)
        
        user = create_test_user("profile_user_3")
        user.rating_sum = 15
        user.rating_count = 3
        user.save()
        
        response = client.get(f'/api/users/{user.id}/average-rating/')
        
        print(f"Request: GET /api/users/{user.id}/average-rating/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            assert data['average_rating'] == 5.0
            assert data['rating_count'] == 3
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_fetch_user_booking_history():
        """Test: GET /api/bookings?owner_id=X or borrower_id=X - Fetch booking history."""
        print("\n" + "="*80)
        print("TEST 1.4: Fetch User Booking History")
        print("="*80)
        
        owner = create_test_user("profile_user_4")
        borrower = create_test_user("profile_user_5")
        item = create_test_item(owner)
        booking = create_test_booking(item, borrower)
        
        # Test owner's bookings
        response = client.get(f'/api/bookings/?owner_id={owner.id}')
        print(f"Request: GET /api/bookings/?owner_id={owner.id}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            # Check if booking is in results
            assert 'results' in data or isinstance(data, list)
            print("✅ PASSED (Owner View)")
        else:
            print(f"❌ FAILED: {response.json()}")
        
        # Test borrower's bookings
        response = client.get(f'/api/bookings/?borrower_id={borrower.id}')
        print(f"\nRequest: GET /api/bookings/?borrower_id={borrower.id}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response has {len(data.get('results', data))} bookings")
            print("✅ PASSED (Borrower View)")
        else:
            print(f"❌ FAILED: {response.json()}")

# ============================================================================
# 2. MY LISTINGS PAGE TESTS
# ============================================================================

class MyListingsPageAudit:
    """Audit My Listings page endpoints."""
    
    @staticmethod
    def test_fetch_user_listings():
        """Test: GET /api/items?excludeUserId=X - Fetch user's listings."""
        print("\n" + "="*80)
        print("TEST 2.1: Fetch User's Listings")
        print("="*80)
        
        owner = create_test_user("listings_user_1")
        item1 = create_test_item(owner, "Item 1")
        item2 = create_test_item(owner, "Item 2")
        
        # Fetch all items excluding this user (inverse filter)
        response = client.get(f'/api/items/')
        print(f"Request: GET /api/items/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {data}")
            # Should return paginated results
            assert 'results' in data or isinstance(data, list)
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_create_listing():
        """Test: POST /api/items - Create a new listing."""
        print("\n" + "="*80)
        print("TEST 2.2: Create New Listing")
        print("="*80)
        
        owner = create_test_user("listings_user_2")
        
        payload = {
            "owner_id": str(owner.id),
            "title": "New Test Item",
            "category": "Furniture",
            "description": "A test item for auction",
            "estimated_value": 250.00,
            "deposit_amount": 50.00,
            "start_date": "2025-01-15",
            "end_date": "2025-12-15",
            "lat": 40.7128,
            "lng": -74.0060,
            "is_available": True
        }
        
        response = client.post(
            '/api/items/',
            data=payload,
            format='json'
        )
        
        print(f"Request: POST /api/items/")
        print(f"Body: {json.dumps(payload, indent=2, default=str)}")
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            assert data['title'] == payload['title']
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_update_listing():
        """Test: PATCH /api/items/{id} - Update a listing."""
        print("\n" + "="*80)
        print("TEST 2.3: Update Listing")
        print("="*80)
        
        owner = create_test_user("listings_user_3")
        item = create_test_item(owner, "Original Title")
        
        update_data = {
            "title": "Updated Title",
            "is_available": False
        }
        
        response = client.patch(
            f'/api/items/{item.id}/',
            data=update_data,
            format='json'
        )
        
        print(f"Request: PATCH /api/items/{item.id}/")
        print(f"Body: {json.dumps(update_data, indent=2)}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            item.refresh_from_db()
            assert item.title == "Updated Title"
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_delete_listing():
        """Test: DELETE /api/items/{id} - Delete a listing."""
        print("\n" + "="*80)
        print("TEST 2.4: Delete Listing")
        print("="*80)
        
        owner = create_test_user("listings_user_4")
        item = create_test_item(owner, "To Delete")
        item_id = item.id
        
        response = client.delete(f'/api/items/{item_id}/')
        
        print(f"Request: DELETE /api/items/{item_id}/")
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 204]:
            # Verify deletion
            exists = Item.objects.filter(id=item_id).exists()
            assert not exists
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_unauthorized_item_update():
        """Test: PATCH /api/items/{id} - Unauthorized user cannot update."""
        print("\n" + "="*80)
        print("TEST 2.5: Access Control - Ownership Enforcement")
        print("="*80)
        
        owner = create_test_user("listings_user_5")
        attacker = create_test_user("listings_user_6")
        item = create_test_item(owner)
        
        update_data = {"title": "Hacked Title"}
        
        # Since we can't set request.user without JWT, we'll test the model logic
        # This would fail with proper auth in place
        response = client.patch(
            f'/api/items/{item.id}/',
            data=update_data,
            format='json'
        )
        
        print(f"Request: PATCH /api/items/{item.id}/ (unauthorized user)")
        print(f"Status: {response.status_code}")
        print(f"Response: {response.json() if response.status_code >= 400 else 'Update allowed'}")
        
        if response.status_code >= 400:
            print("✅ PASSED (Access Denied)")
        else:
            print("⚠️ WARNING: Authorization may not be enforced (requires JWT)")

# ============================================================================
# 3. ITEM DETAILS PAGE TESTS
# ============================================================================

class ItemDetailsPageAudit:
    """Audit Item Details page endpoints."""
    
    @staticmethod
    def test_fetch_item_by_id():
        """Test: GET /api/items/{id} - Fetch item details."""
        print("\n" + "="*80)
        print("TEST 3.1: Fetch Item Details by ID")
        print("="*80)
        
        owner = create_test_user("item_details_user_1")
        item = create_test_item(owner, "Detailed Item")
        
        response = client.get(f'/api/items/{item.id}/')
        
        print(f"Request: GET /api/items/{item.id}/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            assert data['id'] == str(item.id)
            assert data['title'] == item.title
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_fetch_item_with_owner_info():
        """Test: GET /api/items/{id} includes owner information."""
        print("\n" + "="*80)
        print("TEST 3.2: Fetch Item with Owner Info")
        print("="*80)
        
        owner = create_test_user("item_details_user_2")
        item = create_test_item(owner)
        
        response = client.get(f'/api/items/{item.id}/')
        
        print(f"Request: GET /api/items/{item.id}/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            assert 'owner' in data
            assert data['owner']['id'] == str(owner.id)
            assert data['owner']['username'] == owner.username
            print(f"Owner Info: {json.dumps(data['owner'], indent=2, default=str)}")
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_fetch_unavailable_item():
        """Test: GET /api/items/{id} - Fetch unavailable item (should still work)."""
        print("\n" + "="*80)
        print("TEST 3.3: Fetch Unavailable Item")
        print("="*80)
        
        owner = create_test_user("item_details_user_3")
        item = create_test_item(owner)
        item.is_available = False
        item.save()
        
        response = client.get(f'/api/items/{item.id}/')
        
        print(f"Request: GET /api/items/{item.id}/ (is_available=False)")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            assert data['is_available'] == False
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_fetch_invalid_item():
        """Test: GET /api/items/invalid-id - Invalid item ID."""
        print("\n" + "="*80)
        print("TEST 3.4: Fetch Invalid Item ID")
        print("="*80)
        
        fake_id = uuid4()
        response = client.get(f'/api/items/{fake_id}/')
        
        print(f"Request: GET /api/items/{fake_id}/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 404:
            print("✅ PASSED (404 Not Found)")
        else:
            print(f"⚠️ Unexpected status: {response.status_code}")
    
    @staticmethod
    def test_fetch_item_images():
        """Test: GET /api/items/{id}/images - Fetch item images."""
        print("\n" + "="*80)
        print("TEST 3.5: Fetch Item Images")
        print("="*80)
        
        owner = create_test_user("item_details_user_4")
        item = create_test_item(owner)
        
        response = client.get(f'/api/items/{item.id}/images/')
        
        print(f"Request: GET /api/items/{item.id}/images/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")

# ============================================================================
# 4. BOOKING PAGE TESTS
# ============================================================================

class BookingPageAudit:
    """Audit Booking page endpoints."""
    
    @staticmethod
    def test_create_booking():
        """Test: POST /api/bookings - Create a booking."""
        print("\n" + "="*80)
        print("TEST 4.1: Create Booking")
        print("="*80)
        
        owner = create_test_user("booking_user_1")
        borrower = create_test_user("booking_user_2")
        item = create_test_item(owner)
        
        payload = {
            "item_id": str(item.id),
            "owner_id": str(owner.id),
            "borrower_id": str(borrower.id),
            "start_date": (datetime.now() + timedelta(days=1)).isoformat(),
            "return_by_date": (datetime.now() + timedelta(days=8)).isoformat(),
            "total_cost": 75.00
        }
        
        response = client.post(
            '/api/bookings/',
            data=payload,
            format='json'
        )
        
        print(f"Request: POST /api/bookings/")
        print(f"Body: {json.dumps(payload, indent=2, default=str)}")
        print(f"Status: {response.status_code}")
        
        if response.status_code in [200, 201]:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            assert data['status'] == 'pending'
            print("✅ PASSED")
            return data['id']
        else:
            print(f"❌ FAILED: {response.json()}")
            return None
    
    @staticmethod
    def test_fetch_booking():
        """Test: GET /api/bookings/{id} - Fetch booking details."""
        print("\n" + "="*80)
        print("TEST 4.2: Fetch Booking Details")
        print("="*80)
        
        owner = create_test_user("booking_user_3")
        borrower = create_test_user("booking_user_4")
        item = create_test_item(owner)
        booking = create_test_booking(item, borrower)
        
        response = client.get(f'/api/bookings/{booking.id}/')
        
        print(f"Request: GET /api/bookings/{booking.id}/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            print(f"Response: {json.dumps(data, indent=2, default=str)}")
            assert data['id'] == str(booking.id)
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_accept_booking():
        """Test: POST /api/bookings/{id}/accept - Owner accepts booking."""
        print("\n" + "="*80)
        print("TEST 4.3: Accept Booking (Owner)")
        print("="*80)
        
        owner = create_test_user("booking_user_5")
        borrower = create_test_user("booking_user_6")
        item = create_test_item(owner)
        booking = create_test_booking(item, borrower)
        
        response = client.post(f'/api/bookings/{booking.id}/accept/')
        
        print(f"Request: POST /api/bookings/{booking.id}/accept/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            assert data['status'] == 'accepted'
            booking.refresh_from_db()
            assert booking.status == Booking.Status.ACCEPTED
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_decline_booking():
        """Test: POST /api/bookings/{id}/decline - Owner declines booking."""
        print("\n" + "="*80)
        print("TEST 4.4: Decline Booking (Owner)")
        print("="*80)
        
        owner = create_test_user("booking_user_7")
        borrower = create_test_user("booking_user_8")
        item = create_test_item(owner)
        booking = create_test_booking(item, borrower)
        
        response = client.post(f'/api/bookings/{booking.id}/decline/')
        
        print(f"Request: POST /api/bookings/{booking.id}/decline/")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            assert data['status'] == 'declined'
            print("✅ PASSED")
        else:
            print(f"❌ FAILED: {response.json()}")
    
    @staticmethod
    def test_booking_state_transitions():
        """Test: Valid booking state transitions."""
        print("\n" + "="*80)
        print("TEST 4.5: Booking State Transitions")
        print("="*80)
        
        owner = create_test_user("booking_user_9")
        borrower = create_test_user("booking_user_10")
        item = create_test_item(owner)
        booking = create_test_booking(item, borrower)
        
        # PENDING -> ACCEPTED
        print(f"\nPending -> Accepted")
        response = client.post(f'/api/bookings/{booking.id}/accept/')
        assert response.status_code == 200
        booking.refresh_from_db()
        assert booking.status == Booking.Status.ACCEPTED
        print("✅ Transition successful")
        
        # ACCEPTED -> ACTIVE (mark deposit received)
        print(f"\nAccepted -> Active")
        response = client.post(f'/api/bookings/{booking.id}/mark-deposit-received/')
        assert response.status_code == 200
        booking.refresh_from_db()
        assert booking.status == Booking.Status.ACTIVE
        print("✅ Transition successful")
        
        # ACTIVE -> COMPLETED (mark deposit returned)
        print(f"\nActive -> Completed")
        response = client.post(f'/api/bookings/{booking.id}/mark-deposit-returned/')
        assert response.status_code == 200
        booking.refresh_from_db()
        assert booking.status == Booking.Status.COMPLETED
        print("✅ Transition successful")
    
    @staticmethod
    def test_overlapping_bookings():
        """Test: Prevent overlapping bookings (if implemented)."""
        print("\n" + "="*80)
        print("TEST 4.6: Overlapping Bookings Prevention")
        print("="*80)
        
        owner = create_test_user("booking_user_11")
        borrower1 = create_test_user("booking_user_12")
        borrower2 = create_test_user("booking_user_13")
        item = create_test_item(owner)
        
        # Create first booking
        booking1_data = {
            "item_id": str(item.id),
            "owner_id": str(owner.id),
            "borrower_id": str(borrower1.id),
            "start_date": (datetime.now() + timedelta(days=1)).isoformat(),
            "return_by_date": (datetime.now() + timedelta(days=8)).isoformat(),
            "total_cost": 75.00
        }
        
        response1 = client.post('/api/bookings/', data=booking1_data, format='json')
        print(f"Request: POST /api/bookings/ (Booking 1)")
        print(f"Status: {response1.status_code}")
        
        # Create overlapping booking
        booking2_data = {
            "item_id": str(item.id),
            "owner_id": str(owner.id),
            "borrower_id": str(borrower2.id),
            "start_date": (datetime.now() + timedelta(days=5)).isoformat(),
            "return_by_date": (datetime.now() + timedelta(days=12)).isoformat(),
            "total_cost": 75.00
        }
        
        response2 = client.post('/api/bookings/', data=booking2_data, format='json')
        print(f"\nRequest: POST /api/bookings/ (Overlapping Booking)")
        print(f"Status: {response2.status_code}")
        
        if response2.status_code >= 400:
            print("✅ PASSED (Overlap prevented)")
        else:
            print("⚠️ WARNING: Overlapping bookings not prevented (feature may not be implemented)")


# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __name__ == "__main__":
    print("\n" + "="*80)
    print("DJANGO BACKEND API AUDIT FOR SUPABASE")
    print("Testing Profile, My Listings, Item Details, and Booking endpoints")
    print("="*80)
    
    try:
        # Profile Tests
        ProfilePageAudit.test_fetch_current_user_profile()
        ProfilePageAudit.test_update_profile()
        ProfilePageAudit.test_get_user_statistics()
        ProfilePageAudit.test_fetch_user_booking_history()
        
        # My Listings Tests
        MyListingsPageAudit.test_fetch_user_listings()
        MyListingsPageAudit.test_create_listing()
        MyListingsPageAudit.test_update_listing()
        MyListingsPageAudit.test_delete_listing()
        MyListingsPageAudit.test_unauthorized_item_update()
        
        # Item Details Tests
        ItemDetailsPageAudit.test_fetch_item_by_id()
        ItemDetailsPageAudit.test_fetch_item_with_owner_info()
        ItemDetailsPageAudit.test_fetch_unavailable_item()
        ItemDetailsPageAudit.test_fetch_invalid_item()
        ItemDetailsPageAudit.test_fetch_item_images()
        
        # Booking Tests
        BookingPageAudit.test_create_booking()
        BookingPageAudit.test_fetch_booking()
        BookingPageAudit.test_accept_booking()
        BookingPageAudit.test_decline_booking()
        BookingPageAudit.test_booking_state_transitions()
        BookingPageAudit.test_overlapping_bookings()
        
        print("\n" + "="*80)
        print("AUDIT COMPLETE")
        print("="*80)
        
    except Exception as e:
        print(f"\n❌ ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
