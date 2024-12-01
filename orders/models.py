from django.db import models, transaction
from users.models import Buyer
from products.models import Product, Cart

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
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    payment_status = models.CharField(max_length=20, choices=PAYMENT_CHOICES, default='PENDING')
    total_price = models.DecimalField(max_digits=10, decimal_places=2, editable=False)
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
    
    def calculate_total_price(self):
        delivery_cost = self.delivery.delivery_cost if hasattr(self, 'delivery') else 0
        return self.cart.total_price() + delivery_cost

    def save(self, *args, **kwargs):
        self.total_price = self.calculate_total_price()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Order {self.id} by {self.buyer.user.username}"


class Payment(models.Model):
    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name='payment')
    payment_date = models.DateField()
    payment_method = models.CharField(max_length=50)
    payment_amount = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Payment for order {self.order.id}"


class Delivery(models.Model):
    order = models.OneToOneField(Order, on_delete=models.CASCADE, related_name='delivery')
    delivery_type = models.CharField(max_length=50, choices=[('Home Delivery', 'Home Delivery'), ('Pickup Point', 'Pickup Point')])
    delivery_date = models.DateField()
    delivery_status = models.CharField(max_length=50)
    delivery_cost = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Delivery for order {self.order.id}"
