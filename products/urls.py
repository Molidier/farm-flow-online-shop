from django.urls import path
from .views import (
    CategoryListCreateAPIView,
    ProductCreateAPIView,
    ProductDetailAPIView
)

urlpatterns = [
    # Category endpoints
    path('category/', CategoryListCreateAPIView.as_view(), name='category-create-list'),  # Endpoint to create and list categories

    # Product endpoints
    path('product/', ProductCreateAPIView.as_view(), name='product-create'),
    path('product/<int:pk>/', ProductDetailAPIView.as_view(), name='product-detail'),
]
