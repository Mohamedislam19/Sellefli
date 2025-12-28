

from rest_framework import serializers
from .models import Booking, BookingStatus, DepositStatus

# Import related models for nested serialization
from users.models import User
from items.models import Item




class UserBriefSerializer(serializers.ModelSerializer):
   
    
    class Meta:
        model = User
        # Include brief + required fields for Flutter User.fromJson
        fields = [
            'id', 'username', 'avatar_url', 'phone', 
            'rating_sum', 'rating_count', 'created_at', 'updated_at',
        ]
        read_only_fields = fields


class ItemBriefSerializer(serializers.ModelSerializer):
    
    
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




class BookingListSerializer(serializers.ModelSerializer):
  
  
    
    borrower = UserBriefSerializer(read_only=True)
    owner = UserBriefSerializer(read_only=True)
    item = ItemBriefSerializer(read_only=True)

    item_id = serializers.UUIDField(read_only=True)
    owner_id = serializers.UUIDField(read_only=True)
    borrower_id = serializers.UUIDField(read_only=True)
    
   
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
    
        first_image = obj.item.images.order_by('position').first()
        
        if first_image:
            return first_image.image_url
        return None


class BookingDetailSerializer(serializers.ModelSerializer):

    
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
   
    
    status = serializers.ChoiceField(
        choices=BookingStatus.choices,
        help_text="New status for the booking"
    )
    
    def validate_status(self, value):
        
        return value


class DepositStatusUpdateSerializer(serializers.Serializer):
   
    
    deposit_status = serializers.ChoiceField(
        choices=DepositStatus.choices,
        help_text="New deposit status"
    )

