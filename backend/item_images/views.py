"""DRF views for item images."""
import os
import uuid

from django.conf import settings
from django.db import transaction
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from supabase import create_client, Client

from .models import ItemImage
from .serializers import ItemImageSerializer


class ItemImageViewSet(viewsets.ModelViewSet):
	queryset = ItemImage.objects.select_related("item")
	serializer_class = ItemImageSerializer
	http_method_names = ["get", "post", "patch", "delete", "head", "options"]

	def get_queryset(self):
		qs = super().get_queryset()
		item_id = self.request.query_params.get("item_id") or self.request.query_params.get(
			"itemId"
		)
		if item_id:
			qs = qs.filter(item_id=item_id)
		return qs.order_by("position")

	def destroy(self, request, *args, **kwargs):
		instance = self.get_object()
		self._delete_storage_file(instance.image_url)
		return super().destroy(request, *args, **kwargs)

	@action(detail=False, methods=["post"], url_path="upload")
	def upload(self, request):
		"""Upload a single file to Supabase Storage and create ItemImage row.

		Expected form-data: file, item_id, position (1-3)
		"""
		file = request.FILES.get("file")
		item_id = request.data.get("item_id") or request.data.get("itemId")
		position = request.data.get("position")

		if not file or not item_id or not position:
			return Response(
				{"detail": "file, item_id, and position are required"},
				status=status.HTTP_400_BAD_REQUEST,
			)

		try:
			position = int(position)
		except ValueError:
			return Response({"detail": "position must be int"}, status=400)

		client = self._supabase_client()
		filename = f"{uuid.uuid4()}_{file.name}"
		storage_path = f"items/{item_id}/{filename}"

		try:
			client.storage.from_("item-images").upload(
				storage_path,
				file.read(),
				file_options={"content-type": file.content_type or "application/octet-stream"},
			)
			public_url = client.storage.from_("item-images").get_public_url(storage_path)
		except Exception as exc:  # pragma: no cover - network/storage failure
			return Response({"detail": f"upload failed: {exc}"}, status=500)

		serializer = ItemImageSerializer(
			data={"item_id": item_id, "image_url": public_url, "position": position}
		)
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data, status=status.HTTP_201_CREATED)

	@action(detail=False, methods=["post"], url_path="delete-by-url")
	def delete_by_url(self, request):
		image_url = request.data.get("image_url") or request.data.get("imageUrl")
		if not image_url:
			return Response({"detail": "image_url is required"}, status=400)

		qs = ItemImage.objects.filter(image_url=image_url)
		if not qs.exists():
			return Response(status=204)

		self._delete_storage_file(image_url)
		qs.delete()
		return Response(status=204)

	@action(detail=False, methods=["post"], url_path="delete-not-in-positions")
	def delete_not_in_positions(self, request):
		item_id = request.data.get("item_id") or request.data.get("itemId")
		positions = request.data.get("positions") or request.data.get("allowed_positions")
		if not item_id or positions is None:
			return Response({"detail": "item_id and positions are required"}, status=400)
		if not isinstance(positions, list):
			return Response({"detail": "positions must be a list"}, status=400)

		with transaction.atomic():
			qs = ItemImage.objects.filter(item_id=item_id).exclude(position__in=positions)
			for img in qs:
				self._delete_storage_file(img.image_url)
			deleted = qs.count()
			qs.delete()
		return Response({"deleted": deleted})

	@action(detail=False, methods=["post"], url_path="delete-except-ids")
	def delete_except_ids(self, request):
		item_id = request.data.get("item_id") or request.data.get("itemId")
		allowed_ids = request.data.get("allowed_ids") or request.data.get("allowedIds")
		if not item_id or allowed_ids is None:
			return Response({"detail": "item_id and allowed_ids are required"}, status=400)
		if not isinstance(allowed_ids, list):
			return Response({"detail": "allowed_ids must be a list"}, status=400)

		with transaction.atomic():
			qs = ItemImage.objects.filter(item_id=item_id).exclude(id__in=allowed_ids)
			for img in qs:
				self._delete_storage_file(img.image_url)
			deleted = qs.count()
			qs.delete()
		return Response({"deleted": deleted})

	def _delete_storage_file(self, image_url: str):
		if not image_url:
			return
		client = self._supabase_client(optional=True)
		if client is None:
			return
		bucket = "item-images"
		marker = f"/object/public/{bucket}/"
		if marker in image_url:
			path = image_url.split(marker, 1)[1]
		else:
			# best effort: take substring after bucket name
			if bucket in image_url:
				path = image_url.split(bucket, 1)[1].lstrip("/")
			else:
				return
		try:
			client.storage.from_(bucket).remove([path])
		except Exception:
			pass

	def _supabase_client(self, optional: bool = False) -> Client | None:
		url = os.getenv("SUPABASE_URL") or getattr(settings, "SUPABASE_URL", None)
		key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or getattr(
			settings, "SUPABASE_SERVICE_ROLE_KEY", None
		)
		if not url or not key:
			if optional:
				return None
			raise RuntimeError("Supabase credentials (SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY) are required")
		return create_client(url, key)
