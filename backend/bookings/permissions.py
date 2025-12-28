"""Custom permissions for bookings."""
from rest_framework import permissions


class IsBookingOwner(permissions.BasePermission):
	"""Allow only booking owner to perform action."""
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.owner


class IsBookingBorrower(permissions.BasePermission):
	"""Allow only booking borrower to perform action."""
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.borrower


class IsBookingOwnerOrBorrower(permissions.BasePermission):
	"""Allow booking owner or borrower to perform action."""
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.owner or request.user == obj.borrower
