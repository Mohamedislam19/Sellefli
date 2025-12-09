"""User models matching Supabase users table schema."""
import uuid

from django.db import models


class User(models.Model):
	id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
	username = models.CharField(max_length=150, unique=True)
	phone = models.CharField(max_length=20, unique=True)
	avatar_url = models.URLField(blank=True, null=True)
	rating_sum = models.IntegerField(default=0)
	rating_count = models.IntegerField(default=0)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = "users"
		ordering = ["-created_at"]

	def __str__(self) -> str:
		return self.username
