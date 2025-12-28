"""DRF views for bookings."""
import time

from django.db import transaction
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Booking
from .permissions import IsBookingBorrower, IsBookingOwner
from .serializers import BookingSerializer


class BookingViewSet(viewsets.ModelViewSet):
	"""Booking CRUD and status transitions."""
	
	queryset = Booking.objects.select_related(
		"item", "item__owner", "owner", "borrower"
	).prefetch_related("ratings")
	serializer_class = BookingSerializer
	permission_classes = [permissions.IsAuthenticated]
	
	def get_queryset(self):
		"""Allow filtering by owner or borrower."""
		qs = super().get_queryset()
		params = self.request.query_params
		
		owner_id = params.get("owner_id") or params.get("ownerId")
		if owner_id:
			qs = qs.filter(owner_id=owner_id)
		
		borrower_id = params.get("borrower_id") or params.get("borrowerId")
		if borrower_id:
			qs = qs.filter(borrower_id=borrower_id)
		
		status_filter = params.get("status")
		if status_filter:
			qs = qs.filter(status=status_filter)
		
		return qs
	
	@action(detail=True, methods=["post"], url_path="accept", 
	        permission_classes=[permissions.IsAuthenticated, IsBookingOwner])
	def accept(self, request, pk=None):
		"""Accept a booking request (owner only)."""
		with transaction.atomic():
			booking = self.get_object()
			self.check_object_permissions(request, booking)
			
			if booking.status != Booking.Status.PENDING:
				return Response(
					{"detail": "Only pending bookings can be accepted"},
					status=status.HTTP_400_BAD_REQUEST,
				)
			
			booking.status = Booking.Status.ACCEPTED
			booking.save(update_fields=["status", "updated_at"])
			
			serializer = self.get_serializer(booking)
			return Response(serializer.data)
	
	@action(detail=True, methods=["post"], url_path="decline",
	        permission_classes=[permissions.IsAuthenticated, IsBookingOwner])
	def decline(self, request, pk=None):
		"""Decline a booking request (owner only)."""
		with transaction.atomic():
			booking = self.get_object()
			self.check_object_permissions(request, booking)
			
			if booking.status != Booking.Status.PENDING:
				return Response(
					{"detail": "Only pending bookings can be declined"},
					status=status.HTTP_400_BAD_REQUEST,
				)
			
			booking.status = Booking.Status.DECLINED
			booking.save(update_fields=["status", "updated_at"])
			
			serializer = self.get_serializer(booking)
			return Response(serializer.data)
	
	@action(detail=True, methods=["post"], url_path="mark-deposit-received",
	        permission_classes=[permissions.IsAuthenticated, IsBookingOwner])
	def mark_deposit_received(self, request, pk=None):
		"""Mark deposit as received and activate booking (owner only)."""
		with transaction.atomic():
			booking = self.get_object()
			self.check_object_permissions(request, booking)
			
			if booking.status != Booking.Status.ACCEPTED:
				return Response(
					{"detail": "Booking must be in accepted status"},
					status=status.HTTP_400_BAD_REQUEST,
				)
			
			if booking.deposit_status != Booking.DepositStatus.NONE:
				return Response(
					{"detail": "Deposit must be in none status"},
					status=status.HTTP_400_BAD_REQUEST,
				)
			
			booking.deposit_status = Booking.DepositStatus.RECEIVED
			booking.status = Booking.Status.ACTIVE
			booking.save(update_fields=["status", "deposit_status", "updated_at"])
			
			serializer = self.get_serializer(booking)
			return Response(serializer.data)
	
	@action(detail=True, methods=["post"], url_path="mark-deposit-returned",
	        permission_classes=[permissions.IsAuthenticated, IsBookingBorrower])
	def mark_deposit_returned(self, request, pk=None):
		"""Mark deposit as returned and complete booking (borrower only)."""
		with transaction.atomic():
			booking = self.get_object()
			self.check_object_permissions(request, booking)
			
			booking.deposit_status = Booking.DepositStatus.RETURNED
			booking.status = Booking.Status.COMPLETED
			booking.save(update_fields=["status", "deposit_status", "updated_at"])
			
			serializer = self.get_serializer(booking)
			return Response(serializer.data)
	
	@action(detail=True, methods=["post"], url_path="keep-deposit",
	        permission_classes=[permissions.IsAuthenticated, IsBookingOwner])
	def keep_deposit(self, request, pk=None):
		"""Keep deposit as penalty (owner only)."""
		with transaction.atomic():
			booking = self.get_object()
			self.check_object_permissions(request, booking)
			
			booking.deposit_status = Booking.DepositStatus.KEPT
			booking.status = Booking.Status.CLOSED
			booking.save(update_fields=["status", "deposit_status", "updated_at"])
			
			serializer = self.get_serializer(booking)
			return Response(serializer.data)
	
	@action(detail=True, methods=["post"], url_path="generate-code",
	        permission_classes=[permissions.IsAuthenticated, IsBookingOwner])
	def generate_code(self, request, pk=None):
		"""Generate a booking code for this reservation (owner only)."""
		with transaction.atomic():
			booking = self.get_object()
			self.check_object_permissions(request, booking)
			
			# Generate simple booking code (timestamp-based)
			booking.booking_code = f"BK{int(time.time() % 1000000):06d}"
			booking.save(update_fields=["booking_code", "updated_at"])
			
			serializer = self.get_serializer(booking)
			return Response(serializer.data)
