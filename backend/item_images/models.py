"""Item image models."""
import uuid

from django.db import models


class ItemImage(models.Model):
	id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
	item = models.ForeignKey(
		"items.Item",
		on_delete=models.CASCADE,
		related_name="images",
	)
	image_url = models.URLField()
	position = models.PositiveSmallIntegerField()

	class Meta:
		db_table = "item_images"
		ordering = ["position"]
		unique_together = ("item", "position")

	def __str__(self) -> str:
		return f"{self.item_id} @ {self.position}"
