"""Rating models."""
import uuid

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator


class Rating(models.Model):
	"""User ratings after booking completion."""
	
	id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
	booking = models.ForeignKey(
		"bookings.Booking",
		on_delete=models.CASCADE,
		related_name="ratings",
	)
	rater = models.ForeignKey(
		"users.User",
		on_delete=models.CASCADE,
		related_name="ratings_given",
	)
	target_user = models.ForeignKey(
		"users.User",
		on_delete=models.CASCADE,
		related_name="ratings_received",
	)
	stars = models.PositiveSmallIntegerField(
		validators=[MinValueValidator(1), MaxValueValidator(5)]
	)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = "ratings"
		ordering = ["-created_at"]
		unique_together = ("booking", "rater")
		indexes = [
			models.Index(fields=["target_user", "-created_at"]),
			models.Index(fields=["rater", "-created_at"]),
		]

	def __str__(self) -> str:
		return f"{self.rater.username} rated {self.target_user.username}: {self.stars}★"
