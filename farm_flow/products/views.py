from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Product, Category
from .serializers import ProductSerializer, CategorySerializer
from users.models import Farmer
import logging

# Set up a logger
logger = logging.getLogger(__name__)

# Category Views
class CategoryListCreateAPIView(APIView):
    permission_classes = [IsAuthenticated]  # Permission for authenticated users

    def get(self, request, *args, **kwargs):
        categories = Category.objects.all()
        serializer = CategorySerializer(categories, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request, *args, **kwargs):
        serializer = CategorySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


# Product Views
class ProductCreateAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            # Automatically link the authenticated farmer
            serializer = ProductSerializer(data=request.data, context={'request': request})
            if serializer.is_valid():
                serializer.save()  # Save the product with the authenticated farmer
                logger.info("Product created successfully")
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            
            logger.warning("Failed to create product due to validation errors")
            logger.debug(serializer.errors)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            logger.error(f"Error creating product: {e}")
            return Response({"error": "An error occurred while creating the product."}, status=status.HTTP_400_BAD_REQUEST)

# Product Detail Views (Retrieve, Update, Delete)
class ProductDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk, farmer=request.user.farmer)
            logger.info(f"Retrieved product ID: {pk} for farmer ID: {request.user.farmer.id}")
            serializer = ProductSerializer(product)
            return Response(serializer.data)
        except Product.DoesNotExist:
            logger.warning(f"Product ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk, farmer=request.user.farmer)
            serializer = ProductSerializer(product, data=request.data, partial=True)
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
            product = Product.objects.get(pk=pk, farmer=request.user.farmer)
            product.delete()
            logger.info(f"Product ID: {pk} deleted for farmer ID: {request.user.farmer.id}")
            return Response({"message": "Product deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Product.DoesNotExist:
            logger.warning(f"Product ID: {pk} not found for farmer ID: {request.user.farmer.id}")
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)
