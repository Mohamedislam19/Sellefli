"""Custom permissions for bookings."""
from rest_framework import permissions


class IsBookingOwner(permissions.BasePermission):
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.owner


class IsBookingBorrower(permissions.BasePermission):
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.borrower


class IsBookingOwnerOrBorrower(permissions.BasePermission):
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.owner or request.user == obj.borrower
