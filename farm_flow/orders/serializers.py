from rest_framework import serializers
from .models import Orders, OrderProduct, Payment, Delivery
from users.models import Buyer
from products.models import Product


class OrdersSerializer(serializers.ModelSerializer):
    class Meta:
        model = Orders
        fields = ['id', 'buyer', 'order_date', 'order_status', 'total_amount']
        read_only_fields = ['id']


class OrderProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderProduct
        fields = ['id', 'order', 'product', 'quantity_ordered', 'price_at_purchase']
        read_only_fields = ['id']


class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['id', 'order', 'payment_date', 'payment_method', 'payment_amount']
        read_only_fields = ['id']


class DeliverySerializer(serializers.ModelSerializer):
    class Meta:
        model = Delivery
        fields = ['id', 'order', 'delivery_type', 'delivery_date', 'delivery_status', 'delivery_cost']
        read_only_fields = ['id']
