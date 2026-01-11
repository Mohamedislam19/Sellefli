"""User models matching Supabase users table schema."""
import uuid

from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models


class UserManager(BaseUserManager):
	"""Manager for User model."""
	
	def create_user(self, username, email=None, phone=None, password=None, **extra_fields):
		"""Create and return a regular user."""
		if not username:
			raise ValueError("The Username field must be set")
		
		email = self.normalize_email(email) if email else None
		user = self.model(username=username, phone=phone, email=email, **extra_fields)
		if password:
			user.set_password(password)
		else:
			user.set_unusable_password()
		user.save(using=self._db)
		return user
	
	def create_superuser(self, username, email=None, phone=None, password=None, **extra_fields):
		"""Create and return a superuser."""
		extra_fields.setdefault("is_staff", True)
		extra_fields.setdefault("is_superuser", True)
		
		if extra_fields.get("is_staff") is not True:
			raise ValueError("Superuser must have is_staff=True.")
		if extra_fields.get("is_superuser") is not True:
			raise ValueError("Superuser must have is_superuser=True.")
		
		return self.create_user(username, email, phone, password, **extra_fields)


class User(AbstractBaseUser, PermissionsMixin):
	id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
	username = models.CharField(max_length=150, unique=True)
	email = models.EmailField(unique=True, null=True, blank=True)
	phone = models.CharField(max_length=20, unique=True, null=True, blank=True)
	avatar_url = models.URLField(blank=True, null=True)
	rating_sum = models.IntegerField(default=0)
	rating_count = models.IntegerField(default=0)
	is_active = models.BooleanField(default=True)
	is_staff = models.BooleanField(default=False)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	objects = UserManager()

	USERNAME_FIELD = "username"
	REQUIRED_FIELDS = ["phone"]

	class Meta:
		db_table = "users"
		ordering = ["-created_at"]

	def __str__(self) -> str:
		return self.username
