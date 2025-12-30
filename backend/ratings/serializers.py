"""Serializers for ratings."""
from rest_framework import serializers

from bookings.models import Booking
from users.models import User
from .models import Rating


class RatingSerializer(serializers.ModelSerializer):
	"""Rating submission and display."""
	
	rater_id = serializers.UUIDField(write_only=True)
	target_user_id = serializers.UUIDField(write_only=True)
	booking_id = serializers.UUIDField(write_only=True)
	
	# Read-only nested details
	rater = serializers.SerializerMethodField(read_only=True)
	target_user = serializers.SerializerMethodField(read_only=True)
	
	class Meta:
		model = Rating
		fields = [
			"id",
			"booking_id",
			"rater_id",
			"rater",
			"target_user_id",
			"target_user",
			"stars",
			"created_at",
		]
		read_only_fields = [
			"id",
			"rater",
			"target_user",
			"created_at",
		]
	
	def get_rater(self, obj):
		return {
			"id": str(obj.rater.id),
			"username": obj.rater.username,
			"avatar_url": obj.rater.avatar_url,
		}
	
	def get_target_user(self, obj):
		return {
			"id": str(obj.target_user.id),
			"username": obj.target_user.username,
			"avatar_url": obj.target_user.avatar_url,
			"rating_sum": obj.target_user.rating_sum,
			"rating_count": obj.target_user.rating_count,
		}

	def validate(self, data):
		"""Validate rating creation rules."""
		booking_id = data.get("booking_id")
		rater_id = data.get("rater_id")
		target_user_id = data.get("target_user_id")
		stars = data.get("stars")
		
		# Validate stars value
		if stars and (stars < 1 or stars > 5):
			raise serializers.ValidationError({
				"stars": "Stars must be between 1 and 5."
			})
		
		# Check if booking exists
		try:
			booking = Booking.objects.get(pk=booking_id)
		except Booking.DoesNotExist:
			raise serializers.ValidationError("Booking not found.")
		
		# Check if rater exists
		try:
			User.objects.get(pk=rater_id)
		except User.DoesNotExist:
			raise serializers.ValidationError("Rater not found.")
		
		# Check if target user exists
		try:
			User.objects.get(pk=target_user_id)
		except User.DoesNotExist:
			raise serializers.ValidationError("Target user not found.")
		
		# Prevent self-rating
		if rater_id == target_user_id:
			raise serializers.ValidationError("Cannot rate yourself.")
		
		# Check if rating already exists for this booking and rater
		if Rating.objects.filter(
			booking_id=booking_id,
			rater_id=rater_id
		).exists():
			raise serializers.ValidationError("You have already rated for this booking.")
		
		return data
	
	def create(self, validated_data):
		booking_id = validated_data.pop("booking_id")
		rater_id = validated_data.pop("rater_id")
		target_user_id = validated_data.pop("target_user_id")
		
		booking = Booking.objects.get(pk=booking_id)
		rater = User.objects.get(pk=rater_id)
		target_user = User.objects.get(pk=target_user_id)
		
		# Update target user's rating sum
		rating = Rating.objects.create(
			booking=booking,
			rater=rater,
			target_user=target_user,
			**validated_data,
		)
		
		# Update target user's rating stats
		target_user.rating_sum += rating.stars
		target_user.rating_count += 1
		target_user.save(update_fields=['rating_sum', 'rating_count'])
		
		return rating
