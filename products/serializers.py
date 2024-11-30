from rest_framework import serializers
from .models import Farm, Product, ProductImage, Inventory, Category
from .models import Cart , CartItem

# Category Serializer to handle category data
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'description']  # Fields to be serialized


# Farm Serializer for managing farm details
class FarmSerializer(serializers.ModelSerializer):
    class Meta:
        model = Farm
        fields = ['id', 'farmer', 'farm_name', 'farm_passport', 'farm_location']
        read_only_fields = ['id']

# Image of the Product Serializer
class ProductImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductImage
        fields = ['image']
    
# Product Serializer, updated to use Category as a ForeignKey
class ProductSerializer(serializers.ModelSerializer):
    farm = serializers.PrimaryKeyRelatedField(read_only=True)  # Read-only farm reference
    category = serializers.PrimaryKeyRelatedField(queryset=Category.objects.all())  # Allows selection of category by ID
    images = ProductImageSerializer(many=True, required=False)

    class Meta:
        model = Product
        fields = ['id', 'farm', 'category', 'name', 'price', 'description', 'images']
        read_only_fields = ['id', 'farm']

    def create(self, validated_data):
        # Retrieve the farm associated with the authenticated farmer from the request context
        request = self.context.get("request")
        if request and hasattr(request.user, "farmer"):
            try:
                validated_data["farm"] = Farm.objects.get(farmer=request.user.farmer)
            except Farm.DoesNotExist:
                raise serializers.ValidationError("No farm found for this farmer.")
        images = request.FILES.getlist('images')
        product = Product.objects.create(**validated_data)
        for image in images:
            ProductImage.objects.create(product=product, image=image)
        return product
        # Create the Product with the associated farm and selected category
        #return super().create(validated_data)

# Inventory Serializer to handle inventory data
class InventorySerializer(serializers.ModelSerializer):
    farm = serializers.PrimaryKeyRelatedField(read_only=True)
    product_name = serializers.CharField(source='product.name', read_only=True)

    class Meta:
        model = Inventory
        fields = ['id', 'farm', 'product', 'product_name', 'quantity', 'availability']
        read_only_fields = ['id', 'farm', 'product_name']

    def create(self, validated_data):
        # Get the farm from the request context if the user is a farmer
        request = self.context.get("request")
        if request and hasattr(request.user, "farmer"):
            try:
                validated_data["farm"] = Farm.objects.get(farmer=request.user.farmer)
            except Farm.DoesNotExist:
                raise serializers.ValidationError("No farm found for this farmer.")
        
        # Ensure the selected product belongs to the farmer's farm
        product = validated_data.get('product')
        farm = validated_data.get('farm')
        if product and product.farm != farm:
            raise serializers.ValidationError("The product must belong to the farmer's farm.")

        return super().create(validated_data)


#cart implementation

class CartItemSerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source='product.name', read_only=True)  # Display the product name
    price_per_unit = serializers.DecimalField(max_digits=10, decimal_places=2, read_only=True)  # Display price per unit
    
    class Meta:
        model = CartItem
        fields = ['id', 'product', 'quantity', 'price_per_unit', 'subtotal', 'product_name', 'verified']
    
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
        if self.instance and self.instance.subtotal != self.instance.price_per_unit * self.instance.quantity:
            raise serializers.ValidationError("Quantity cannot be updated after the subtotal has been changed.")
        return value
    

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
