"""Serializers for bookings."""
from rest_framework import serializers

from items.models import Item
from items.serializers import UserPublicSerializer
from users.models import User
from .models import Booking


class ItemMinimalSerializer(serializers.ModelSerializer):
	"""Minimal item info for booking context."""
	
	owner = UserPublicSerializer(read_only=True)
	
	class Meta:
		model = Item
		fields = [
			"id",
			"title",
			"owner",
			"estimated_value",
			"deposit_amount",
		]


class BookingSerializer(serializers.ModelSerializer):
	"""Full booking details with related data."""
	
	owner = UserPublicSerializer(read_only=True)
	borrower = UserPublicSerializer(read_only=True)
	item = ItemMinimalSerializer(read_only=True)
	
	item_id = serializers.UUIDField(write_only=True)
	owner_id = serializers.UUIDField(write_only=True)
	borrower_id = serializers.UUIDField(write_only=True)
	
	class Meta:
		model = Booking
		fields = [
			"id",
			"item",
			"item_id",
			"owner",
			"owner_id",
			"borrower",
			"borrower_id",
			"status",
			"deposit_status",
			"booking_code",
			"start_date",
			"return_by_date",
			"total_cost",
			"created_at",
			"updated_at",
		]
		read_only_fields = [
			"id",
			"item",
			"owner",
			"borrower",
			"booking_code",
			"created_at",
			"updated_at",
		]
	
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
	
	def validate(self, data):
		"""Validate booking creation rules."""
		owner_id = data.get("owner_id")
		borrower_id = data.get("borrower_id")
		item_id = data.get("item_id")
		start_date = data.get("start_date")
		return_by_date = data.get("return_by_date")
		
		# Check if during update (not create)
		if self.instance:
			return data
		
		# Prevent self-booking
		if owner_id == borrower_id:
			raise serializers.ValidationError("Cannot book your own item (owner and borrower cannot be the same)")
		
		# Validate date range
		if start_date and return_by_date and start_date >= return_by_date:
			raise serializers.ValidationError({
				"return_by_date": "return_by_date must be after start_date."
			})
		
		# Check item existence and availability
		try:
			item = Item.objects.get(pk=item_id)
			if not item.is_available:
				raise serializers.ValidationError("Item is not available for booking")
		except Item.DoesNotExist:
			raise serializers.ValidationError("Item not found")
		
		# Check owner and borrower existence
		try:
			User.objects.get(pk=owner_id)
		except User.DoesNotExist:
			raise serializers.ValidationError("Owner not found")
		
		try:
			User.objects.get(pk=borrower_id)
		except User.DoesNotExist:
			raise serializers.ValidationError("Borrower not found")
		
		# Check for duplicate active booking by same borrower on same item
		existing = Booking.objects.filter(
			item_id=item_id,
			borrower_id=borrower_id,
			status__in=['pending', 'accepted', 'active']
		).exists()
		if existing:
			raise serializers.ValidationError("You already have an active booking for this item")
		
		# Check for overlapping bookings on the same item
		overlapping = Booking.objects.filter(
			item_id=item_id,
			status__in=['pending', 'accepted', 'active'],
			start_date__lt=return_by_date,      # Existing starts before new ends
			return_by_date__gt=start_date        # Existing ends after new starts
		).exists()
		if overlapping:
			raise serializers.ValidationError(
				"Item is already booked for the selected dates. Please choose different dates."
			)
		
		return data
	
	def update(self, instance, validated_data):
		# ForeignKey fields are write-only; ignore if present during update
		validated_data.pop("item_id", None)
		validated_data.pop("owner_id", None)
		validated_data.pop("borrower_id", None)
		return super().update(instance, validated_data)
