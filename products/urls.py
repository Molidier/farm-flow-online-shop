from django.urls import path
from .views import (
    CategoryListCreateAPIView,
    ProductCreateAPIView,
    ProductDetailAPIView,
    CartItemView,
    CartItemDeleteView,
    CartDeleteView,
    CartView,
    BargainRequestView,
    BargainResponseView
)

urlpatterns = [
    # Category endpoints
    path('category/', CategoryListCreateAPIView.as_view(), name='category-create-list'),  # Endpoint to create and list categories

    # Product endpoints
    path('product/', ProductCreateAPIView.as_view(), name='product-create'),
    path('product/<int:pk>/', ProductDetailAPIView.as_view(), name='product-detail'),

    path('cart/', CartView.as_view(), name='cart-list-create'),
    path('cart/', CartDeleteView.as_view(), name='delete-cart'),
    path('cart/items/', CartItemView.as_view(), name='add-cart-item'),
    path('cart/items/<int:item_id>/', CartItemDeleteView.as_view(), name='delete-cart-item'),
    path('cart/items/<int:item_id>/bargain/request/', BargainRequestView.as_view(), name='bargain-request'),
    path('cart/items/<int:item_id>/bargain/respond/', BargainResponseView.as_view(), name='bargain-response'),
]
