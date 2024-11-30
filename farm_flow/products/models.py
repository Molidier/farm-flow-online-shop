from django.db import models
from users.models import Farmer, User  # Importing Farmer and User models from users app

# Category model to store different product categories for categorization
class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)  # Unique name for each category
    description = models.TextField(blank=True, null=True)  # Optional description for each category

    def __str__(self):
        return self.name


# Product model representing an individual product directly linked to a farmer
class Product(models.Model):
    # Each product is now directly linked to a farmer (removed Farm reference)
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE, null = True)  # Direct link to the farmer
    category = models.ForeignKey(Category, on_delete=models.SET_DEFAULT, default=1)  # FK with default value
    name = models.CharField(max_length=100)  # Name of the product
    price = models.DecimalField(max_digits=10, decimal_places=2)  # Product price with up to 2 decimal places
    description = models.TextField(null=True, blank=True)  # Optional product description
    image = models.ImageField(upload_to='product_images/', null=True, blank=True)  # Optional image for the product
    quantity = models.FloatField(default=0)  # New field for quantity in kilograms (kg) as a double

    def __str__(self):
        return self.name


# Cart model representing a shopping cart for a buyer
class Cart(models.Model):
    buyer = models.ForeignKey('users.Buyer', on_delete=models.CASCADE)
    created_date = models.DateField()
    cart_status = models.CharField(max_length=50, choices=[('Active', 'Active'), ('Inactive', 'Inactive')])

    def __str__(self):
        # Returns a string showing the cart ID and the buyer's first name
        return f"Cart {self.id} for {self.buyer.user.first_name}"


# CartItem model representing each product added to a cart by a buyer
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    verified = models.BooleanField(default=False)
    admin = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL, limit_choices_to={'role': 'admin'})

    def __str__(self):
        # Returns a string showing the quantity and product name in the cart
        return f"{self.quantity} of {self.product.name} in cart {self.cart.id}"
