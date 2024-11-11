from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Buyer, Farmer, OTP

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

class FarmerAdmin(admin.ModelAdmin):
    list_display = ('user', 'Fname', 'is_verified')
    search_fields = ('user__phone_number', 'user__email', 'Fname')
    list_filter = ('is_verified',)

class OTPAdmin(admin.ModelAdmin):
    list_display = ('phone_number', 'otp', 'created_at')
    search_fields = ('phone_number',)
    list_filter = ('created_at',)

# Register the models with the custom admin classes
admin.site.register(User, UserAdmin)
admin.site.register(Buyer, BuyerAdmin)
admin.site.register(Farmer, FarmerAdmin)
admin.site.register(OTP, OTPAdmin)
