# farm_flow/farm_flow/urls.py
from django.contrib import admin
from farm_flow.admin import custom_admin_site
from django.urls import path, include
from ffapp import views
from users.views import RegisterFarmerAPIView, RegisterBuyerAPIView
from django.conf import settings
from django.conf.urls.static import static

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    #path("register_customer/", views.register_c, name="register_customer"),
    #path("register_farmer/", views.register_f, name="register_farmer"),
    path('admin/', custom_admin_site.urls),
    path("login/", views.login_view, name="login"),
    path("api/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("users/", include("users.urls")),  # Include users app URLs
    path("orders/", include("orders.urls")),  # Include orders app URLs
    path("products/", include("products.urls")),  # Include products app URLs
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)  # for serving media files

admin.site.index_title = 'Farm Flow'
admin.site.site_header = 'Farm Flow Admin'
admin.site.site_title = 'FF Admin Site'
