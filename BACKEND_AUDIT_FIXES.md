# BACKEND AUDIT - CRITICAL FIXES IMPLEMENTATION GUIDE

## Overview
This document provides step-by-step implementation of the 3 critical issues found in the Django backend audit.

---

## FIX #1: Add Booking Overlap Validation ⭐ CRITICAL

### Problem
Users can create overlapping bookings on the same item, allowing double-booking.

```
Example Bug:
Item: Laptop
Booking A: Jan 10-17 ✅ Created
Booking B: Jan 15-22 ✅ Created (overlaps!) BUG!
```

### Solution
Add overlap validation to `BookingSerializer.validate()`

### Implementation

**File:** `backend/bookings/serializers.py`

**Current Code (Lines 58-92):**
```python
def create(self, validated_data):
    item_id = validated_data.pop("item_id")
    owner_id = validated_data.pop("owner_id")
    borrower_id = validated_data.pop("borrower_id")
    
    item = Item.objects.get(pk=item_id)
    owner = User.objects.get(pk=owner_id)
    borrower = User.objects.get(pk=borrower_id)
    
    return Booking.objects.create(
        item=item,
        owner=owner,
        borrower=borrower,
        **validated_data,
    )
```

**Updated Code (Add validation method):**
```python
def validate(self, data):
    """Validate booking doesn't overlap with existing bookings."""
    from rest_framework.serializers import ValidationError
    from django.db.models import Q
    
    # Get item
    try:
        item = Item.objects.get(pk=data['item_id'])
    except Item.DoesNotExist:
        raise ValidationError({"item_id": "Item not found."})
    
    # Get dates
    start_date = data['start_date']
    return_by_date = data['return_by_date']
    
    # Check for overlapping bookings
    # Overlap occurs if: new_start < existing_end AND new_end > existing_start
    overlapping = Booking.objects.filter(
        item=item,
        status__in=[
            Booking.Status.PENDING,
            Booking.Status.ACCEPTED,
            Booking.Status.ACTIVE,
        ],
        start_date__lt=return_by_date,  # Existing starts before new ends
        return_by_date__gt=start_date    # Existing ends after new starts
    ).exists()
    
    if overlapping:
        raise ValidationError(
            "Item is already booked for the selected dates. "
            "Please choose different dates."
        )
    
    return data


def create(self, validated_data):
    item_id = validated_data.pop("item_id")
    owner_id = validated_data.pop("owner_id")
    borrower_id = validated_data.pop("borrower_id")
    
    item = Item.objects.get(pk=item_id)
    owner = User.objects.get(pk=owner_id)
    borrower = User.objects.get(pk=borrower_id)
    
    return Booking.objects.create(
        item=item,
        owner=owner,
        borrower=borrower,
        **validated_data,
    )
```

### Testing

**Test Case 1: Successful Booking**
```
POST /api/bookings/
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "borrower_id": "660e8400-e29b-41d4-a716-446655440001",
  "start_date": "2025-01-10T00:00:00Z",
  "return_by_date": "2025-01-17T00:00:00Z",
  "total_cost": "75.00"
}

Response: 201 Created ✅
```

**Test Case 2: Overlapping Booking (Should Fail)**
```
First booking: Jan 10-17 (created above)

POST /api/bookings/
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",  (same item!)
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "borrower_id": "770e8400-e29b-41d4-a716-446655440006",
  "start_date": "2025-01-15T00:00:00Z",  (overlaps!)
  "return_by_date": "2025-01-22T00:00:00Z",
  "total_cost": "75.00"
}

Response: 400 Bad Request ✅
{
  "non_field_errors": [
    "Item is already booked for the selected dates. Please choose different dates."
  ]
}
```

**Test Case 3: Declined Booking Doesn't Block New Bookings**
```
If previous booking was DECLINED, new booking should be allowed.
Status check uses: ['pending', 'accepted', 'active']
DECLINED is not included, so no conflict ✅
```

---

## FIX #2: Prevent Self-Booking 🔐 CRITICAL

### Problem
Users can book their own items.

```
Example Bug:
User A creates Item X
User A creates Booking for Item X ✅ Created (BUG!)
```

### Solution
Add self-booking validation to `BookingSerializer.validate()`

### Implementation

**File:** `backend/bookings/serializers.py`

**Add to `validate()` method (after overlap check):**
```python
def validate(self, data):
    """Validate booking doesn't overlap and isn't self-booking."""
    from rest_framework.serializers import ValidationError
    
    # ... (overlap validation code above) ...
    
    # Prevent self-booking
    if str(data['borrower_id']) == str(item.owner_id):
        raise ValidationError(
            {"borrower_id": "Cannot book your own item."}
        )
    
    return data
```

**Complete validate() method:**
```python
def validate(self, data):
    """Validate booking conditions."""
    from rest_framework.serializers import ValidationError
    
    # Get item
    try:
        item = Item.objects.get(pk=data['item_id'])
    except Item.DoesNotExist:
        raise ValidationError({"item_id": "Item not found."})
    
    # Check overlap
    start_date = data['start_date']
    return_by_date = data['return_by_date']
    
    overlapping = Booking.objects.filter(
        item=item,
        status__in=[
            Booking.Status.PENDING,
            Booking.Status.ACCEPTED,
            Booking.Status.ACTIVE,
        ],
        start_date__lt=return_by_date,
        return_by_date__gt=start_date
    ).exists()
    
    if overlapping:
        raise ValidationError(
            "Item is already booked for the selected dates."
        )
    
    # Check self-booking
    if str(data['borrower_id']) == str(item.owner_id):
        raise ValidationError(
            {"borrower_id": "Cannot book your own item."}
        )
    
    return data
```

### Testing

**Test Case 1: Self-Booking Attempt (Should Fail)**
```
User A: 550e8400-e29b-41d4-a716-446655440000
Item X (owner=User A): 750e8400-e29b-41d4-a716-446655440002

POST /api/bookings/
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "borrower_id": "550e8400-e29b-41d4-a716-446655440000",  (same as owner!)
  "start_date": "2025-01-10T00:00:00Z",
  "return_by_date": "2025-01-17T00:00:00Z",
  "total_cost": "75.00"
}

Response: 400 Bad Request ✅
{
  "borrower_id": "Cannot book your own item."
}
```

**Test Case 2: Valid Booking (Different Users)**
```
User A (owner): 550e8400-e29b-41d4-a716-446655440000
User B (borrower): 660e8400-e29b-41d4-a716-446655440001
Item X: 750e8400-e29b-41d4-a716-446655440002

POST /api/bookings/
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "borrower_id": "660e8400-e29b-41d4-a716-446655440001",
  "start_date": "2025-01-10T00:00:00Z",
  "return_by_date": "2025-01-17T00:00:00Z",
  "total_cost": "75.00"
}

Response: 201 Created ✅
```

---

## FIX #3: Check Item Availability 📦 CRITICAL

### Problem
Users can book items marked as unavailable.

```
Example Bug:
Item marked: is_available = False
Booking created anyway ✅ BUG!
```

### Solution
Add availability check to `BookingSerializer.validate()`

### Implementation

**File:** `backend/bookings/serializers.py`

**Add to `validate()` method (after self-booking check):**
```python
def validate(self, data):
    """Validate booking conditions."""
    from rest_framework.serializers import ValidationError
    
    # ... (previous checks) ...
    
    # Check item availability
    if not item.is_available:
        raise ValidationError(
            {"item_id": "Item is not available for booking."}
        )
    
    return data
```

**Complete validate() method:**
```python
def validate(self, data):
    """Validate booking conditions."""
    from rest_framework.serializers import ValidationError
    
    # Get item
    try:
        item = Item.objects.get(pk=data['item_id'])
    except Item.DoesNotExist:
        raise ValidationError({"item_id": "Item not found."})
    
    # Check availability
    if not item.is_available:
        raise ValidationError(
            {"item_id": "Item is not available for booking."}
        )
    
    # Check overlap
    start_date = data['start_date']
    return_by_date = data['return_by_date']
    
    overlapping = Booking.objects.filter(
        item=item,
        status__in=[
            Booking.Status.PENDING,
            Booking.Status.ACCEPTED,
            Booking.Status.ACTIVE,
        ],
        start_date__lt=return_by_date,
        return_by_date__gt=start_date
    ).exists()
    
    if overlapping:
        raise ValidationError(
            "Item is already booked for the selected dates."
        )
    
    # Check self-booking
    if str(data['borrower_id']) == str(item.owner_id):
        raise ValidationError(
            {"borrower_id": "Cannot book your own item."}
        )
    
    return data
```

### Testing

**Test Case 1: Unavailable Item (Should Fail)**
```
Item X: is_available = False

POST /api/bookings/
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "borrower_id": "660e8400-e29b-41d4-a716-446655440001",
  "start_date": "2025-01-10T00:00:00Z",
  "return_by_date": "2025-01-17T00:00:00Z",
  "total_cost": "75.00"
}

Response: 400 Bad Request ✅
{
  "item_id": "Item is not available for booking."
}
```

**Test Case 2: Available Item (Should Succeed)**
```
Item X: is_available = True

POST /api/bookings/
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",
  "owner_id": "550e8400-e29b-41d4-a716-446655440000",
  "borrower_id": "660e8400-e29b-41d4-a716-446655440001",
  "start_date": "2025-01-10T00:00:00Z",
  "return_by_date": "2025-01-17T00:00:00Z",
  "total_cost": "75.00"
}

Response: 201 Created ✅
```

---

## COMPLETE FIXED validate() METHOD

Here's the complete `BookingSerializer.validate()` method combining all 3 fixes:

**File:** `backend/bookings/serializers.py`

```python
def validate(self, data):
    """
    Validate booking conditions:
    1. Item exists and is available
    2. No overlapping bookings
    3. User cannot book own item
    """
    from rest_framework.serializers import ValidationError
    
    # 1. Get item and check existence
    try:
        item = Item.objects.get(pk=data['item_id'])
    except Item.DoesNotExist:
        raise ValidationError({"item_id": "Item not found."})
    
    # 2. Check item availability
    if not item.is_available:
        raise ValidationError(
            {"item_id": "Item is not available for booking."}
        )
    
    # 3. Check for overlapping bookings
    start_date = data['start_date']
    return_by_date = data['return_by_date']
    
    overlapping = Booking.objects.filter(
        item=item,
        status__in=[
            Booking.Status.PENDING,
            Booking.Status.ACCEPTED,
            Booking.Status.ACTIVE,
        ],
        start_date__lt=return_by_date,      # Existing starts before new ends
        return_by_date__gt=start_date        # Existing ends after new starts
    ).exists()
    
    if overlapping:
        raise ValidationError(
            "Item is already booked for the selected dates. "
            "Please choose different dates."
        )
    
    # 4. Prevent self-booking
    if str(data['borrower_id']) == str(item.owner_id):
        raise ValidationError(
            {"borrower_id": "Cannot book your own item."}
        )
    
    return data
```

---

## IMPLEMENTATION CHECKLIST

- [ ] Open `backend/bookings/serializers.py`
- [ ] Locate the `BookingSerializer` class
- [ ] Find or create the `validate()` method
- [ ] Add all 3 validation checks (availability, overlap, self-booking)
- [ ] Test with provided test cases
- [ ] Run Django test suite: `python manage.py test bookings`
- [ ] Verify in Postman/API client with test requests
- [ ] Deploy to production

---

## ADDITIONAL RECOMMENDATIONS (Non-Critical)

### Fix #4: JWT-Based User Identification

**File:** `backend/users/views.py`

**Current Code (Lines 28-45):**
```python
@action(detail=False, methods=["get"], url_path="me")
def me(self, request):
    """Get current authenticated user profile.
    
    In a real scenario, this would use request.user from JWT auth.
    For now, returns user if id is in query params.
    """
    user_id = request.query_params.get("id")
    if not user_id:
        return Response(
            {"detail": "User ID required (use ?id=<user_id> or JWT auth)"},
            status=status.HTTP_400_BAD_REQUEST,
        )
    
    try:
        user = User.objects.get(pk=user_id)
        serializer = self.get_serializer(user)
        return Response(serializer.data)
    except User.DoesNotExist:
        return Response(
            {"detail": "User not found"},
            status=status.HTTP_404_NOT_FOUND,
        )
```

**Improved Code (Uses JWT):**
```python
@action(detail=False, methods=["get"], url_path="me")
def me(self, request):
    """Get current authenticated user profile from JWT token."""
    
    # Check if user is authenticated via JWT
    if not request.user or not request.user.is_authenticated:
        return Response(
            {"detail": "Not authenticated. Please provide a valid JWT token."},
            status=status.HTTP_401_UNAUTHORIZED,
        )
    
    # Get user from JWT claims (set by authentication middleware)
    try:
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
    except Exception as e:
        return Response(
            {"detail": str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )
```

**Usage After Fix:**
```
Old way:
  GET /api/users/me?id=550e8400... (requires manual ID)

New way:
  GET /api/users/me/
  Authorization: Bearer <JWT_TOKEN>  (extracts ID from token)
```

---

### Fix #5: Add Item Review Aggregation

**File:** `backend/items/views.py`

**Add this action to `ItemViewSet` class:**
```python
@action(detail=True, methods=['get'], url_path='reviews')
def reviews(self, request, pk=None):
    """Get item reviews and average rating."""
    from django.db.models import Avg
    from ratings.serializers import RatingSerializer
    from ratings.models import Rating
    
    item = self.get_object()
    
    # Get all ratings for bookings of this item
    ratings = Rating.objects.filter(
        booking__item=item
    ).select_related('rater')
    
    # Calculate average
    avg_stats = ratings.aggregate(
        average_rating=Avg('stars'),
        total_reviews=models.Count('id')
    )
    
    return Response({
        'item_id': str(item.id),
        'average_rating': avg_stats['average_rating'] or 0,
        'total_reviews': avg_stats['total_reviews'] or 0,
        'reviews': RatingSerializer(ratings, many=True).data
    })
```

**Usage:**
```
GET /api/items/750e8400-e29b-41d4-a716-446655440002/reviews/

Response:
{
  "item_id": "750e8400-e29b-41d4-a716-446655440002",
  "average_rating": 4.5,
  "total_reviews": 10,
  "reviews": [
    {
      "id": "950e8400...",
      "booking_id": "650e8400...",
      "rater": {...},
      "stars": 5,
      "created_at": "2024-12-28T10:00:00Z"
    },
    ...
  ]
}
```

---

## VERIFICATION COMMANDS

After implementing fixes, run these commands to verify:

```bash
# Run tests
cd backend
python manage.py test bookings.tests

# Run specific test
python manage.py test bookings.tests.BookingValidationTests

# Check migrations
python manage.py migrate --check

# Validate schema
python manage.py dbshell

# Run server
python manage.py runserver
```

---

## DEPLOYMENT NOTES

### Before Merging to Production

1. Create feature branch:
   ```bash
   git checkout -b fix/booking-validations
   ```

2. Apply all fixes

3. Run full test suite:
   ```bash
   python manage.py test
   ```

4. Test with Postman/curl using provided test cases

5. Create pull request

6. Get code review approval

7. Merge to main

8. Deploy to production

---

## ROLLBACK PLAN

If issues occur in production:

```bash
# Rollback database migration (if any)
python manage.py migrate bookings 0001_initial

# Revert code changes
git revert <commit-hash>

# Restart Django server
systemctl restart django
```

---

**Time to Fix:** ~35 minutes  
**Risk Level:** Low (additive validations only)  
**Backward Compatibility:** ✅ Yes (only rejects invalid bookings)
