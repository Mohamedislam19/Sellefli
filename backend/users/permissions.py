"""Custom permissions for users."""
from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
	"""Allow users to edit their own profile."""
	
	def has_object_permission(self, request, view, obj):
		# Read permissions are allowed to any request
		if request.method in permissions.SAFE_METHODS:
			return True
		
		# Write permissions only to the user of the profile
		return request.user == obj
