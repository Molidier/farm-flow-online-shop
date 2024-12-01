from django.db import models, transaction
from users.models import Buyer
from products.models import Product, Cart
from decimal import Decimal

class Order(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('CONFIRMED', 'Confirmed'),
        ('COMPLETED', 'Completed'),
        ('DELIVERED', 'Delivered'),
        ('CANCELED', 'Canceled'),
    ]


    PAYMENT_CHOICES = [
        ('PENDING', 'Pending'),
        ('PAID', 'Paid'),
        ('FAILED', 'Failed'),
    ]

    cart = models.OneToOneField(Cart, on_delete=models.CASCADE, related_name='order')
    buyer = models.ForeignKey(Buyer, on_delete=models.CASCADE, related_name='orders')
    delivery_address = models.CharField(max_length=255)
    delivery_cost = models.DecimalField(max_digits=10, decimal_places=2)
    total_price = models.DecimalField(max_digits=10, decimal_places=2, editable=False)
    payment_method = models.CharField(max_length=50, null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_CHOICES, default='PENDING')
    delivery_type = models.CharField(max_length=50, choices=[('Home Delivery', 'Home Delivery'), ('Pickup Point', 'Pickup Point')])
    delivery_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def process_order_with_atomicity(self):
        with transaction.atomic():
            for item in self.cart.items.all():
                product = item.product
                try:
                    # Deduct the quantity using the dedicated method
                    product.update_quantity(-item.quantity)
                except ValueError as e:
                    raise ValueError(
                        f"Failed to process order. {str(e)}"
                    )
            # mark the order as processed
            self.status = 'CONFIRMED'
            self.save()
    
    def calculate_delivery_cost(self):
        if self.delivery_type == "Home Delivery":
            self.delivery_cost = Decimal("1000.00")  # fee for home delivery
        elif self.delivery_type == "Pickup Point":
            self.delivery_cost = Decimal("500.00")  # fee for pickup
        else:
            self.delivery_cost = Decimal("0.00")

    
    def mark_as_paid(self):
        if self.payment_status != "PENDING":
            raise ValueError("Payment status cannot be updated.")
        self.payment_status = "PAID"
        self.save()

    def mark_as_delivered(self):
        if self.status != "CONFIRMED":
            raise ValueError("Order must be processing to be delivered.")
        self.status = "DELIVERED"
        self.save()

    def save(self, *args, **kwargs):
        self.calculate_delivery_cost()
        self.total_price = self.cart.total_price() + self.delivery_cost
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Order {self.id} by {self.buyer.user.username}"



