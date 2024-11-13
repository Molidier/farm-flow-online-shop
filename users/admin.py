from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Buyer, Farmer, OTP, VerifiedFarmer, PendingFarmer
from rest_framework.authtoken.models import TokenProxy
from django.contrib.auth.models import Group

#Hides Auth Token and Groups Sections
admin.site.unregister(Group)
admin.site.unregister(TokenProxy)

class UserAdmin(BaseUserAdmin):
    # Define the fields to display in the list view
    list_display = ('email', 'phone_number', 'first_name', 'last_name', 'role', 'is_staff', 'is_active')
    list_filter = ('is_staff', 'is_superuser', 'is_active', 'role')
    search_fields = ('email', 'phone_number', 'first_name', 'last_name')
    ordering = ('email',)
    
    # Define fieldsets for detailed view in the admin
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('first_name', 'last_name', 'phone_number')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_superuser', 'role')}),
    )
    
    # Define fieldsets for the add view in the admin
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'phone_number', 'first_name', 'last_name', 'role', 'password1', 'password2', 'is_staff', 'is_active'),
        }),
    )

class BuyerAdmin(admin.ModelAdmin):
    list_display = ('user', 'deliveryAdress')
    search_fields = ('user__phone_number', 'user__email', 'deliveryAdress')
    
class BaseFarmerAdmin(admin.ModelAdmin):
    list_display = ('user', 'Fname', 'get_farm_location', 'get_farm_passport')
    search_fields = ('user__phone_number', 'user__email', 'Fname')

    # Common methods to display related Farm information
    def get_farm_location(self, obj):
        return obj.farm.farm_location if hasattr(obj, 'farm') else 'No location'
    get_farm_location.short_description = 'Farm Location'

    def get_farm_passport(self, obj):
        return obj.farm.farm_passport if hasattr(obj, 'farm') else 'No size'
    get_farm_passport.short_description = 'Farm Passport'

class VerifiedFarmerAdmin(BaseFarmerAdmin):
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(verified=True)

class PendingFarmerAdmin(BaseFarmerAdmin):
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(verified=False)

# class OTPAdmin(admin.ModelAdmin):
#     list_display = ('phone_number', 'otp', 'created_at')
#     search_fields = ('phone_number',)
#     list_filter = ('created_at',)

# Register the models with the custom admin classes
# admin.site.register(OTP, OTPAdmin)
