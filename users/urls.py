from django.urls import path
from .views import RegisterFarmerAPIView, RegisterBuyerAPIView, FarmerUserPageView, BuyerUserPageView, VerifyOTPView

urlpatterns = [
    path('register/farmer/', RegisterFarmerAPIView.as_view(), name='register_farmer'),
    path('register/buyer/', RegisterBuyerAPIView.as_view(), name='register_buyer'),
    path('farmer/userpage/', FarmerUserPageView.as_view(), name='farmer_userpage'),
    path('buyer/userpage/', BuyerUserPageView.as_view(), name='buyer_userpage'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify_otp'),
]