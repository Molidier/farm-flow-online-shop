"""
URL configuration for farm_flow project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.urls import path
from ffapp import views  # Import views from your app (replace 'ffapp' with your actual app name)


urlpatterns = [
    path('register_customer/', views.register_c, name='register_customer'),  # Endpoint for customer registration
    path('register_farmer/', views.register_f, name='register_farmer'),      # Endpoint for farmer registration
    path('login/', views.login_view, name='login'),                          # Endpoint for login
]

