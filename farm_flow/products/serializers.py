from rest_framework import serializers
from .models import Farm, Product, Inventory, Cart, CartItem, Category

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


# Product Serializer, updated to use Category as a ForeignKey
class ProductSerializer(serializers.ModelSerializer):
    farm = serializers.PrimaryKeyRelatedField(read_only=True)  # Read-only farm reference
    category = serializers.PrimaryKeyRelatedField(queryset=Category.objects.all())  # Allows selection of category by ID

    class Meta:
        model = Product
        fields = ['id', 'farm', 'category', 'name', 'price', 'description', 'image']
        read_only_fields = ['id', 'farm']

    def create(self, validated_data):
        # Retrieve the farm associated with the authenticated farmer from the request context
        request = self.context.get("request")
        if request and hasattr(request.user, "farmer"):
            try:
                validated_data["farm"] = Farm.objects.get(farmer=request.user.farmer)
            except Farm.DoesNotExist:
                raise serializers.ValidationError("No farm found for this farmer.")
        
        # Create the Product with the associated farm and selected category
        return super().create(validated_data)


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
