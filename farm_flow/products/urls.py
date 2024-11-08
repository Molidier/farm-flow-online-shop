from django.urls import path
from .views import (
    ProductCreateAPIView, ProductDetailAPIView, 
    FarmerInventoryListCreateView, InventoryDetailUpdateDeleteView,
    FarmListCreateAPIView, FarmDetailUpdateDeleteAPIView
)

urlpatterns = [
    path('product/', ProductCreateAPIView.as_view(), name='product-create'),
    path('product/<int:pk>/', ProductDetailAPIView.as_view(), name='product-detail'),
    path('inventory/', FarmerInventoryListCreateView.as_view(), name='inventory-create'),
    path('inventory/<int:pk>/', InventoryDetailUpdateDeleteView.as_view(), name='inventory-detail'),
    path('farm/', FarmListCreateAPIView.as_view(), name='farm-create-list'),  # Endpoint to create and list farms
    path('farm/<int:pk>/', FarmDetailUpdateDeleteAPIView.as_view(), name='farm-detail'),  # Endpoint to retrieve, update, or delete a farm
]
