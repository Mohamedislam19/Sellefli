"""
=============================================================================
BOOKING VIEWS - Django REST Framework API Views
=============================================================================

This file defines the API VIEWS (endpoints) for bookings.

WHAT IS A VIEW?
---------------
A view is a Python function or class that:
1. Receives an HTTP request (GET, POST, PUT, DELETE, etc.)
2. Processes the request (fetch data, validate input, etc.)
3. Returns an HTTP response (usually JSON for APIs)

Think of views as the "controller" in MVC architecture - they handle
the logic between the URL and the data.

VIEW TYPES IN DRF (Django REST Framework):
------------------------------------------
1. APIView: Basic class-based view, you define get(), post(), etc.
2. ViewSet: Groups related views together (list, create, retrieve, update, delete)
3. ModelViewSet: ViewSet with automatic CRUD operations for a model
4. @api_view: Decorator for function-based views

We'll use a mix of ViewSet (for standard CRUD) and custom actions.

HOW THIS CONNECTS TO FLUTTER:
-----------------------------
Each view method corresponds to an API endpoint that Flutter calls:

Flutter BookingRepository method → Django View → Database

- createBooking()          → BookingViewSet.create()
- getBookingDetails(id)    → BookingViewSet.retrieve()
- getIncomingRequests()    → BookingViewSet.incoming()
- getMyRequests()          → BookingViewSet.my_requests()
- updateBookingStatus()    → BookingViewSet.update_status()
- updateDepositStatus()    → BookingViewSet.update_deposit()

=============================================================================
"""

from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import AllowAny  # TODO: Change to IsAuthenticated in production
from django.shortcuts import get_object_or_404

from .models import Booking, BookingStatus, DepositStatus
from .serializers import (
    BookingListSerializer,
    BookingDetailSerializer,
    BookingCreateSerializer,
    BookingStatusUpdateSerializer,
    DepositStatusUpdateSerializer,
)


# =============================================================================
# BOOKING VIEWSET
# =============================================================================

class BookingViewSet(viewsets.ModelViewSet):
    """
    ViewSet for Booking CRUD operations and custom actions.
    
    A ViewSet combines multiple related views into a single class.
    It automatically provides these actions:
    
    Standard CRUD actions (from ModelViewSet):
    ------------------------------------------
    - list()     → GET /api/bookings/           → List all bookings
    - create()   → POST /api/bookings/          → Create a new booking
    - retrieve() → GET /api/bookings/<id>/      → Get a single booking
    - update()   → PUT /api/bookings/<id>/      → Update entire booking
    - partial_update() → PATCH /api/bookings/<id>/ → Update some fields
    - destroy()  → DELETE /api/bookings/<id>/   → Delete a booking
    
    Custom actions (we define these with @action decorator):
    --------------------------------------------------------
    - incoming()       → GET /api/bookings/incoming/?owner_id=xxx
    - my_requests()    → GET /api/bookings/my-requests/?borrower_id=xxx
    - update_status()  → PATCH /api/bookings/<id>/status/
    - update_deposit() → PATCH /api/bookings/<id>/deposit/
    - generate_code()  → POST /api/bookings/<id>/generate-code/
    
    The router in urls.py automatically creates URL patterns for all these.
    """
    
    # -------------------------------------------------------------------------
    # VIEWSET CONFIGURATION
    # -------------------------------------------------------------------------
    
    # Base queryset: All bookings, with related objects pre-loaded for efficiency
    # select_related: SQL JOIN to fetch related objects in one query
    # This prevents the "N+1 query problem" (fetching users/items one by one)
    queryset = Booking.objects.select_related('item', 'owner', 'borrower').all()
    
    # Permission classes: Who can access this viewset
    # AllowAny: No authentication required (for development)
    # TODO: Change to IsAuthenticated for production
    permission_classes = [AllowAny]
    
    # -------------------------------------------------------------------------
    # get_serializer_class: Choose serializer based on the action
    # -------------------------------------------------------------------------
    
    def get_serializer_class(self):
        """
        Return different serializers for different actions.
        
        This is a common pattern:
        - List views use a lighter serializer (less data, faster)
        - Detail views use a fuller serializer (more data)
        - Create views use a serializer optimized for input validation
        
        Returns:
            The serializer class to use for the current action
        """
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
    
    # -------------------------------------------------------------------------
    # STANDARD CRUD OVERRIDES
    # -------------------------------------------------------------------------
    
    def retrieve(self, request, pk=None):
        """
        GET /api/bookings/<id>/
        
        Retrieve detailed information about a single booking.
        This matches Flutter's getBookingDetails() method.
        
        The response includes:
        - Full booking data (status, dates, cost, etc.)
        - Nested item data (title, deposit amount)
        - Nested borrower data (username, avatar, phone)
        - Nested owner data (username, avatar, phone)
        - First image URL for the item
        
        Args:
            request: The HTTP request
            pk: The booking ID (from URL)
            
        Returns:
            Response with serialized booking data
        """
        # Get the booking or return 404 if not found
        booking = get_object_or_404(
            Booking.objects.select_related('item', 'owner', 'borrower'),
            pk=pk
        )
        
        # Serialize and return
        serializer = self.get_serializer(booking)
        return Response(serializer.data)
    
    def create(self, request):
        """
        POST /api/bookings/
        
        Create a new booking request.
        This matches Flutter's createBooking() method.
        
        Expected request body:
        {
            "item_id": "uuid-of-item",
            "owner_id": "uuid-of-owner",
            "borrower_id": "uuid-of-borrower",
            "start_date": "2024-01-15",
            "return_by_date": "2024-01-20",
            "total_cost": 500.00
        }
        
        The booking is created with:
        - status = 'pending' (default)
        - deposit_status = 'none' (default)
        - No booking_code (generated when accepted)
        
        Args:
            request: The HTTP request with booking data
            
        Returns:
            Response with created booking data (201 Created)
            or validation errors (400 Bad Request)
        """
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
    
    # -------------------------------------------------------------------------
    # CUSTOM ACTIONS
    # -------------------------------------------------------------------------
    # The @action decorator creates additional endpoints on the viewset.
    # 
    # Parameters:
    # - detail=True: URL includes an ID, like /api/bookings/<id>/action/
    # - detail=False: URL is on the collection, like /api/bookings/action/
    # - methods=['get']: HTTP methods this action responds to
    # - url_path: Custom URL segment (default is method name with underscores → dashes)
    # -------------------------------------------------------------------------
    
    @action(detail=False, methods=['get'], url_path='incoming')
    def incoming(self, request):
        """
        GET /api/bookings/incoming/?owner_id=<uuid>
        
        Get all incoming booking requests for an owner.
        This matches Flutter's getIncomingRequests() method.
        
        These are requests from OTHER users who want to borrow the owner's items.
        Used in the "Incoming" tab of RequestsOrdersPage.
        
        Query Parameters:
            owner_id (required): UUID of the item owner
            
        Returns:
            List of bookings where the user is the owner
        """
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
        """
        GET /api/bookings/my-requests/?borrower_id=<uuid>
        
        Get all booking requests made by a borrower.
        This matches Flutter's getMyRequests() method.
        
        These are requests the user has made to borrow items from others.
        Used in the "My Requests" tab of RequestsOrdersPage.
        
        Query Parameters:
            borrower_id (required): UUID of the borrower
            
        Returns:
            List of bookings where the user is the borrower
        """
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
        """
        PATCH /api/bookings/<id>/status/
        
        Update the status of a booking.
        This matches Flutter's updateBookingStatus() method.
        
        Expected request body:
        {
            "status": "accepted"  // or "declined", "active", "completed", "closed"
        }
        
        Special behavior:
        - When accepting, a booking code is automatically generated
        
        Args:
            request: The HTTP request with new status
            pk: The booking ID
            
        Returns:
            Updated booking data
        """
        # Get the booking
        booking = get_object_or_404(Booking, pk=pk)
        
        # Validate the new status
        serializer = BookingStatusUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        new_status = serializer.validated_data['status']
        
        # -------------------------------------------------------------------------
        # STATUS TRANSITION LOGIC
        # -------------------------------------------------------------------------
        # Different status changes trigger different behaviors
        # -------------------------------------------------------------------------
        
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
        """
        PATCH /api/bookings/<id>/deposit/
        
        Update the deposit status of a booking.
        This matches Flutter's updateDepositStatus() method.
        
        Expected request body:
        {
            "deposit_status": "received"  // or "returned", "kept"
        }
        
        Special behavior:
        - "returned" also sets booking status to "completed"
        - "kept" also sets booking status to "closed"
        
        Args:
            request: The HTTP request with new deposit status
            pk: The booking ID
            
        Returns:
            Updated booking data
        """
        # Get the booking
        booking = get_object_or_404(Booking, pk=pk)
        
        # Validate the new deposit status
        serializer = DepositStatusUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        new_deposit_status = serializer.validated_data['deposit_status']
        
        # -------------------------------------------------------------------------
        # DEPOSIT STATUS TRANSITION LOGIC
        # -------------------------------------------------------------------------
        
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
        """
        POST /api/bookings/<id>/generate-code/
        
        Generate a booking code for a booking.
        This matches Flutter's generateBookingCode() method.
        
        Normally, the code is generated automatically when accepting a booking.
        This endpoint allows manual code generation if needed.
        
        Args:
            request: The HTTP request
            pk: The booking ID
            
        Returns:
            The generated booking code
        """
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
        """
        GET /api/bookings/user-transactions/?user_id=<uuid>
        
        Get recent transactions for a user (as either owner or borrower).
        This matches Flutter's getUserTransactions() method.
        
        Used for the transaction history / activity feed.
        
        Query Parameters:
            user_id (required): UUID of the user
            limit (optional): Max number of results (default 10)
            
        Returns:
            List of recent bookings involving this user
        """
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

