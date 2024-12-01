from decimal import Decimal
from typing import Optional
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from datetime import datetime, timedelta
from django.db.models.signals import post_save
from django.dispatch import receiver


class UserManager(BaseUserManager):
    def create_user(self, email, phone_number, first_name, last_name, password=None, **extra_fields):
        if not all([email, phone_number, first_name, last_name]):
            raise ValueError("All required fields must be provided.")

        email = self.normalize_email(email)
        user = self.model(
            email=email,
            phone_number=phone_number,
            first_name=first_name,
            last_name=last_name,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, phone_number, first_name, last_name, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields["role"] = "admin"
        return self.create_user(email, phone_number, first_name, last_name, password=password, **extra_fields)
class User(AbstractBaseUser, PermissionsMixin):
    STATUS_CHOICES = [
        ("pending", "Pending"),
        ("approved", "Approved"),
        ("rejected", "Rejected"),
    ]

    ROLE_CHOICES = [
        ("admin", "Admin"),
        ("farmer", "Farmer"),
        ("buyer", "Buyer"),
    ]

    first_name = models.CharField(max_length=60)
    last_name = models.CharField(max_length=60)
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    phone_number = models.CharField(max_length=15, unique=True)
    image = models.ImageField(upload_to='farmer_profile_pictures/', null=True, blank=True) 
    is_staff = models.BooleanField(default=False)
    is_active = models.CharField(max_length=10, choices=STATUS_CHOICES, default="pending")
    is_superuser = models.BooleanField(default=False)
    image = models.ImageField(upload_to='profile_images/', null=True, blank=True)  # Add image field

    objects = UserManager()

    USERNAME_FIELD = "phone_number"
    REQUIRED_FIELDS = ["email", "first_name", "last_name"]



class Buyer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    deliveryAdress = models.CharField(max_length=255, default="Default Address")


class Farmer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    Fname = models.CharField(max_length=60)
    farm_location = models.CharField(max_length=255, default="not specified")  # Add farm_location
    farm_size = models.DecimalField(max_digits=10, decimal_places=2, default=0)  # Add farm_size (in acres, for example)



# Proxy model for Verified Farmers
class ApprovedFarmer(Farmer):
    class Meta:
        proxy = True
        verbose_name = "Approved Farmer"
        verbose_name_plural = "Approved Farmers"

# Proxy model for Verified Farmers
class RejectedFarmer(Farmer):
    class Meta:
        proxy = True
        verbose_name = "Rejected Farmer"
        verbose_name_plural = "Rejected Farmers"

# Proxy model for Unverified Farmers
class PendingFarmer(Farmer):
    class Meta:
        proxy = True
        verbose_name = "Pending Farmer"
        verbose_name_plural = "Pending Farmers"
        
# Signal to set `is_active` to 'Rejected' for farmers
@receiver(post_save, sender=Farmer)
def set_farmer_inactive(sender, instance, created, **kwargs):
    if created:
        instance.user.is_active = 'pending'
        instance.user.save()

class OTP(models.Model):
    email = models.EmailField()
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    def is_valid(self):
        return (timezone.now() - self.created_at) < timedelta(minutes=5)
