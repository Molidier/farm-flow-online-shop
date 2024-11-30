from rest_framework import serializers
from .models import Product, Category
from users.models import Farmer  # Import the Farmer model

# Category Serializer to handle category data
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'description']  # Fields to be serialized


# Product Serializer, updated to use Farmer directly and include quantity field
class ProductSerializer(serializers.ModelSerializer):
    # Directly link the product to the farmer
    farmer = serializers.PrimaryKeyRelatedField(queryset=Farmer.objects.all())  # Direct link to Farmer
    category = serializers.PrimaryKeyRelatedField(queryset=Category.objects.all())  # Allows selection of category by ID

    class Meta:
        model = Product
        fields = ['id', 'farmer', 'category', 'name', 'price', 'description', 'image', 'quantity']
        read_only_fields = ['id']

    def create(self, validated_data):
        # Automatically link the authenticated farmer to the product
        request = self.context.get("request")
        if request and hasattr(request.user, "farmer"):
            validated_data["farmer"] = request.user.farmer  # Assign authenticated farmer
        
        # Create the Product with the associated farmer and category
        return super().create(validated_data)
