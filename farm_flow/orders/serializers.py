from rest_framework import serializers
from .models import Orders, OrderProduct, Payment, Delivery
from products.models import Product
from users.models import Buyer

class OrderProductSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name')
    class Meta:
        model = OrderProduct
        fields = ['id', 'product', 'product_name', 'quantity_ordered', 'price_at_purchase']

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = ['id', 'order', 'payment_date', 'payment_method', 'payment_amount']

class DeliverySerializer(serializers.ModelSerializer):
    class Meta:
        model = Delivery
        fields = ['id', 'order', 'delivery_type', 'delivery_date', 'delivery_status', 'delivery_cost']

class OrdersSerializer(serializers.ModelSerializer):
    buyer_name = serializers.CharField(source='buyer.name')
    order_products = OrderProductSerializer(many=True)
    payment_details = PaymentSerializer(many=True)
    delivery_details = DeliverySerializer(many=True)

    class Meta:
        model = Orders
        fields = ['id', 'buyer', 'buyer_name', 'order_date', 'order_status', 'total_amount', 'order_products', 'payment_details', 'delivery_details']
