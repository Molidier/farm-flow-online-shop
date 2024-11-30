import logging
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Product, ProductImage, Inventory, Farm, Category, CartItem, Cart
from .serializers import ProductSerializer, InventorySerializer, FarmSerializer, CategorySerializer , CartSerializer, CartItemSerializer
from .permissions import IsFarmer
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.exceptions import ValidationError
from rest_framework.permissions import AllowAny
from users.models import User, Buyer
from users.serializers import BuyerSerializer

# Set up a logger
logger = logging.getLogger(__name__)

# Product Views
class CategoryListCreateAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def get(self, request, *args, **kwargs):
        # Retrieve all categories
        categories = Category.objects.all()
        serializer = CategorySerializer(categories, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        # Create a new category
        serializer = CategorySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# View to create a new product

# View to create a new product associated with a farm
class ProductCreateAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request, *args, **kwargs):
        try:
            # Retrieve the single farm associated with the authenticated farmer
            farm = Farm.objects.get(farmer=request.user.farmer)
            logger.info(f"Attempting to create a product for farm ID: {farm.id}")
            
            # Pass the farm instance directly to the serializer's save method
            serializer = ProductSerializer(data=request.data, context={'request': request})
            if serializer.is_valid():
                product = serializer.save(farm=farm)  # Set farm explicitly here
                #product = serializer.save(farm = Farm.objects.get(farm_name='farm1'))  # TEST CODE
                logger.info("Product created successfully")
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            
            logger.warning("Failed to create product due to validation errors")
            logger.debug(serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except Farm.DoesNotExist:
            logger.warning(f"No farm found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "No farm found for this farmer."}, status=status.HTTP_400_BAD_REQUEST)

# Remaining views for ProductDetailAPIView, Inventory Views, and Farm Views stay largely the same
# View to retrieve, update, or delete a specific product
class ProductDetailAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def get(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk, farm__farmer=request.user.farmer)
            logger.info(f"Retrieved product ID: {pk} for farmer ID: {request.user.farmer.id}")
            serializer = ProductSerializer(product)
            return Response(serializer.data)
        except Product.DoesNotExist:
            logger.warning(f"Product ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk, farm__farmer=request.user.farmer)
            data = request.data.copy()
            data['farm'] = request.user.farmer.id
            logger.info(f"Updating product ID: {pk} for farm ID: {data['farm']}")
            
            serializer = ProductSerializer(product, data=data, partial=True)
            if serializer.is_valid():
                serializer.save()
                logger.info("Product updated successfully")
                return Response(serializer.data)
            
            logger.warning("Failed to update product due to validation errors")
            logger.debug(serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Product.DoesNotExist:
            logger.warning(f"Product ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

    def delete(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk, farm__farmer=request.user.farmer)
            product.delete()
            logger.info(f"Product ID: {pk} deleted for farmer ID: {request.user.farmer.id}")
            return Response({"message": "Product deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Product.DoesNotExist:
            logger.warning(f"Product ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

# Inventory Views

# View to list all inventory items for a farmer's farm or create a new inventory item
class FarmerInventoryListCreateView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def get(self, request, *args, **kwargs):
        try:
            farm = Farm.objects.get(farmer=request.user.farmer)
            inventory_items = Inventory.objects.filter(farm=farm)
            serializer = InventorySerializer(inventory_items, many=True)
            logger.info(f"Retrieved inventory items for farm ID: {farm.id}")
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Farm.DoesNotExist:
            logger.warning(f"Farm not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Farm not found"}, status=status.HTTP_404_NOT_FOUND)

    def post(self, request, *args, **kwargs):
        try:
            # Use the single farm associated with the authenticated farmer
            farm = Farm.objects.get(farmer=request.user.farmer)
            logger.info(f"Attempting to create inventory item for farm ID: {farm.id}")

            # Pass context to include request in serializer
            serializer = InventorySerializer(data=request.data, context={'request': request})
            if serializer.is_valid():
                serializer.save(farm=farm)  # Explicitly set farm here if necessary
                logger.info("Inventory item created successfully")
                return Response(serializer.data, status=status.HTTP_201_CREATED)

            logger.warning("Failed to create inventory item due to validation errors")
            logger.debug(serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        except Farm.DoesNotExist:
            logger.warning(f"No farm found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "No farm found for this farmer."}, status=status.HTTP_400_BAD_REQUEST)

        
# View to retrieve, update, or delete a specific inventory item
class InventoryDetailUpdateDeleteView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def get(self, request, pk, *args, **kwargs):
        try:
            inventory_item = Inventory.objects.get(pk=pk, farm__farmer=request.user.farmer)
            serializer = InventorySerializer(inventory_item)
            logger.info(f"Retrieved inventory item ID: {pk} for farmer ID: {request.user.farmer.id}")
            return Response(serializer.data)
        except Inventory.DoesNotExist:
            logger.warning(f"Inventory item ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Inventory item not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, pk, *args, **kwargs):
        try:
            inventory_item = Inventory.objects.get(pk=pk, farm__farmer=request.user.farmer)
            serializer = InventorySerializer(inventory_item, data=request.data, partial=True, context={"request": request})
            if serializer.is_valid():
                serializer.save()
                logger.info("Inventory item updated successfully")
                return Response(serializer.data)
            logger.warning("Failed to update inventory item due to validation errors")
            logger.debug(serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Inventory.DoesNotExist:
            logger.warning(f"Inventory item ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Inventory item not found"}, status=status.HTTP_404_NOT_FOUND)

    def delete(self, request, pk, *args, **kwargs):
        try:
            inventory_item = Inventory.objects.get(pk=pk, farm__farmer=request.user.farmer)
            inventory_item.delete()
            logger.info(f"Inventory item ID: {pk} deleted for farmer ID: {request.user.farmer.id}")
            return Response({"message": "Inventory item deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Inventory.DoesNotExist:
            logger.warning(f"Inventory item ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Inventory item not found"}, status=status.HTTP_404_NOT_FOUND)


# Farm Views

# View to create a new farm, retrieve farm details, or update farm information
class FarmListCreateAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def post(self, request, *args, **kwargs):
        data = request.data.copy()
        data['farmer'] = request.user.farmer.id
        logger.info(f"Attempting to create a farm for farmer ID: {request.user.farmer.id}")
        
        serializer = FarmSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            logger.info("Farm created successfully")
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        logger.warning("Failed to create farm due to validation errors")
        logger.debug(serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request, *args, **kwargs):
        farms = Farm.objects.filter(farmer=request.user.farmer)
        serializer = FarmSerializer(farms, many=True)
        logger.info(f"Retrieved farms for farmer ID: {request.user.farmer.id}")
        return Response(serializer.data, status=status.HTTP_200_OK)

class FarmDetailUpdateDeleteAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def get(self, request, pk, *args, **kwargs):
        try:
            farm = Farm.objects.get(pk=pk, farmer=request.user.farmer)
            serializer = FarmSerializer(farm)
            logger.info(f"Retrieved farm ID: {pk} for farmer ID: {request.user.farmer.id}")
            return Response(serializer.data)
        except Farm.DoesNotExist:
            logger.warning(f"Farm ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Farm not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, pk, *args, **kwargs):
        try:
            farm = Farm.objects.get(pk=pk, farmer=request.user.farmer)
            data = request.data.copy()
            logger.info(f"Updating farm ID: {pk} for farmer ID: {request.user.farmer.id}")
            
            serializer = FarmSerializer(farm, data=data, partial=True)
            if serializer.is_valid():
                serializer.save()
                logger.info("Farm updated successfully")
                return Response(serializer.data)
            
            logger.warning("Failed to update farm due to validation errors")
            logger.debug(serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Farm.DoesNotExist:
            logger.warning(f"Farm ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Farm not found"}, status=status.HTTP_404_NOT_FOUND)

    def delete(self, request, pk, *args, **kwargs):
        try:
            farm = Farm.objects.get(pk=pk, farmer=request.user.farmer)
            farm.delete()
            logger.info(f"Farm ID: {pk} deleted for farmer ID: {request.user.farmer.id}")
            return Response({"message": "Farm deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Farm.DoesNotExist:
            logger.warning(f"Farm ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Farm not found"}, status=status.HTTP_404_NOT_FOUND)
        
# Endpoint to get the list of farms for the authenticated farmer
class FarmerFarmListAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def get(self, request, *args, **kwargs):
        farms = Farm.objects.filter(farmer=request.user.farmer)
        serializer = FarmSerializer(farms, many=True)
        logger.info(f"Retrieved farm list for farmer ID: {request.user.farmer.id}")
        return Response(serializer.data, status=status.HTTP_200_OK)



#cart views
class CartView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access their cart
    
    #to get the cart of the current user
    def get(self, request, *args, **kwargs): 
        try:
            cart = Cart.objects.get(buyer=request.user.buyer)
            serializer = CartSerializer(cart)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Cart.DoesNotExist:
            return Response({"error": "Cart not found."}, status=status.HTTP_404_NOT_FOUND)

    #to make a new cart
    def post(self, request, *args, **kwargs):
        serializer = CartSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save(buyer=request.user.buyer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        print(request.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CartDeleteView(APIView):
    permission_classes = [IsAuthenticated]  # only authenticated users can delete their cart
    def delete(self, request, *args, **kwargs):
        try:
            cart = Cart.objects.get(buyer=request.user.buyer) #get the cart
            cart.items.all().delete() #delete items
            # Or delete the cart entirely
            cart.delete()

            return Response({"message": "Cart deleted successfully."}, status=status.HTTP_204_NO_CONTENT)
        except Cart.DoesNotExist:
            return Response({"error": "Cart not found."}, status=status.HTTP_404_NOT_FOUND)

   
class CartItemView(APIView):
    permission_classes = [IsAuthenticated]  # only authenticated users can add items to their cart
    #to add products to the cart
    def post(self, request, *args, **kwargs):
        cart_id = request.data.get('cart')
        product_id = request.data.get('product')
        quantity = request.data.get('quantity')

        try:
            cart = Cart.objects.get(id=cart_id, buyer=request.user.buyer)  # get the user's cart
        except Cart.DoesNotExist:
            return Response({"error": "Cart not found or you do not have access to this cart."}, status=status.HTTP_404_NOT_FOUND)
        
        # Check if the product is already in the cart
        existing_item = CartItem.objects.filter(cart=cart, product_id=product_id).first()
        if existing_item:
            # If item exists, update quantity
            existing_item.quantity += quantity
            existing_item.save()
            return Response(CartItemSerializer(existing_item).data, status=status.HTTP_200_OK)
        
        # If item doesn't exist, create a new CartItem
        data = {
            "cart": cart.id,
            "product": product_id,
            "quantity": quantity,
        }
        
        serializer = CartItemSerializer(data=data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    
        
class CartItemDeleteView(APIView):
    permission_classes = [IsAuthenticated]  # only authenticated users can delte their items
    def delete(self, request, *args, **kwargs):
        try:
            # Ensure the cart item exists and belongs to the authenticated user's cart
            cart_item = CartItem.objects.get(id=kwargs['item_id'], cart__buyer=request.user.buyer)
            cart_item.delete()
            return Response({"message": "Item removed successfully"}, status=status.HTTP_204_NO_CONTENT)
        except CartItem.DoesNotExist:
            # Handle the case where the item does not exist
            return Response({"error": "Cart item not found or you do not have permission to delete it."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            # Handle unexpected errors
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


        