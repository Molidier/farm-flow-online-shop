from django.urls import path
from .views import OrderView, UserOrderHistoryView, ProcessDeliveryView, ProcessPaymentView, UpdateDeliveryAddressView, ConfirmOrderView, FarmerSalesReportView

urlpatterns = [
    path('', OrderView.as_view(), name='order-list'),
    path('order/<int:cart_id>/create/', OrderView.as_view(), name='order-create'),
    path('history/', UserOrderHistoryView.as_view(), name='user-oder-history'),
    path('<int:order_id>/payment/', ProcessPaymentView.as_view(), name='process-payment'),
    path('<int:order_id>/delivery/', ProcessDeliveryView.as_view(), name='process-delivery'),
    path('<int:order_id>/update-address/', UpdateDeliveryAddressView.as_view(), name='update-delivery-address'),
    path('<int:order_id>/confirm/', ConfirmOrderView.as_view(), name='confirm-order'),
    path('farmer/sales/<int:farmer_id>/',FarmerSalesReportView.as_view(), name='farmer-sales-report' )
]

