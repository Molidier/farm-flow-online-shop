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
from django.middleware.csrf import get_token
from django.http import HttpResponse
from django.core.mail import send_mail
from django.core.mail import BadHeaderError
from smtplib import SMTPException

#Hides Auth Token and Groups Sections
admin.site.unregister(Group)
admin.site.unregister(TokenProxy)


class UserAdmin(BaseUserAdmin):
    # Define the fields to display in the list view
    list_display = ('email', 'phone_number', 'first_name', 'last_name', 'role', 'is_staff')
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
            'fields': ('email', 'phone_number', 'first_name', 'last_name', 'role', 'password1', 'password2', 'is_staff',),
        }),
    )


class FFUserAdmin(admin.ModelAdmin):
    list_display = ('user', 'get_name', 'get_email')
    # Get fields from User
    def get_name(self, obj):
        return obj.user.first_name + ' ' + obj.user.last_name
    get_name.short_description = 'Full Name'
    def get_email(self, obj):
        return obj.user.email
    get_email.short_description = 'Email'


class BuyerAdmin(FFUserAdmin):
    list_display = FFUserAdmin.list_display + ('deliveryAdress',)
    search_fields = ('user__phone_number', 'user__email', 'deliveryAdress')


class FarmerAdminForm(forms.ModelForm):
    # Add `is_active` as a field in the FarmerAdmin form
    is_active = forms.ChoiceField(
        label="is_active",
        choices=[
            ("pending", "Pending"),
            ("approved", "Approved"),
            ("rejected", "Rejected"),
        ],
        required=False,
    )
    class Meta:
        model = Farmer
        fields = ['user', 'Fname']
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
            instance.user.save()
        if commit:
            instance.save()
        return instance


class BaseFarmerAdmin(FFUserAdmin):
    form = FarmerAdminForm
    list_display = FFUserAdmin.list_display + ('get_is_active','Fname', 'get_farm_location', 'get_farm_passport')
    search_fields = ('user__phone_number', 'user__email', 'Fname')
    def get_is_active(self, obj):
        return obj.user.is_active
    get_is_active.short_description = 'Is_active'
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
    # Display only Approved Farmers
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(user__is_active='approved')
    

class RejectedFarmerAdmin(BaseFarmerAdmin):
    # Display only Rejected Farmers
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(user__is_active='rejected')


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
        farmer.user.is_active = 'approved'
        farmer.save()
        farmer.user.save()
        messages.success(request, f"Farmer {farmer.user.first_name + ' ' + farmer.user.last_name} has been approved.")
        return redirect(request.META.get('HTTP_REFERER'))
    # Reject action
    def reject_farmer(self, request, farmer_id):
        farmer = Farmer.objects.get(id=farmer_id)

        if request.method == 'POST':
            reason = request.POST.get('reason', '').strip()
            previous_url = request.POST.get('previous_url', '/admin/')  # Default fallback

            if reason:
                farmer.user.is_active = 'rejected'
                farmer.user.save()
                farmer.save()
                # EMAIL HERE!!
                subject = 'Farmer Registration: Rejected'
                message = f"Hi {farmer.user.first_name},\n\nYour registration was rejected by admin: {reason}."
                try:
                    send_mail(subject, message, 'toksanbayamira4@gmail.com', [farmer.user.email],fail_silently=False)
                except BadHeaderError:
                    print("Invalid header found.")
                except SMTPException as e:
                    print(f"SMTP error occurred: {e}")
                except Exception as e:
                    print(f"An error occurred: {e}")
        
                #send_mail(subject, message, 'toksanbayamira4@gmail.com', [farmer.user.email], fail_silently=False)
                messages.success(request, f"Farmer {farmer.user.first_name + ' ' + farmer.user.last_name} has been rejected for reason: {reason}.")
            else:
                messages.error(request, "Rejection reason cannot be empty.")

            return redirect(previous_url)

        # Include the previous URL in the form
        csrf_token = get_token(request)
        previous_url = request.META.get('HTTP_REFERER', '/admin/')
        html = format_html(
            """
            <form method="post" style="margin: 10px;">
                <input type="hidden" name="csrfmiddlewaretoken" value="{}" />
                <input type="hidden" name="previous_url" value="{}" />
                <textarea name="reason" rows="4" cols="40" placeholder="Enter rejection reason"></textarea>
                <br><button type="submit" class="button">Submit</button>
            </form>
            """,
            csrf_token,
            previous_url
        )
        return HttpResponse(html)

    # Display only Pending Farmers
    def get_queryset(self, request):
        queryset = super().get_queryset(request)
        return queryset.filter(user__is_active = 'pending')

