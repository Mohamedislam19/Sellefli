"""Serializers for users."""
from rest_framework import serializers

from .models import User


class UserSerializer(serializers.ModelSerializer):
	"""Full user profile information."""
	
	class Meta:
		model = User
		fields = [
			"id",
			"username",
			"email",
			"phone",
			"avatar_url",
			"rating_sum",
			"rating_count",
			"created_at",
			"updated_at",
		]
		read_only_fields = [
			"id",
			"rating_sum",
			"rating_count",
			"created_at",
			"updated_at",
		]

	def validate_username(self, value):
		"""Ensure username is unique (except when updating own profile)."""
		instance = self.instance
		if instance and instance.username == value:
			# Allow same username during update
			return value
		
		if User.objects.filter(username=value).exists():
			raise serializers.ValidationError("Username already exists.")
		return value

	def validate_phone(self, value):
		"""Ensure phone is unique (except when updating own profile)."""
		instance = self.instance
		if instance and instance.phone == value:
			# Allow same phone during update
			return value
		
		if User.objects.filter(phone=value).exists():
			raise serializers.ValidationError("Phone number already in use.")
		return value


class UserPublicSerializer(serializers.ModelSerializer):
	"""Public user profile (limited info)."""
	
	class Meta:
		model = User
		fields = [
			"id",
			"username",
			"avatar_url",
			"rating_sum",
			"rating_count",
		]


class UserLoginSerializer(serializers.Serializer):
    """Serializer for user login."""
    
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True)


class UserRegistrationSerializer(serializers.Serializer):
    """Serializer for user registration."""
    
    email = serializers.EmailField(required=True)
    password = serializers.CharField(write_only=True, required=True, min_length=6)
    username = serializers.CharField(required=True)
    phone = serializers.CharField(required=True)

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email is already registered.")
        return value

    def validate_phone(self, value):
        if User.objects.filter(phone=value).exists():
            raise serializers.ValidationError("This phone number is already registered.")
        return value

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("This username is taken.")
        return value
