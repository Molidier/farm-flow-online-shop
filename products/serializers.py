from rest_framework import serializers
from .models import Product, Cart, CartItem, Category
from users.models import Farmer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'description']


class ProductSerializer(serializers.ModelSerializer):
    farmer = serializers.PrimaryKeyRelatedField(queryset=Farmer.objects.all())  # Allow setting farmer ID
    category = serializers.PrimaryKeyRelatedField(queryset=Category.objects.all())  # Allow setting category ID

    class Meta:
        model = Product
        fields = ['id', 'farmer', 'category', 'name', 'price', 'description', 'image', 'quantity']
        read_only_fields = ['id']


class CartSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cart
        fields = ['id', 'buyer', 'created_date', 'cart_status']


class CartItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = CartItem
        fields = ['id', 'cart', 'product', 'product_name', 'quantity', 'price_per_unit', 'verified']
        read_only_fields = ['id', 'product_name']
