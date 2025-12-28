"""DRF views for ratings."""
from rest_framework import permissions, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Rating
from .serializers import RatingSerializer


class RatingViewSet(viewsets.ModelViewSet):
	"""Rating CRUD operations."""
	
	queryset = Rating.objects.select_related(
		"booking", "rater", "target_user"
	)
	serializer_class = RatingSerializer
	permission_classes = [permissions.IsAuthenticated]
	
	def get_queryset(self):
		"""Allow filtering by user."""
		qs = super().get_queryset()
		params = self.request.query_params
		
		target_user_id = params.get("target_user_id") or params.get("targetUserId")
		if target_user_id:
			qs = qs.filter(target_user_id=target_user_id)
		
		rater_id = params.get("rater_id") or params.get("raterId")
		if rater_id:
			qs = qs.filter(rater_id=rater_id)
		
		booking_id = params.get("booking_id") or params.get("bookingId")
		if booking_id:
			qs = qs.filter(booking_id=booking_id)
		
		return qs
	
	@action(detail=False, methods=["get"], url_path="has-rated")
	def has_rated(self, request):
		"""Check if a user has already rated for a booking."""
		booking_id = request.query_params.get("booking_id") or request.query_params.get("bookingId")
		rater_id = request.query_params.get("rater_id") or request.query_params.get("raterId")
		
		if not booking_id or not rater_id:
			return Response({"detail": "booking_id and rater_id required"}, status=400)
		
		exists = Rating.objects.filter(
			booking_id=booking_id,
			rater_id=rater_id,
		).exists()
		
		return Response({"has_rated": exists})
