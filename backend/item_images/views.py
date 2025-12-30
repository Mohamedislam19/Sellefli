"""DRF views for item images."""
import uuid
import os
from supabase import create_client, Client

from django.db import transaction
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import ItemImage
from .serializers import ItemImageSerializer


class ItemImageViewSet(viewsets.ModelViewSet):
	queryset = ItemImage.objects.select_related("item")
	serializer_class = ItemImageSerializer
	permission_classes = [permissions.IsAuthenticated]
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

		# Initialize Supabase Client
		supabase_url = os.getenv("SUPABASE_URL")
		supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
		
		if not supabase_url or not supabase_key:
			return Response({"detail": "Server misconfiguration: missing Supabase credentials"}, status=500)

		try:
			supabase: Client = create_client(supabase_url, supabase_key)
			
			# Generate unique filename
			filename = f"{uuid.uuid4()}_{file.name}"
			# Bucket: item-images (verify this exists in your Supabase dashboard)
			bucket_name = "item-images"
			path_on_storage = f"{item_id}/{filename}"
			
			# Read file bytes
			file_content = file.read()
			
			# Upload to Supabase
			res = supabase.storage.from_(bucket_name).upload(
				path=path_on_storage,
				file=file_content,
				file_options={"content-type": file.content_type}
			)
			
			# Get Public URL
			file_url = supabase.storage.from_(bucket_name).get_public_url(path_on_storage)
			
		except Exception as exc:
			return Response({"detail": f"Supabase upload failed: {exc}"}, status=500)

		serializer = ItemImageSerializer(
			data={"item_id": item_id, "image_url": file_url, "position": position}
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
		"""Delete file from Supabase Storage using URL."""
		if not image_url:
			return
		
		# Try to extract path from URL
		# URL format: .../storage/v1/object/public/item-images/item_id/filename
		try:
			supabase_url = os.getenv("SUPABASE_URL")
			supabase_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
			if not supabase_url or not supabase_key:
				return

			supabase: Client = create_client(supabase_url, supabase_key)
			bucket_name = "item-images" # Match the bucket used in upload
			
			# Simple heuristic to extract path: everything after bucket_name + /
			if bucket_name in image_url:
				parts = image_url.split(f"/{bucket_name}/")
				if len(parts) > 1:
					path_to_delete = parts[1]
					supabase.storage.from_(bucket_name).remove([path_to_delete])
		except Exception:
			# Silent fail allowed for delete
			pass
