from django.db import models
from users.models import Buyer
from products.models import Product

class Orders(models.Model):
    buyer = models.ForeignKey(Buyer, on_delete=models.CASCADE)
    order_date = models.DateField()
    order_status = models.CharField(max_length=50, null=True, blank=True)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Order {self.id} by {self.buyer.name}"


class OrderProduct(models.Model):
    order = models.ForeignKey(Orders, on_delete=models.CASCADE)
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity_ordered = models.IntegerField()
    price_at_purchase = models.DecimalField(max_digits=10, decimal_places=2)

    class Meta:
        unique_together = ('order', 'product')

    def __str__(self):
        return f"{self.product.name} in order {self.order.id}"


class Payment(models.Model):
    order = models.ForeignKey(Orders, on_delete=models.CASCADE)
    payment_date = models.DateField()
    payment_method = models.CharField(max_length=50)
    payment_amount = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Payment for order {self.order.id}"


class Delivery(models.Model):
    order = models.ForeignKey(Orders, on_delete=models.CASCADE)
    delivery_type = models.CharField(max_length=50, choices=[('Home Delivery', 'Home Delivery'), ('Pickup Point', 'Pickup Point')])
    delivery_date = models.DateField()
    delivery_status = models.CharField(max_length=50)
    delivery_cost = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"Delivery for order {self.order.id}"
