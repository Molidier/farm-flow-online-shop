from django.db import models
from users.models import Farmer, User  # Import User instead of Admin

class Farm(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE)
    farm_name = models.CharField(max_length=100)
    farm_passport = models.CharField(max_length=50, unique=True)
    farm_location = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        return self.farm_name


class Product(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    category = models.CharField(max_length=50, null=True, blank=True)
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.TextField(null=True, blank=True)
    #image file

    def __str__(self):
        return self.name
'''

'''

class Inventory(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    availability = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.product.name} - {self.quantity}"


class Cart(models.Model):
    buyer = models.ForeignKey('users.Buyer', on_delete=models.CASCADE)
    created_date = models.DateField()
    cart_status = models.CharField(max_length=50, choices=[('Active', 'Active'), ('Inactive', 'Inactive')])

    def __str__(self):
        return f"Cart {self.id} for {self.buyer.user.first_name}"


class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    verified = models.BooleanField(default=False)
    
    # Reference User model, filter by role="admin" when needed
    admin = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL, limit_choices_to={'role': 'admin'})

    def __str__(self):
        return f"{self.quantity} of {self.product.name} in cart {self.cart.id}"
