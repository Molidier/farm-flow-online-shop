from rest_framework import serializers
from .models import Farm, Product, Inventory, Cart, CartItem

# Farm Serializer
class FarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farm
        fields = ['id', 'farmer', 'farm_name', 'farm_passport', 'farm_location']
        read_only_fields = ['id']


# Product Serializer
class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ['id', 'farm', 'category', 'name', 'price', 'description']
        read_only_fields = ['id']


# Inventory Serializer
class InventorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Inventory
        fields = ['id', 'farm', 'product', 'quantity', 'availability']
        read_only_fields = ['id']


# Cart Serializer
class CartSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cart
        fields = ['id', 'buyer', 'created_date', 'cart_status']
        read_only_fields = ['id']


# CartItem Serializer
class CartItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = CartItem
        fields = ['id', 'cart', 'product', 'quantity', 'price_per_unit', 'verified', 'admin']
        read_only_fields = ['id']
