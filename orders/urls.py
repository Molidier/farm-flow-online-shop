from django.urls import path
from .views import UserOrderHistoryAPIView

urlpatterns = [
    # Existing URLs for Orders, OrderProduct, Payment, and Delivery views...
    path('user/orders/history/', UserOrderHistoryAPIView.as_view(), name='user_order_history'),  # New URL for order history
]
