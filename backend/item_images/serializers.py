"""Serializers for item images."""
from rest_framework import serializers

from .models import ItemImage


class ItemImageSerializer(serializers.ModelSerializer):
	item_id = serializers.UUIDField(required=False)
	item = serializers.PrimaryKeyRelatedField(read_only=True)

	class Meta:
		model = ItemImage
		fields = [
			"id",
			"item_id",
			"item",
			"image_url",
			"position",
		]

	def validate_position(self, value: int) -> int:
		if value < 1 or value > 3:
			raise serializers.ValidationError("position must be between 1 and 3")
		return value

	def create(self, validated_data):
		item_id = validated_data.pop("item_id", None) or self.context.get("item_id")
		if item_id is None:
			raise serializers.ValidationError({"item_id": "This field is required."})
		from items.models import Item

		item = Item.objects.get(pk=item_id)
		return ItemImage.objects.create(item=item, **validated_data)
