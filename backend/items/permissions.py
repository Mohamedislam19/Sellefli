"""Custom permissions for items."""
from rest_framework import permissions


class IsItemOwner(permissions.BasePermission):
	"""Allow only item owner to perform action."""
	
	def has_object_permission(self, request, view, obj):
		return request.user == obj.owner
