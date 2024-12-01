from django.db import models
from users.models import Farmer, User  # Importing Farmer and User models from users app


class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)  # Unique name for each category
    description = models.TextField(blank=True, null=True)  # Optional description for each category

    def __str__(self):
        return self.name


class Product(models.Model):
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE)  # Direct link to the farmer
    category = models.ForeignKey(Category, on_delete=models.SET_DEFAULT, default=1)  # FK with default value
    name = models.CharField(max_length=100)  # Name of the product
    price = models.DecimalField(max_digits=10, decimal_places=2)  # Product price with up to 2 decimal places
    description = models.TextField(null=True, blank=True)  # Optional product description
    image = models.ImageField(upload_to='product_images/', null=True, blank=True)  # Optional image for the product
    quantity = models.FloatField(default=0)  # Quantity in kilograms (kg)

    def __str__(self):
        return self.name


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
    admin = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL, limit_choices_to={'role': 'admin'})

    def __str__(self):
        return f"{self.quantity} of {self.product.name} in cart {self.cart.id}"
