from decimal import Decimal
from typing import Optional
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.utils import timezone
from datetime import datetime, timedelta



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
    is_staff = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_superuser = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = "phone_number"
    REQUIRED_FIELDS = ["email", "first_name", "last_name"]



class Buyer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    deliveryAdress=models.CharField()
    #ABM -> added by Moldir
    payment_method = models.CharField(max_length=50, null=True, blank=True)
   


class Farmer(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    #Q -> do we really need it?
    Fname=models.CharField()
    #ABM
    farm_location = models.CharField(max_length=255, default="Unknown farm location", null=True, blank=True)
    verified = models.BooleanField(default=False)



class OTP(models.Model):
    #Q -> should not we also add email verification?
    phone_number = models.CharField(max_length=15)
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def is_valid(self):
        return (timezone.now() - self.created_at) < timedelta(minutes=5)


