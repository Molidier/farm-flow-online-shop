from django.urls import path
from .views import (
    CategoryListCreateAPIView,
    ProductCreateAPIView, ProductDetailAPIView, 
    FarmerInventoryListCreateView, InventoryDetailUpdateDeleteView,
    FarmListCreateAPIView, FarmDetailUpdateDeleteAPIView, FarmerFarmListAPIView, 
    CartItemView, CartView, CartItemDeleteView, CartDeleteView
)

urlpatterns = [
    # Category endpoints
    path('category/', CategoryListCreateAPIView.as_view(), name='category-create-list'),  # Endpoint to create and list categories

    # Product endpoints
    path('product/', ProductCreateAPIView.as_view(), name='product-create'),
    path('product/<int:pk>/', ProductDetailAPIView.as_view(), name='product-detail'),

    # Inventory endpoints
    path('inventory/', FarmerInventoryListCreateView.as_view(), name='inventory-create-list'),  # Create and list inventory items
    path('inventory/<int:pk>/', InventoryDetailUpdateDeleteView.as_view(), name='inventory-detail'),  # Retrieve, update, or delete inventory items

    # Farm endpoints
    path('farm/', FarmListCreateAPIView.as_view(), name='farm-create-list'),  # Create and list farms
    path('farm/<int:pk>/', FarmDetailUpdateDeleteAPIView.as_view(), name='farm-detail'),  # Retrieve, update, or delete a farm
    path('farms/', FarmerFarmListAPIView.as_view(), name='farmer-farm-list'),  # List all farms for a specific farmer

    path('cart/', CartView.as_view(), name='cart-list-create'),
    path('cart/', CartDeleteView.as_view(), name='delete-cart'),
    path('cart/items/', CartItemView.as_view(), name='add-cart-item'),
    path('cart/items/<int:item_id>/', CartItemDeleteView.as_view(), name='delete-cart-item')
]
