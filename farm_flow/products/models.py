from django.db import models
from users.models import Farmer, User  # Importing Farmer and User models from users app

# Farm model to store details about a farm owned by a farmer
class Farm(models.Model):
    # Links each farm to a specific farmer; if the farmer is deleted, their farm is also deleted (CASCADE).
    farmer = models.ForeignKey(Farmer, on_delete=models.CASCADE)
    farm_name = models.CharField(max_length=100)  # Name of the farm
    farm_passport = models.CharField(max_length=50, unique=True)  # Unique identifier for each farm
    farm_location = models.CharField(max_length=255, null=True, blank=True)  # Optional location field

    def __str__(self):
        # Returns the farm name when the Farm object is represented as a string
        return self.farm_name
    

# Product model representing an individual product from a farm
class Product(models.Model):
    # Each product is linked to a farm; deleting the farm deletes associated products
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    category = models.CharField(max_length=50, null=True, blank=True)  # Optional product category
    name = models.CharField(max_length=100)  # Name of the product
    price = models.DecimalField(max_digits=10, decimal_places=2)  # Product price with up to 2 decimal places
    description = models.TextField(null=True, blank=True)  # Optional product description
    image = models.ImageField(upload_to='product_images/', null=True, blank=True)  # Optional image for the product

    def __str__(self):
        # Returns the product name when the Product object is represented as a string
        return self.name


# Inventory model for tracking stock levels of each product in a farm
class Inventory(models.Model):
    # Each inventory item is linked to a farm and a product; deleting the farm or product deletes the inventory item
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()  # Number of items in stock
    availability = models.BooleanField(default=True)  # Whether the product is currently available

    def __str__(self):
        # Returns a string showing the product name and quantity in inventory
        return f"{self.product.name} - {self.quantity}"


# Cart model representing a shopping cart for a buyer
class Cart(models.Model):
    # Links each cart to a buyer; if the buyer is deleted, their cart is also deleted
    buyer = models.ForeignKey('users.Buyer', on_delete=models.CASCADE)
    created_date = models.DateField()  # Date when the cart was created
    cart_status = models.CharField(max_length=50, choices=[('Active', 'Active'), ('Inactive', 'Inactive')])  # Status of the cart

    def __str__(self):
        # Returns a string showing the cart ID and the buyer's first name
        return f"Cart {self.id} for {self.buyer.user.first_name}"


# CartItem model representing each product added to a cart by a buyer
class CartItem(models.Model):
    # Links each cart item to a cart and a product; deleting either deletes the cart item
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()  # Number of units of the product in the cart
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)  # Price of one unit at the time of addition
    verified = models.BooleanField(default=False)  # Whether the item has been verified (e.g., by an admin or process)

    # Optional link to an admin user; if the admin is deleted, this field is set to null
    admin = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL, limit_choices_to={'role': 'admin'})

    def __str__(self):
        # Returns a string showing the quantity and product name in the cart
        return f"{self.quantity} of {self.product.name} in cart {self.cart.id}"
