from django.db import models
from users.models import Farmer, User, Buyer  # Importing Farmer and User models from users app
from decimal import Decimal


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
    quantity = models.DecimalField(max_digits=10, decimal_places=2, default=1)  # Quantity in kilograms (kg)

    def __str__(self):
        return self.name
    
    def update_quantity(self, change):
        new_quantity = self.quantity + change
        if new_quantity < 0.0:
            raise ValueError(f"Not enough stock for {self.name}. Only {self.quantity:.2f} units available.")
        self.quantity = new_quantity
        self.save()


# cart model representing a shopping cart for a buyer
class Cart(models.Model):
    buyer = models.ForeignKey(Buyer, on_delete=models.CASCADE)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def total_price(self):
        return sum(
            Decimal(str(item.subtotal)) for item in self.items.all()
        )
    
    def __str__(self):
        # Returns a string showing the cart ID and the buyer's first name
        return f"Cart {self.id} for {self.buyer.user.first_name}"

# CartItem model representing each product added to a cart by a buyer
class CartItem(models.Model):
    cart = models.ForeignKey(Cart, related_name='items', on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.DecimalField(max_digits=10, decimal_places=2, default=1.00) 
    price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, editable=False)
    is_bargain_requested = models.BooleanField(default=False)  # True if the buyer requests a new price
    requested_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    bargain_status = models.CharField(
        max_length=20,
        choices=[('PENDING', 'Pending'), ('ACCEPTED', 'Accepted'), ('REJECTED', 'Rejected')],
        default='PENDING'
    )

    def save(self, *args, **kwargs):
        self.price_per_unit = self.product.price
        subtotal = self.quantity * self.price_per_unit
        self.subtotal=subtotal.quantize(Decimal("0.01"))
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.quantity} of {self.product.name} in cart {self.cart.id}"
    
