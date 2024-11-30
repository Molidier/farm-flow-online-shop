from django.db import models
from users.models import Farmer, User  # Importing Farmer and User models from users app

# Category model to store different product categories for categorization
class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)  # Unique name for each category
    description = models.TextField(blank=True, null=True)  # Optional description for each category

    def __str__(self):
        # Returns the category name when the Category object is represented as a string
        return self.name


# Farm model to store details about a farm owned by a farmer
class Farm(models.Model):
    farmer = models.OneToOneField(Farmer, on_delete=models.CASCADE)
    farm_name = models.CharField(max_length=100)
    farm_passport = models.CharField(max_length=50, unique=True)
    farm_location = models.CharField(max_length=255, null=True, blank=True)

    def __str__(self):
        # Returns the farm name when the Farm object is represented as a string
        return self.farm_name
    

# Product model representing an individual product from a farm
class Product(models.Model):
    # Each product is linked to a farm; deleting the farm deletes associated products
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    category = models.ForeignKey(Category, on_delete=models.SET_DEFAULT, default=1)  # FK with default value
    name = models.CharField(max_length=100)  # Name of the product
    price = models.DecimalField(max_digits=10, decimal_places=2)  # Product price with up to 2 decimal places
    description = models.TextField(null=True, blank=True)  # Optional product description
    #image = models.ImageField(upload_to='product_images/', null=True, blank=True)  # Optional image for the product

    def __str__(self):
        # Returns the product name when the Product object is represented as a string
        return self.name

class ProductImage(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='product_images/')

# Inventory model for tracking stock levels of each product in a farm
class Inventory(models.Model):
    farm = models.ForeignKey(Farm, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.IntegerField()
    availability = models.BooleanField(default=True)

    def __str__(self):
        # Returns a string showing the product name and quantity in inventory
        return f"{self.product.name} - {self.quantity}"


# Cart model representing a shopping cart for a buyer
class Cart(models.Model):
    buyer = models.ForeignKey('users.Buyer', on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def total_price(self):
        return sum(item.subtotal for item in self.items.all())
    def __str__(self):
        # Returns a string showing the cart ID and the buyer's first name
        return f"Cart {self.id} for {self.buyer.user.first_name}"


# CartItem model representing each product added to a cart by a buyer
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name='items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, editable=False)
    verified = models.BooleanField(default=False)

    def save(self, *args, **kwargs):
        if not self.price_per_unit:  #it only sets if price_per_unit is not already set
            self.price_per_unit = self.product.price
        self.subtotal = self.price_per_unit * self.quantity
        super().save(*args, **kwargs)

    def __str__(self):
        # Returns a string showing the quantity and product name in the cart
        return f"{self.quantity} of {self.product.name} in cart {self.cart.id}"
    
