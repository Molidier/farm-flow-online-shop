from rest_framework import serializers
from .models import Product,Category, Cart, CartItem
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


#cart implementation

class CartItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)  # Display the product name
    price_per_unit = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)  # Display price per unit
    
    class Meta:
        model = CartItem
        fields = ['id', 'product', 'quantity', 'price_per_unit', 'subtotal', 'product_name', 
                  'is_bargain_requested', 'requested_price', 'bargain_status']
        read_only_fields = ['subtotal', 'price_per_unit', 'bargain_status']

    def validate_product(self, value):
        # Ensure product exists
        try:
            product = Product.objects.get(id=value.id)
        except Product.DoesNotExist:
            raise serializers.ValidationError("Product does not exist.")
        return value
    
    def validate_quantity(self, value):
        # Ensure quantity is positive
        if value <= 0:
            raise serializers.ValidationError("Quantity must be greater than 0.")
        return value
    
    def update(self, instance, validated_data):
        # Handle bargain-related updates
        if 'requested_price' in validated_data:
            instance.is_bargain_requested = True
            instance.bargain_status = 'PENDING'
            instance.requested_price = validated_data['requested_price']
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        return instance

class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True)  # Nested serializer for cart items
    
    class Meta:
        model = Cart
        fields = ['id', 'buyer', 'is_active', 'created_at', 'updated_at', 'items']
        read_only_fields = ['buyer', 'is_active', 'created_at', 'updated_at']
    
    def create(self, validated_data):
        """Create a new cart and associated cart items."""
        items_data = validated_data.pop('items')
        cart = Cart.objects.create(**validated_data)
        for item_data in items_data:
            CartItem.objects.create(cart=cart, **item_data)
        return cart
    
    def update(self, instance, validated_data):
        """Update existing cart and associated cart items."""
        items_data = validated_data.pop('items')
        
        # Update cart fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        # Update or create cart items
        for item_data in items_data:
            item_id = item_data.get('id')
            if item_id:  # If item already exists in the cart
                item = CartItem.objects.get(id=item_id, cart=instance)
                item.quantity = item_data['quantity']
                item.save()
            else:  # If it's a new item, create it
                CartItem.objects.create(cart=instance, **item_data)
        return instance
    
    def to_representation(self, instance):
        """Customizing the output."""
        representation = super().to_representation(instance)
        # Calculate total price using the total_price method from Cart model
        representation['total_price'] = instance.total_price()
        return representation


