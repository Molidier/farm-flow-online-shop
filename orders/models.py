from django.db import models
from users.models import Buyer
from products.models import Product, Cart

class Order(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('CONFIRMED', 'Confirmed'),
        ('SHIPPED', 'Shipped'),
        ('DELIVERED', 'Delivered'),
        ('CANCELED', 'Canceled'),
    ]

    PAYMENT_CHOICES = [
        ('PENDING', 'Pending'),
        ('PAID', 'Paid'),
        ('FAILED', 'Failed'),
    ]

    cart = models.OneToOneField('products.Cart', on_delete=models.CASCADE, related_name='order')
    buyer = models.ForeignKey('users.Buyer', on_delete=models.CASCADE, related_name='orders')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_CHOICES, default='PENDING')
    total_price = models.DecimalField(max_digits=10, decimal_places=2, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def save(self, *args, **kwargs):
        self.total_price = self.cart.total_price()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Order {self.id} by {self.buyer.user.username}"


class Payment(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    payment_date = models.DateField()
    payment_method = models.CharField(max_length=50)
    payment_amount = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Payment for order {self.order.id}"


class Delivery(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE)
    delivery_type = models.CharField(max_length=50, choices=[('Home Delivery', 'Home Delivery'), ('Pickup Point', 'Pickup Point')])
    delivery_date = models.DateField()
    delivery_status = models.CharField(max_length=50)
    delivery_cost = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Delivery for order {self.order.id}"
