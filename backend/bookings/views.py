

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny 
from django.shortcuts import get_object_or_404

from .models import Booking, BookingStatus, DepositStatus
from .serializers import (
    BookingListSerializer,
    BookingDetailSerializer,
    BookingCreateSerializer,
    BookingStatusUpdateSerializer,
    DepositStatusUpdateSerializer,
)



class BookingViewSet(viewsets.ModelViewSet):
    
    
  
    queryset = Booking.objects.select_related('item', 'owner', 'borrower').all()
    
   
    permission_classes = [AllowAny]
    
   
    
    def get_serializer_class(self):
       
        # For creating new bookings, use the create serializer
        if self.action == 'create':
            return BookingCreateSerializer
        
        # For list views (incoming, my_requests, list), use the list serializer
        if self.action in ['list', 'incoming', 'my_requests']:
            return BookingListSerializer
        
        # For detail view (retrieve), use the detail serializer
        if self.action == 'retrieve':
            return BookingDetailSerializer
        
        # Default to list serializer
        return BookingListSerializer
    
  
    
    def retrieve(self, request, pk=None):
        
        # Get the booking or return 404 if not found
        booking = get_object_or_404(
            Booking.objects.select_related('item', 'owner', 'borrower'),
            pk=pk
        )
        
        # Serialize and return
        serializer = self.get_serializer(booking)
        return Response(serializer.data)
    
    def create(self, request):
       
        serializer = BookingCreateSerializer(data=request.data)
        
        # Validate the data
        if serializer.is_valid():
            # Save to database
            booking = serializer.save()
            
            # Return the created booking with 201 status
            return Response(
                BookingDetailSerializer(booking).data,
                status=status.HTTP_201_CREATED
            )
        
        # Return validation errors
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
  
    
    @action(detail=False, methods=['get'], url_path='incoming')
    def incoming(self, request):
       
        # Get owner_id from query parameters
        owner_id = request.query_params.get('owner_id')
        
        if not owner_id:
            return Response(
                {'error': 'owner_id query parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Filter bookings where the user is the owner
        # Order by newest first (matches Flutter repository)
        bookings = Booking.objects.select_related(
            'item', 'owner', 'borrower'
        ).filter(
            owner_id=owner_id
        ).order_by('-created_at')
        
        # Serialize and return
        serializer = BookingListSerializer(bookings, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'], url_path='my-requests')
    def my_requests(self, request):
       
        # Get borrower_id from query parameters
        borrower_id = request.query_params.get('borrower_id')
        
        if not borrower_id:
            return Response(
                {'error': 'borrower_id query parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Filter bookings where the user is the borrower
        bookings = Booking.objects.select_related(
            'item', 'owner', 'borrower'
        ).filter(
            borrower_id=borrower_id
        ).order_by('-created_at')
        
        # Serialize and return
        serializer = BookingListSerializer(bookings, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['patch'], url_path='status')
    def update_status(self, request, pk=None):
      
        # Get the booking
        booking = get_object_or_404(Booking, pk=pk)
        
        # Validate the new status
        serializer = BookingStatusUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        new_status = serializer.validated_data['status']
        
       
        if new_status == BookingStatus.ACCEPTED:
            # Accept the booking → generates booking code automatically
            booking.accept()
            message = f'Booking accepted. Code: {booking.booking_code}'
            
        elif new_status == BookingStatus.DECLINED:
            # Decline the booking
            booking.decline()
            message = 'Booking declined.'
            
        else:
            # For other status changes, just update the status directly
            booking.status = new_status
            booking.save(update_fields=['status', 'updated_at'])
            message = f'Booking status updated to {new_status}.'
        
        # Return updated booking
        return Response({
            'message': message,
            'booking': BookingDetailSerializer(booking).data
        })
    
    @action(detail=True, methods=['patch'], url_path='deposit')
    def update_deposit(self, request, pk=None):
       
        # Get the booking
        booking = get_object_or_404(Booking, pk=pk)
        
        # Validate the new deposit status
        serializer = DepositStatusUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        new_deposit_status = serializer.validated_data['deposit_status']
        
        # DEPOSIT STATUS TRANSITION LOGIC
        
        if new_deposit_status == DepositStatus.RECEIVED:
            # Validate: can only mark received when status=accepted and deposit_status=none
            # This matches Flutter cubit's markDepositReceived() validation
            if booking.status != BookingStatus.ACCEPTED:
                return Response(
                    {'error': 'Can only mark deposit received when booking is accepted'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            if booking.deposit_status != DepositStatus.NONE:
                return Response(
                    {'error': 'Deposit status must be none to mark as received'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            # This also sets status to 'active' (borrowing period begins)
            booking.mark_deposit_received()
            message = 'Deposit marked as received. Booking is now active.'
            
        elif new_deposit_status == DepositStatus.RETURNED:
            # This also completes the booking
            booking.mark_deposit_returned()
            message = 'Deposit returned. Booking completed.'
            
        elif new_deposit_status == DepositStatus.KEPT:
            # This also closes the booking
            booking.keep_deposit()
            message = 'Deposit kept. Booking closed.'
            
        else:
            booking.deposit_status = new_deposit_status
            booking.save(update_fields=['deposit_status', 'updated_at'])
            message = f'Deposit status updated to {new_deposit_status}.'
        
        # Return updated booking
        return Response({
            'message': message,
            'booking': BookingDetailSerializer(booking).data
        })
    
    @action(detail=True, methods=['post'], url_path='generate-code')
    def generate_code(self, request, pk=None):
       
        booking = get_object_or_404(Booking, pk=pk)
        
        # Generate new code (or keep existing one)
        if not booking.booking_code:
            code = booking.generate_booking_code()
        else:
            code = booking.booking_code
        
        return Response({
            'booking_code': code,
            'message': 'Booking code generated successfully.'
        })
    
    @action(detail=False, methods=['get'], url_path='user-transactions')
    def user_transactions(self, request):
       
        user_id = request.query_params.get('user_id')
        limit = int(request.query_params.get('limit', 10))
        
        if not user_id:
            return Response(
                {'error': 'user_id query parameter is required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get bookings where user is either owner or borrower
        # Uses Q objects for OR queries
        from django.db.models import Q
        
        bookings = Booking.objects.select_related(
            'item', 'owner', 'borrower'
        ).filter(
            Q(owner_id=user_id) | Q(borrower_id=user_id)
        ).order_by('-created_at')[:limit]
        
        # Serialize with an extra field indicating the user's role
        data = []
        for booking in bookings:
            booking_data = BookingListSerializer(booking).data
            booking_data['is_borrower'] = str(booking.borrower_id) == user_id
            data.append(booking_data)
        
        return Response(data)

