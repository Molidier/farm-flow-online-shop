from django.urls import path
from .views import RegisterFarmerAPIView, RegisterBuyerAPIView

urlpatterns = [
    path('register/farmer/', RegisterFarmerAPIView.as_view(), name='register_farmer'),
    path('register/buyer/', RegisterBuyerAPIView.as_view(), name='register_buyer'),
]
