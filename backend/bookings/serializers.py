"""
=============================================================================
BOOKING SERIALIZERS - Django REST Framework Serializers
=============================================================================

This file defines SERIALIZERS for the Booking model.

WHAT IS A SERIALIZER?
---------------------
A serializer converts complex data (like Django model instances) into simple
Python data types that can be rendered into JSON (and vice versa).

Think of it as a translator:
    Python Object (Booking model) ←→ JSON (what Flutter receives/sends)

WHY DO WE NEED SERIALIZERS?
---------------------------
1. VALIDATION: Check incoming data is valid before saving to database
2. CONVERSION: Convert model objects to JSON for API responses
3. NESTED DATA: Include related objects (like user info, item details)
4. CONTROL: Choose which fields to expose (hide sensitive data)

TYPES OF SERIALIZERS:
---------------------
1. ModelSerializer: Automatically creates fields from a Django model
2. Serializer: Manual field definitions (more control, more code)
3. ReadOnlySerializer: For display only (no create/update)

HOW THIS CONNECTS TO FLUTTER:
-----------------------------
When your Flutter app calls GET /api/bookings/123/, Django:
1. Fetches the Booking from database
2. Passes it through a serializer
3. Returns JSON that matches your Flutter Booking.fromJson() expectations

=============================================================================
"""

from rest_framework import serializers
from .models import Booking, BookingStatus, DepositStatus

# Import related models for nested serialization
from users.models import User
from items.models import Item


# =============================================================================
# NESTED SERIALIZERS (for including related data in responses)
# =============================================================================

class UserBriefSerializer(serializers.ModelSerializer):
    """
    A lightweight serializer for User data.
    
    Used when we want to include user info inside a booking response,
    but we don't need ALL user fields - just the essential ones.
    
    This matches what Flutter expects in the 'borrower' and 'owner' fields:
    - id: UUID of the user
    - username: Display name
    - avatar_url: Profile picture URL
    - phone: Contact number (for owners to contact borrowers)
    """
    
    class Meta:
        model = User
        # Include brief + required fields for Flutter User.fromJson
        fields = [
            'id', 'username', 'avatar_url', 'phone', 
            'rating_sum', 'rating_count', 'created_at', 'updated_at',
        ]
        read_only_fields = fields


class ItemBriefSerializer(serializers.ModelSerializer):
    """
    A lightweight serializer for Item data.
    
    Used when we want to include item info inside a booking response.
    Includes only the fields needed for booking displays.
    
    This matches what Flutter expects in the 'item' field:
    - id: UUID of the item
    - title: Item name
    - deposit_amount: Required deposit (shown in booking details)
    """
    
    # Expose owner_id raw FK as UUID
    owner_id = serializers.UUIDField(read_only=True)

    class Meta:
        model = Item
        # Provide minimal set required by Flutter Item.fromJson
        fields = [
            'id', 'owner_id', 'title', 'category',
            'deposit_amount', 'estimated_value', 'is_available',
            'created_at', 'updated_at',
        ]
        read_only_fields = fields


# =============================================================================
# MAIN BOOKING SERIALIZERS
# =============================================================================

class BookingListSerializer(serializers.ModelSerializer):
    """
    Serializer for LIST views (showing multiple bookings).
    
    Used by: GET /api/bookings/incoming/ and GET /api/bookings/my-requests/
    
    This is optimized for list displays:
    - Includes essential booking info
    - Includes brief user info (borrower OR owner depending on view)
    - Includes item title and first image
    - Does NOT include full nested objects (to keep response size small)
    
    The Flutter RequestsOrdersPage uses this data to display booking cards.
    """
    
    # -------------------------------------------------------------------------
    # NESTED FIELDS
    # -------------------------------------------------------------------------
    # These fields pull data from related models.
    # read_only=True means they come from the database, not from user input.
    # -------------------------------------------------------------------------
    
    borrower = UserBriefSerializer(read_only=True)
    owner = UserBriefSerializer(read_only=True)
    item = ItemBriefSerializer(read_only=True)

    # Raw UUIDs for ForeignKeys (match Flutter model JSON keys)
    # Django automatically provides <field>_id attributes for FK fields.
    item_id = serializers.UUIDField(read_only=True)
    owner_id = serializers.UUIDField(read_only=True)
    borrower_id = serializers.UUIDField(read_only=True)
    
    # -------------------------------------------------------------------------
    # CUSTOM FIELDS
    # -------------------------------------------------------------------------
    # SerializerMethodField: Computed fields that run a method to get their value
    # These don't exist on the model but are calculated on-the-fly
    # -------------------------------------------------------------------------
    
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Booking
        fields = [
            # Booking identification
            'id',
            'booking_code',

            # Foreign key raw IDs (for Flutter's Booking.fromJson)
            'item_id',
            'owner_id',
            'borrower_id',
            
            # Status info
            'status',
            'deposit_status',
            
            # Dates
            'start_date',
            'return_by_date',
            
            # Cost
            'total_cost',
            
            # Related objects (nested)
            'item',
            'borrower',
            'owner',
            
            # Computed fields
            'image_url',
            
            # Timestamps
            'created_at',
            'updated_at',
        ]
    
    def get_image_url(self, obj: Booking) -> str | None:
        """
        Get the first image URL for the booking's item.
        
        This method is called for each booking to fetch the primary image.
        It matches the Flutter repository's behavior of getting the first image.
        
        Args:
            obj: The Booking instance being serialized
            
        Returns:
            The URL of the first image, or None if no images exist
        """
        # Get the first image for this item (ordered by position)
        # This uses the related_name from ItemImage model
        first_image = obj.item.images.order_by('position').first()
        
        if first_image:
            return first_image.image_url
        return None


class BookingDetailSerializer(serializers.ModelSerializer):
    """
    Serializer for DETAIL views (showing a single booking with full info).
    
    Used by: GET /api/bookings/<id>/
    
    This includes everything needed for the BookingDetailPage in Flutter:
    - Full booking information
    - Complete borrower and owner details
    - Item details with deposit amount
    - First image URL
    
    This matches the data structure from Flutter's getBookingDetails() method
    in booking_repository.dart.
    """
    
    # Nested serializers for related objects
    borrower = UserBriefSerializer(read_only=True)
    owner = UserBriefSerializer(read_only=True)
    item = ItemBriefSerializer(read_only=True)

    # Raw UUIDs for ForeignKeys
    item_id = serializers.UUIDField(read_only=True)
    owner_id = serializers.UUIDField(read_only=True)
    borrower_id = serializers.UUIDField(read_only=True)
    
    # Computed field for image
    image_url = serializers.SerializerMethodField()
    
    class Meta:
        model = Booking
        fields = [
            # All booking fields
            'id',
            'booking_code',

            # Foreign key raw IDs
            'item_id',
            'owner_id',
            'borrower_id',
            'status',
            'deposit_status',
            'start_date',
            'return_by_date',
            'total_cost',
            'created_at',
            'updated_at',
            
            # Related objects
            'item',
            'borrower',
            'owner',
            
            # Computed
            'image_url',
        ]
    
    def get_image_url(self, obj: Booking) -> str | None:
        """Get the first image URL for the item."""
        first_image = obj.item.images.order_by('position').first()
        return first_image.image_url if first_image else None


class BookingCreateSerializer(serializers.ModelSerializer):
    """
    Serializer for CREATING new bookings.
    
    Used by: POST /api/bookings/
    
    When a borrower requests to borrow an item, the Flutter app sends:
    - item_id: Which item they want
    - borrower_id: Who is borrowing (current user)
    - owner_id: Who owns the item
    - start_date: When they want to start
    - return_by_date: When they'll return it
    - total_cost: Calculated rental cost
    
    The serializer:
    1. Validates all the data
    2. Sets default status to 'pending'
    3. Creates the booking in the database
    4. Returns the created booking
    """
    
    # -------------------------------------------------------------------------
    # INPUT FIELDS (for creating bookings)
    # -------------------------------------------------------------------------
    # PrimaryKeyRelatedField: Accept a UUID, look up the related object
    # queryset: Which objects are valid (all items, all users)
    # write_only=True: Accept this field on input, but don't include in output
    # -------------------------------------------------------------------------
    
    item_id = serializers.PrimaryKeyRelatedField(
        queryset=Item.objects.all(),
        source='item',                        # Maps to the 'item' field on model
        write_only=True,
        help_text="UUID of the item to book"
    )
    
    owner_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all(),
        source='owner',
        write_only=True,
        help_text="UUID of the item owner"
    )
    
    borrower_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all(),
        source='borrower',
        write_only=True,
        help_text="UUID of the borrower (usually current user)"
    )
    
    class Meta:
        model = Booking
        fields = [
            # Input fields (for creation)
            'item_id',
            'owner_id',
            'borrower_id',
            'start_date',
            'return_by_date',
            'total_cost',
            
            # Output fields (returned after creation)
            'id',
            'status',
            'deposit_status',
            'booking_code',
            'created_at',
        ]
        # These are set automatically, not by user input
        read_only_fields = ['id', 'status', 'deposit_status', 'booking_code', 'created_at']
    
    def validate(self, attrs):
        """
        Custom validation for booking creation.
        
        This method is called after individual field validation.
        Use it to check relationships between fields.
        
        Args:
            attrs: Dictionary of validated field values
            
        Returns:
            The validated attrs (possibly modified)
            
        Raises:
            ValidationError: If validation fails
        """
        # Check that return date is after start date
        if attrs['return_by_date'] <= attrs['start_date']:
            raise serializers.ValidationError({
                'return_by_date': 'Return date must be after start date.'
            })
        
        # Check that borrower is not the owner (can't borrow your own item)
        if attrs['borrower'] == attrs['owner']:
            raise serializers.ValidationError({
                'borrower_id': 'You cannot borrow your own item.'
            })
        
        # Check that the item belongs to the specified owner
        if attrs['item'].owner != attrs['owner']:
            raise serializers.ValidationError({
                'owner_id': 'The specified owner does not own this item.'
            })
        
        # Check that the item is available
        if not attrs['item'].is_available:
            raise serializers.ValidationError({
                'item_id': 'This item is not currently available for booking.'
            })
        
        return attrs


class BookingStatusUpdateSerializer(serializers.Serializer):
    """
    Serializer for updating booking status.
    
    Used by: PATCH /api/bookings/<id>/status/
    
    This is a simple serializer (not ModelSerializer) because we only
    need to accept and validate the new status value.
    
    Actions that use this:
    - Accept booking: status = 'accepted'
    - Decline booking: status = 'declined'
    - Activate booking: status = 'active'
    - Complete booking: status = 'completed'
    - Close booking: status = 'closed'
    """
    
    status = serializers.ChoiceField(
        choices=BookingStatus.choices,
        help_text="New status for the booking"
    )
    
    def validate_status(self, value):
        """
        Validate the status transition.
        
        Not all status changes are valid. For example:
        - Can't go from 'completed' back to 'pending'
        - Can't 'accept' an already declined booking
        
        Args:
            value: The new status value
            
        Returns:
            The validated status value
        """
        # The view will handle checking if the transition is valid
        # based on the current status
        return value


class DepositStatusUpdateSerializer(serializers.Serializer):
    """
    Serializer for updating deposit status.
    
    Used by: PATCH /api/bookings/<id>/deposit/
    
    Actions that use this:
    - Mark deposit received: deposit_status = 'received'
    - Mark deposit returned: deposit_status = 'returned'
    - Keep deposit: deposit_status = 'kept'
    """
    
    deposit_status = serializers.ChoiceField(
        choices=DepositStatus.choices,
        help_text="New deposit status"
    )

