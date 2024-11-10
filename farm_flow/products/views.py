import logging
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Product, Inventory, Farm
from .serializers import ProductSerializer, InventorySerializer, FarmSerializer
from .permissions import IsFarmer

# Set up a logger
logger = logging.getLogger(__name__)

# Product Views

# View to create a new product
class ProductCreateAPIView(APIView):
    permission_classes = [IsAuthenticated, IsFarmer]

    def post(self, request, *args, **kwargs):
        data = request.data.copy()
        data['farm'] = request.user.farmer.id
        logger.info(f"Attempting to create a product for farm ID: {data['farm']}")
        
        serializer = ProductSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            logger.info("Product created successfully")
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        logger.warning("Failed to create product due to validation errors")
        logger.debug(serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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
        farm_id = request.data.get("farm")  # get farm ID from request data
        try:
            # Verify that the farm belongs to the authenticated farmer
            farm = Farm.objects.get(id=farm_id, farmer=request.user.farmer)
        except Farm.DoesNotExist:
            logger.warning(f"Invalid farm ID: {farm_id} for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Invalid farm selection"}, status=status.HTTP_400_BAD_REQUEST)

        data = request.data.copy()
        data["farm"] = farm.id
        logger.info(f"Attempting to create inventory item for farm ID: {farm.id}")

        serializer = InventorySerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            logger.info("Inventory item created successfully")
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        logger.warning("Failed to create inventory item due to validation errors")
        logger.debug(serializer.errors)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

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
            # Retrieve the inventory item with the given `pk` that belongs to a farm owned by the current farmer
            inventory_item = Inventory.objects.get(pk=pk, farm__farmer=request.user.farmer)
            data = request.data.copy()
            
            # Set `farm` in the request data to the farm associated with the inventory item
            data['farm'] = inventory_item.farm.id
            
            logger.info(f"Updating inventory item ID: {pk} for farm ID: {data['farm']}")
            
            serializer = InventorySerializer(inventory_item, data=data, partial=True)
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
