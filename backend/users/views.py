"""DRF views for users."""
from django.conf import settings
from supabase import create_client, Client
from rest_framework import permissions, status, viewsets, views
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import User
from .serializers import UserSerializer, UserPublicSerializer, UserRegistrationSerializer, UserLoginSerializer


class LoginView(views.APIView):
    """
    Login a user via Supabase Auth and return tokens.
    Authentication is delegated to Supabase, but proxied by Django.
    """
    permission_classes = [permissions.AllowAny]
    serializer_class = UserLoginSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']

        # Init Supabase Client
        url = settings.SUPABASE_URL
        key = settings.SUPABASE_SERVICE_ROLE_KEY # Ideally use ANON key for client-side ops proxying, but SERVICE is okay if careful 
        # Actually for sign_in, we should use the CLIENT/ANON key usually, but here request is server-side.
        # However, supabase-py client handles this.
        
        if not url or not key:
             return Response({"error": "Configuration error"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        supabase: Client = create_client(url, key)

        try:
            # Login
            response = supabase.auth.sign_in_with_password({
                "email": email,
                "password": password
            })
            
            session = response.session
            user = response.user
            
            if not session or not user:
                return Response({"error": "Login failed"}, status=status.HTTP_401_UNAUTHORIZED)
            
            # Fetch profile to return
            try:
                db_user = User.objects.get(id=user.id)
                user_data = UserSerializer(db_user).data
            except User.DoesNotExist:
                 user_data = None

            return Response({
                "access_token": session.access_token,
                "refresh_token": session.refresh_token,
                "user": user_data,
                "expires_at": session.expires_at,
                "expires_in": session.expires_in
            })

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_401_UNAUTHORIZED)


class RegisterView(views.APIView):
    """
    Register a new user in Supabase Auth and Django DB.
    """
    permission_classes = [permissions.AllowAny]
    serializer_class = UserRegistrationSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email']
        password = serializer.validated_data['password']
        username = serializer.validated_data['username']
        phone = serializer.validated_data['phone']

        # Init Supabase Admin Client
        url = settings.SUPABASE_URL
        key = settings.SUPABASE_SERVICE_ROLE_KEY
        
        if not url or not key:
            return Response(
                {"error": "Server configuration error: Missing Supabase credentials."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        supabase: Client = create_client(url, key)

        # 1. Create User in Supabase Auth
        try:
            # Create user with admin privileges (bypasses email confirm if desired, or sends it)
            # We auto-confirm here to mimic immediate login success unless required otherwise.
            attributes = {
                "email": email,
                "password": password,
                "email_confirm": True,
                "user_metadata": {
                    "username": username,
                    "phone": phone
                }
            }
            response = supabase.auth.admin.create_user(attributes)
            auth_user = response.user
            
            if not auth_user or not auth_user.id:
                 return Response({"error": "Failed to create user in authentication provider."}, status=status.HTTP_400_BAD_REQUEST)
                 
            user_id = auth_user.id

        except Exception as e:
            # Handle Supabase errors (e.g. rate limit, invalid pass, etc)
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        # 2. Create User in Django DB
        try:
            user = User.objects.create(
                id=user_id,
                email=email,
                username=username,
                phone=phone
            )
        except Exception as e:
            # ROLLBACK: Delete the just-created auth user
            try:
                supabase.auth.admin.delete_user(user_id)
            except Exception as delete_error:
                # Log this critical failure
                print(f"CRITICAL: Failed to rollback user {user_id}: {delete_error}")
                
            return Response(
                {"error": "Failed to create user profile. Please try again."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        # Return success with user data
        return Response(
            UserSerializer(user).data,
            status=status.HTTP_201_CREATED
        )


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
	
	@action(detail=False, methods=["get", "patch"], url_path="me")
	def me(self, request):
		"""Get or update current authenticated user profile."""
		user = request.user
		if request.method == "GET":
			serializer = self.get_serializer(user)
			return Response(serializer.data)
		elif request.method == "PATCH":
			serializer = self.get_serializer(user, data=request.data, partial=True)
			serializer.is_valid(raise_exception=True)
			serializer.save()
			return Response(serializer.data)
	
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
