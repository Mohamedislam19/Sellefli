"""DRF views for users."""
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import User
from .serializers import UserSerializer, UserPublicSerializer


class UserViewSet(viewsets.ModelViewSet):
	"""User profile CRUD operations."""
	
	queryset = User.objects.all()
	serializer_class = UserSerializer
	permission_classes = [permissions.IsAuthenticated]
	
	def get_serializer_class(self):
		"""Use public serializer for list view."""
		if self.action == "list":
			return UserPublicSerializer
		return UserSerializer
	
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
	
	@action(detail=True, methods=["patch"], url_path="update-profile")
	def update_profile(self, request, pk=None):
		"""Update user profile information."""
		user = self.get_object()
		serializer = self.get_serializer(user, data=request.data, partial=True)
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data)
	
	@action(detail=True, methods=["post"], url_path="upload-avatar")
	def upload_avatar(self, request, pk=None):
		"""Upload user avatar image.
		
		POST /api/users/{userId}/upload-avatar/
		Expects multipart form with 'avatar' file field.
		"""
		user = self.get_object()
		
		# Get the avatar file from request
		avatar_file = request.FILES.get("avatar")
		if not avatar_file:
			return Response(
				{"detail": "Avatar file required (field name: 'avatar')"},
				status=status.HTTP_400_BAD_REQUEST,
			)
		
		try:
			# For now, just save the file reference
			# In production, you'd upload to cloud storage like S3 or Cloudinary
			# and return the public URL
			
			# Update user with avatar URL
			# This is a placeholder - in production integrate with actual file storage
			user.avatar_url = str(avatar_file)
			user.save()
			
			serializer = self.get_serializer(user)
			return Response(serializer.data)
		except Exception as e:
			return Response(
				{"detail": f"Failed to upload avatar: {str(e)}"},
				status=status.HTTP_500_INTERNAL_SERVER_ERROR,
			)
	
	@action(detail=True, methods=["get"], url_path="average-rating")
	def average_rating(self, request, pk=None):
		"""Get user's average rating."""
		user = self.get_object()
		avg_rating = user.rating_sum / user.rating_count if user.rating_count > 0 else 0
		return Response({
			"user_id": str(user.id),
			"average_rating": avg_rating,
			"rating_sum": user.rating_sum,
			"rating_count": user.rating_count,
		})
