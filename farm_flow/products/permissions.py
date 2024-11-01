from rest_framework.permissions import BasePermission

class IsFarmer(BasePermission):
    """
    Custom permission to only allow farmers to create or update products.
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role == 'farmer'
