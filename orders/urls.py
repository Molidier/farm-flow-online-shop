from django.urls import path
from .views import OrderView, UserOrderHistoryView

urlpatterns = [
    # Existing URLs for Orders, OrderProduct, Payment, and Delivery views...
    path('', OrderView.as_view(), name='order-list'),
    path('order/<int:cart_id>/create/', OrderView.as_view(), name='order-create'),
    path('history/', UserOrderHistoryView.as_view(), name='user-oder-history'),
]
