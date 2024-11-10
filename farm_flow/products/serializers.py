from rest_framework import serializers
from .models import Farm, Product, Inventory, Cart, CartItem

# Farm Serializer
class FarmSerializer(serializers.ModelSerializer):
    # Adding a calculated field to display the number of products related to this farm
    product_count = serializers.IntegerField(source='product_set.count', read_only=True)
    
    class Meta:
        model = Farm
        # Fields to be serialized for the Farm model
        fields = ['id', 'farmer', 'farm_name', 'farm_passport', 'farm_location', 'product_count']
        read_only_fields = ['id', 'product_count']  # The farm ID and product count are read-only


# Product Serializer
class ProductSerializer(serializers.ModelSerializer):
    # Use ImageField to handle image uploads for the product
    image = serializers.ImageField(required=False, allow_null=True)  # Image is optional
    # Adding a calculated field for a short description (first 30 characters of the description)
    short_description = serializers.SerializerMethodField()

    class Meta:
        model = Product
        # Fields to be serialized for the Product model, including the optional image
        fields = ['id', 'farm', 'category', 'name', 'price', 'description', 'short_description', 'image']
        read_only_fields = ['id']  # The product ID is read-only

    def get_short_description(self, obj):
        # Returns a short version of the description (first 30 characters)
        return obj.description[:30] + '...' if obj.description and len(obj.description) > 30 else obj.description


# Inventory Serializer with additional fields and validation
class InventorySerializer(serializers.ModelSerializer):
    # Display the product name instead of only the product ID
    product_name = serializers.CharField(source='product.name', read_only=True)
    # Adding a calculated field to show total value (quantity * price)
    total_value = serializers.SerializerMethodField()

    class Meta:
        model = Inventory
        # Fields to be serialized for the Inventory model, including the product name and total value
        fields = ['id', 'farm', 'product', 'product_name', 'quantity', 'availability', 'total_value']
        # Make `id`, `farm`, and `product_name` read-only
        read_only_fields = ['id', 'product_name', 'total_value']

    def get_total_value(self, obj):
        # Calculates total value as quantity * price
        return obj.quantity * obj.product.price if obj.product else 0

    def validate(self, data):
        # Retrieve product and farm from data or instance
        product = data.get('product')
        farm = data.get('farm', getattr(self.instance, 'farm', None))

        # Ensure both product and farm are provided
        if product is None:
            raise serializers.ValidationError({"product": "This field is required."})
        if farm is None:
            raise serializers.ValidationError({"farm": "This field is required."})

        # Check that the product belongs to the specified farm
        if product.farm != farm:
            raise serializers.ValidationError("The product must belong to the specified farm.")

        return data



# Cart Serializer
class CartSerializer(serializers.ModelSerializer):
    # Adding a calculated field for the total price of all items in the cart
    total_price = serializers.SerializerMethodField()

    class Meta:
        model = Cart
        # Fields to be serialized for the Cart model, including total price
        fields = ['id', 'buyer', 'created_date', 'cart_status', 'total_price']
        read_only_fields = ['id', 'total_price']  # The cart ID and total price are read-only

    def get_total_price(self, obj):
        # Calculates total price of all items in the cart
        return sum(item.quantity * item.price_per_unit for item in obj.cartitem_set.all())


# CartItem Serializer
class CartItemSerializer(serializers.ModelSerializer):
    # Adding a nested representation of the product
    product_details = ProductSerializer(source='product', read_only=True)

    class Meta:
        model = CartItem
        # Fields to be serialized for each item in a cart, including product details
        fields = ['id', 'cart', 'product', 'product_details', 'quantity', 'price_per_unit', 'verified', 'admin']
        read_only_fields = ['id', 'product_details']  # The cart item ID and product details are read-only
