"""DRF views for items."""
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response

from item_images.models import ItemImage
from item_images.serializers import ItemImageSerializer
from .models import Item
from .serializers import ItemSerializer


class ItemPagination(PageNumberPagination):
	page_size_query_param = "page_size"

	def get_page_size(self, request):
		explicit = super().get_page_size(request)
		if explicit:
			return explicit
		# Support camelCase param used by the Flutter client
		alt = request.query_params.get("pageSize")
		if alt:
			try:
				return int(alt)
			except ValueError:
				return None
		return self.page_size


class ItemViewSet(viewsets.ModelViewSet):
	queryset = Item.objects.select_related("owner").prefetch_related("images")
	serializer_class = ItemSerializer
	pagination_class = ItemPagination

	def get_queryset(self):
		qs = super().get_queryset()
		params = self.request.query_params

		exclude_user = params.get("excludeUserId") or params.get("exclude_user_id")
		if exclude_user:
			qs = qs.exclude(owner_id=exclude_user)

		# Category filter: accepts comma-separated or repeated params.
		categories = params.getlist("categories") or []
		if not categories:
			raw = params.get("categories")
			if raw:
				categories = [c for c in raw.split(",") if c]
		if categories and "All" not in categories:
			qs = qs.filter(category__in=categories)

		search = params.get("searchQuery") or params.get("search")
		if search:
			qs = qs.filter(title__icontains=search)

		return qs

	@action(detail=True, methods=["get", "post"], url_path="images")
	def images(self, request, pk=None):
		item = self.get_object()
		if request.method.lower() == "get":
			serializer = ItemImageSerializer(
				item.images.order_by("position"), many=True
			)
			return Response(serializer.data)

		# POST supports a single object or a list of objects
		data = request.data
		many = isinstance(data, list)
		serializer = ItemImageSerializer(
			data=data,
			many=many,
			context={"item_id": str(item.id)},
		)
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data, status=status.HTTP_201_CREATED)

	@action(detail=True, methods=["post"], url_path="images/reorder")
	def reorder_images(self, request, pk=None):
		item = self.get_object()
		ordered_ids = request.data.get("ordered_ids") or request.data.get("orderedIds")
		if not isinstance(ordered_ids, list):
			return Response({"detail": "ordered_ids must be a list"}, status=400)

		for idx, img_id in enumerate(ordered_ids, start=1):
			ItemImage.objects.filter(item=item, id=img_id).update(position=idx)

		return Response({"status": "ok"})

	def destroy(self, request, *args, **kwargs):
		item = self.get_object()
		# Clean up related images (DB and storage) before deleting item
		images = list(item.images.all())
		for img in images:
			try:
				from item_images.views import ItemImageViewSet

				ItemImageViewSet()._delete_storage_file(img.image_url)
			except Exception:
				pass
			img.delete()
		return super().destroy(request, *args, **kwargs)

	@action(detail=True, methods=["post"], url_path="images/sync")
	def sync_images(self, request, pk=None):
		"""Replace images set for an item.

		Accepts JSON body:
		{
		  "keep_ids": ["uuid", ...],
		  "remove_urls": ["..."],
		  "add": [ {"image_url": "...", "position": 1}, ...]
		}
		"""

		item = self.get_object()
		keep_ids = request.data.get("keep_ids") or request.data.get("keepIds") or []
		remove_urls = request.data.get("remove_urls") or request.data.get("removeUrls") or []
		add_payload = request.data.get("add") or []

		if not isinstance(keep_ids, list) or not isinstance(remove_urls, list) or not isinstance(add_payload, list):
			return Response({"detail": "keep_ids, remove_urls, add must be lists"}, status=400)

		# delete any images not in keep_ids or explicitly in remove_urls
		to_delete = ItemImage.objects.filter(item=item).exclude(id__in=keep_ids)
		if remove_urls:
			to_delete = ItemImage.objects.filter(item=item, image_url__in=remove_urls) | to_delete
		for img in to_delete.distinct():
			try:
				from item_images.views import ItemImageViewSet

				ItemImageViewSet()._delete_storage_file(img.image_url)
			except Exception:
				pass
		to_delete.distinct().delete()

		created = []
		if add_payload:
			serializer = ItemImageSerializer(
				data=[{**item_data, "item_id": str(item.id)} for item_data in add_payload],
				many=True,
				context={"item_id": str(item.id)},
			)
			serializer.is_valid(raise_exception=True)
			serializer.save()
			created = serializer.data

		return Response({"created": created, "status": "ok"}, status=200)
