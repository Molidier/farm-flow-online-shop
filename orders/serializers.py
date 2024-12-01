from rest_framework import serializers
from .models import Order
from products.models import Product, Cart
from products.serializers import CartItemSerializer
from users.models import Buyer

class OrderSerializer(serializers.ModelSerializer):
    cart_id = serializers.PrimaryKeyRelatedField(source='cart.id', read_only=True)
    cart_items = CartItemSerializer(source='cart.items', many=True, read_only=True)
    buyer_id = serializers.PrimaryKeyRelatedField(source='buyer.id', read_only=True)

    class Meta:
        model = Order
        fields = ['id', 'cart_id', 'buyer_id','delivery_address', 'delivery_cost', 
                  'total_price', 'payment_method', 'status', 'payment_status', 
                  'delivery_type', 'delivery_date', 'created_at', 'updated_at', 'cart_items']
        read_only_fields = ['id', 'total_price', 'created_at', 'updated_at']

class OrderUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Order
        fields = ['status', 'payment_status']


