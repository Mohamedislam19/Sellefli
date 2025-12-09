"""Item models."""
import uuid

from django.db import models


class Item(models.Model):
	id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
	owner = models.ForeignKey(
		"users.User",
		on_delete=models.CASCADE,
		related_name="items",
	)
	title = models.CharField(max_length=255)
	category = models.CharField(max_length=100)
	description = models.TextField()
	estimated_value = models.DecimalField(max_digits=12, decimal_places=2)
	deposit_amount = models.DecimalField(max_digits=12, decimal_places=2)
	start_date = models.DateField(null=True, blank=True)
	end_date = models.DateField(null=True, blank=True)
	lat = models.FloatField(null=True, blank=True)
	lng = models.FloatField(null=True, blank=True)
	is_available = models.BooleanField(default=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = "items"
		ordering = ["-created_at"]

	def __str__(self) -> str:
		return self.title
