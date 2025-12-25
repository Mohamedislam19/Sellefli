"""
=============================================================================
BOOKING URLS - Django REST Framework URL Routing
=============================================================================

This file defines the URL PATTERNS for the bookings API.

WHAT IS URL ROUTING?
--------------------
URL routing maps URLs (like /api/bookings/) to views (Python code).

When a request comes in:
1. Django looks at the URL
2. Finds a matching pattern in urls.py
3. Calls the corresponding view
4. Returns the response

HOW ROUTERS WORK:
-----------------
DRF provides "routers" that automatically create URL patterns for ViewSets.

Instead of manually writing:
    path('', BookingViewSet.as_view({'get': 'list', 'post': 'create'}))
    path('<pk>/', BookingViewSet.as_view({'get': 'retrieve', 'put': 'update'}))
    ...

We just do:
    router.register('', BookingViewSet)

And the router creates ALL the patterns automatically!

GENERATED URLS:
---------------
When you register a ViewSet with a router, it creates these URLs:

Standard CRUD:
    GET    /api/bookings/              → list all bookings
    POST   /api/bookings/              → create a booking
    GET    /api/bookings/<id>/         → get one booking
    PUT    /api/bookings/<id>/         → update entire booking
    PATCH  /api/bookings/<id>/         → update some fields
    DELETE /api/bookings/<id>/         → delete a booking

Custom actions (from @action decorators in views.py):
    GET    /api/bookings/incoming/          → get incoming requests
    GET    /api/bookings/my-requests/       → get my requests
    PATCH  /api/bookings/<id>/status/       → update booking status
    PATCH  /api/bookings/<id>/deposit/      → update deposit status
    POST   /api/bookings/<id>/generate-code/ → generate booking code
    GET    /api/bookings/user-transactions/ → get user transactions

HOW THIS CONNECTS TO FLUTTER:
-----------------------------
Your Flutter app will call these endpoints:

Flutter BookingRepository method     → API Endpoint
------------------------------------------------------
createBooking()                      → POST /api/bookings/
getBookingDetails(id)                → GET /api/bookings/<id>/
getIncomingRequests(ownerId)         → GET /api/bookings/incoming/?owner_id=xxx
getMyRequests(borrowerId)            → GET /api/bookings/my-requests/?borrower_id=xxx
updateBookingStatus(id, status)      → PATCH /api/bookings/<id>/status/
updateDepositStatus(id, status)      → PATCH /api/bookings/<id>/deposit/
generateBookingCode(id)              → POST /api/bookings/<id>/generate-code/
getUserTransactions(userId)          → GET /api/bookings/user-transactions/?user_id=xxx

=============================================================================
"""

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import BookingViewSet


# =============================================================================
# ROUTER SETUP
# =============================================================================
# 
# DefaultRouter: Creates URL patterns for ViewSets
# - Includes a browsable API root (useful for development)
# - Automatically generates URL patterns for all ViewSet actions
#
# Parameters:
# - trailing_slash=True (default): URLs end with /
#   Example: /api/bookings/ (not /api/bookings)
# =============================================================================

router = DefaultRouter()

# =============================================================================
# REGISTER VIEWSETS
# =============================================================================
#
# router.register(prefix, viewset, basename)
#
# Parameters:
# - prefix: URL prefix ('' means no extra prefix since we're already at /api/bookings/)
# - viewset: The ViewSet class to route
# - basename: Used for generating URL names (optional, auto-detected from queryset)
#
# Since prefix is '', the URLs are:
# - /api/bookings/           (from main urls.py: path("api/bookings/", include(...)))
# - /api/bookings/<id>/
# - /api/bookings/incoming/
# - etc.
# =============================================================================

router.register(
    prefix='',                    # No extra prefix
    viewset=BookingViewSet,       # The ViewSet class
    basename='booking'            # URL names: booking-list, booking-detail, etc.
)


# =============================================================================
# URL PATTERNS
# =============================================================================
#
# The urlpatterns list tells Django which URLs this app handles.
#
# router.urls: All the auto-generated URL patterns from the router
#
# You can also add manual URL patterns here if needed:
#
#     urlpatterns = [
#         path('custom/', custom_view, name='custom'),  # Manual pattern
#     ] + router.urls                                    # + router patterns
#
# =============================================================================

urlpatterns = router.urls


# =============================================================================
# GENERATED URL NAMES
# =============================================================================
#
# Each URL pattern has a "name" you can use for reverse lookups.
# These names follow the pattern: {basename}-{action}
#
# Standard actions:
#     booking-list          → /api/bookings/
#     booking-detail        → /api/bookings/<pk>/
#
# Custom actions (from @action decorator):
#     booking-incoming      → /api/bookings/incoming/
#     booking-my-requests   → /api/bookings/my-requests/
#     booking-update-status → /api/bookings/<pk>/status/
#     booking-update-deposit → /api/bookings/<pk>/deposit/
#     booking-generate-code → /api/bookings/<pk>/generate-code/
#     booking-user-transactions → /api/bookings/user-transactions/
#
# Usage in Python code:
#     from django.urls import reverse
#     url = reverse('booking-detail', kwargs={'pk': booking_id})
#     # Returns: '/api/bookings/550e8400-e29b-41d4-a716-446655440000/'
#
# =============================================================================

