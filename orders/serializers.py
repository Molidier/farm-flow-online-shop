from rest_framework import serializers
from .models import Order, Payment, Delivery
from products.models import Product, Cart
from users.models import Buyer

class OrderSerializer(serializers.ModelSerializer):
    cart_id = serializers.PrimaryKeyRelatedField(source='cart.id', read_only=True)
    buyer_id = serializers.PrimaryKeyRelatedField(source='buyer.id', read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'cart_id', 'buyer_id', 'status', 'payment_status', 'total_price', 'created_at', 'updated_at']
        read_only_fields = ['total_price', 'created_at', 'updated_at']

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['id', 'order', 'payment_date', 'payment_method', 'payment_amount']

class DeliverySerializer(serializers.ModelSerializer):
    class Meta:
        model = Delivery
        fields = ['id', 'order', 'delivery_type', 'delivery_date', 'delivery_status', 'delivery_cost']

