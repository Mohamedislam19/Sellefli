"""Serializers for items and related resources."""
from rest_framework import serializers

from users.models import User
from item_images.serializers import ItemImageSerializer
from .models import Item


class UserPublicSerializer(serializers.ModelSerializer):
	class Meta:
		model = User
		fields = [
			"id",
			"username",
			"avatar_url",
			"rating_sum",
			"rating_count",
		]


class ItemSerializer(serializers.ModelSerializer):
	owner_id = serializers.UUIDField()
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

	def create(self, validated_data):
		owner_id = validated_data.pop("owner_id")
		owner = User.objects.get(pk=owner_id)
		return Item.objects.create(owner=owner, **validated_data)

	def update(self, instance, validated_data):
		# owner_id is write-only; ignore if present during update
		validated_data.pop("owner_id", None)
		return super().update(instance, validated_data)
