"""Booking models."""
import uuid

from django.db import models


class Booking(models.Model):
	"""Booking request and lifecycle tracking."""
	
	class Status(models.TextChoices):
		PENDING = "pending", "Pending"
		ACCEPTED = "accepted", "Accepted"
		ACTIVE = "active", "Active"
		COMPLETED = "completed", "Completed"
		DECLINED = "declined", "Declined"
		CLOSED = "closed", "Closed"
	
	class DepositStatus(models.TextChoices):
		NONE = "none", "None"
		RECEIVED = "received", "Received"
		RETURNED = "returned", "Returned"
		KEPT = "kept", "Kept"
	
	id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
	item = models.ForeignKey(
		"items.Item",
		on_delete=models.CASCADE,
		related_name="bookings",
	)
	owner = models.ForeignKey(
		"users.User",
		on_delete=models.CASCADE,
		related_name="bookings_as_owner",
	)
	borrower = models.ForeignKey(
		"users.User",
		on_delete=models.CASCADE,
		related_name="bookings_as_borrower",
	)
	status = models.CharField(
		max_length=20,
		choices=Status.choices,
		default=Status.PENDING,
	)
	deposit_status = models.CharField(
		max_length=20,
		choices=DepositStatus.choices,
		default=DepositStatus.NONE,
	)
	booking_code = models.CharField(max_length=50, blank=True, null=True)
	start_date = models.DateTimeField()
	return_by_date = models.DateTimeField()
	total_cost = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
	created_at = models.DateTimeField(auto_now_add=True)
	updated_at = models.DateTimeField(auto_now=True)

	class Meta:
		db_table = "bookings"
		ordering = ["-created_at"]
		indexes = [
			models.Index(fields=["owner", "-created_at"]),
			models.Index(fields=["borrower", "-created_at"]),
			models.Index(fields=["status"]),
		]

	def __str__(self) -> str:
		return f"Booking {self.id} - {self.status}"
