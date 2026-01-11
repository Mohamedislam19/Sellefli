"""Serializers for items and related resources."""
from rest_framework import serializers

from users.models import User
from users.serializers import UserPublicSerializer
from item_images.serializers import ItemImageSerializer
from .models import Item


class ItemSerializer(serializers.ModelSerializer):
	owner_id = serializers.UUIDField(read_only=True)
	owner = UserPublicSerializer(read_only=True)
	images = ItemImageSerializer(many=True, read_only=True)

	# Accept UI MM/DD/YYYY, plain date, and ISO datetimes the app may send
	_date_input_formats = [
		"%Y-%m-%d",
		"%m/%d/%Y",
		"%Y-%m-%dT%H:%M:%S.%fZ",
		"%Y-%m-%dT%H:%M:%S.%f",
		"%Y-%m-%dT%H:%M:%S%z",
		"%Y-%m-%dT%H:%M:%S",
	]

	start_date = serializers.DateField(
		input_formats=_date_input_formats, required=False, allow_null=True
	)
	end_date = serializers.DateField(
		input_formats=_date_input_formats, required=False, allow_null=True
	)

	class Meta:
		model = Item
		fields = [
			"id",
			"owner_id",
			"owner",
			"title",
			"category",
			"description",
			"estimated_value",
			"deposit_amount",
			"start_date",
			"end_date",
			"lat",
			"lng",
			"is_available",
			"created_at",
			"updated_at",
			"images",
		]

	def validate(self, data):
		"""Validate date ranges and business logic."""
		start_date = data.get("start_date")
		end_date = data.get("end_date")
		
		# Validate date range if both are provided
		if start_date and end_date and start_date >= end_date:
			raise serializers.ValidationError({
				"end_date": "end_date must be after start_date."
			})
		
		# Validate deposit amount doesn't exceed estimated value
		estimated_value = data.get("estimated_value")
		deposit_amount = data.get("deposit_amount")
		if estimated_value and deposit_amount and deposit_amount > estimated_value:
			raise serializers.ValidationError({
				"deposit_amount": "Deposit amount cannot exceed estimated value."
			})
		
		return data

	def create(self, validated_data):
		user = self.context['request'].user
		if not user.is_authenticated:
			raise serializers.ValidationError("Authentication required.")
		return Item.objects.create(owner=user, **validated_data)

	def update(self, instance, validated_data):
		# owner_id is write-only; ignore if present during update
		validated_data.pop("owner_id", None)
		return super().update(instance, validated_data)
