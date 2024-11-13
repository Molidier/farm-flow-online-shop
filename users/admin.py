from django.contrib import admin
from django import forms
from django.urls import path
from django.utils.html import format_html
from django.shortcuts import redirect
from .models import Farmer, PendingFarmer, ApprovedFarmer, User
from django.contrib import messages
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
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


class FFUserAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_name', 'get_email', 'get_is_active')
    # Get fields from User
    def get_name(self, obj):
        return obj.user.first_name + ' ' + obj.user.last_name
    get_name.short_description = 'Full Name'
    def get_email(self, obj):
        return obj.user.email
    get_email.short_description = 'Email'
    def get_is_active(self, obj):
        return obj.user.is_active
    get_is_active.short_description = 'Active'
    get_is_active.boolean = True


class BuyerAdmin(FFUserAdmin):
    list_display = FFUserAdmin.list_display + ('deliveryAdress',)
    search_fields = ('user__phone_number', 'user__email', 'deliveryAdress')


class FarmerAdminForm(forms.ModelForm):
    # Add `is_active` as a field in the FarmerAdmin form
    is_active = forms.BooleanField(label="Active", required=False)
    class Meta:
        model = Farmer
        fields = ['user', 'Fname', 'verified', 'is_active']
    # Initialize `is_active` from the related `User` model
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance.user:
            self.fields['is_active'].initial = self.instance.user.is_active
    # Save the `is_active` field to the related `User` model
    def save(self, commit=True):
        instance = super().save(commit=False)
        if 'is_active' in self.cleaned_data:
            # Set is_active on the related User model
            instance.user.is_active = self.cleaned_data['is_active']
            instance.user.save()  # Explicitly save the User instance
        if commit:
            instance.save()
        return instance


class BaseFarmerAdmin(FFUserAdmin):
    form = FarmerAdminForm
    list_display = FFUserAdmin.list_display + ('Fname', 'get_farm_location', 'get_farm_passport')
    search_fields = ('user__phone_number', 'user__email', 'Fname')
    # Get fields from Farm
    def get_farm_location(self, obj):
        return obj.farm.farm_location if hasattr(obj, 'farm') else 'No location'
    get_farm_location.short_description = 'Farm Location'
    def get_farm_passport(self, obj):
        return obj.farm.farm_passport if hasattr(obj, 'farm') else 'No size'
    get_farm_passport.short_description = 'Farm Passport'
    # Disable the Add button
    def has_add_permission(self, request):
        return False

class ApprovedFarmerAdmin(BaseFarmerAdmin):
    # Display only Verified Farmers
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(verified=True)
    
class RejectedFarmerAdmin(BaseFarmerAdmin):
    # Display only Inactive, Unverified Farmers
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(verified=False, user__is_active=False)

class PendingFarmerAdmin(BaseFarmerAdmin):
    list_display = BaseFarmerAdmin.list_display +  ('approve_button', 'reject_button')
     # Approve button
    def approve_button(self, obj):
        return format_html(
            '<a class="button" href="{}">Approve</a>',
            f"approve/{obj.id}"
        )
    approve_button.short_description = 'Approve'
    approve_button.allow_tags = True
    # Reject button
    def reject_button(self, obj):
        return format_html(
            '<a class="button" href="{}">Reject</a>',
            f"reject/{obj.id}"
        )
    reject_button.short_description = 'Reject'
    reject_button.allow_tags = True
    # Define custom URLs for approve and reject actions
    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('approve/<int:farmer_id>/', self.approve_farmer, name='approve_farmer'),
            path('reject/<int:farmer_id>/', self.reject_farmer, name='reject_farmer'),
        ]
        return custom_urls + urls
    # Approve action
    def approve_farmer(self, request, farmer_id):
        farmer = Farmer.objects.get(id=farmer_id)
        farmer.verified = True
        farmer.user.is_active = True
        farmer.save()
        messages.success(request, f"Farmer {farmer.Fname} has been approved.")
        return redirect(request.META.get('HTTP_REFERER'))
    # Reject action
    def reject_farmer(self, request, farmer_id):
        farmer = Farmer.objects.get(id=farmer_id)
        farmer.verified = False
        farmer.user.is_active = False
        farmer.save()
        farmer.user.save()
        messages.success(request, f"Farmer {farmer.Fname} has been rejected.")
        return redirect(request.META.get('HTTP_REFERER'))
    # Display only Active, Unverified Farmers
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(verified=False, user__is_active = True)

