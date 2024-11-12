from rest_framework import serializers
from .models import Orders, OrderProduct, Payment, Delivery
from users.models import Buyer
from products.models import Product


from rest_framework import serializers
from .models import Orders, OrderProduct, Payment, Delivery
from products.serializers import ProductSerializer

# Serializer for OrderProduct details within each order
class OrderProductSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)  # Include product details

    class Meta:
        model = OrderProduct
        fields = ['id', 'product', 'quantity_ordered', 'price_at_purchase']


# Orders Serializer to include nested order product details
class OrdersSerializer(serializers.ModelSerializer):
    order_products = OrderProductSerializer(source='orderproduct_set', many=True, read_only=True)  # Nested product details

    class Meta:
        model = Orders
        fields = ['id', 'buyer', 'order_date', 'order_status', 'total_amount', 'order_products']


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
