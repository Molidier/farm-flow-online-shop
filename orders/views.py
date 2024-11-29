from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Orders, OrderProduct, Payment, Delivery
from .serializers import OrdersSerializer, OrderProductSerializer, PaymentSerializer, DeliverySerializer
from users.models import Buyer
from products.models import Farm, Product


# Orders View
class OrdersCreateAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = OrdersSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrdersDetailAPIView(APIView):
    def get(self, request, pk, *args, **kwargs):
        try:
            order = Orders.objects.get(pk=pk)
        except Orders.DoesNotExist:
            return Response({"error": "Order not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrdersSerializer(order)
        return Response(serializer.data)

    def put(self, request, pk, *args, **kwargs):
        try:
            order = Orders.objects.get(pk=pk)
        except Orders.DoesNotExist:
            return Response({"error": "Order not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrdersSerializer(order, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk, *args, **kwargs):
        try:
            order = Orders.objects.get(pk=pk)
        except Orders.DoesNotExist:
            return Response({"error": "Order not found"}, status=status.HTTP_404_NOT_FOUND)

        order.delete()
        return Response({"message": "Order deleted successfully"}, status=status.HTTP_204_NO_CONTENT)


# OrderProduct View
class OrderProductCreateAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = OrderProductSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderProductDetailAPIView(APIView):
    def get(self, request, pk, *args, **kwargs):
        try:
            order_product = OrderProduct.objects.get(pk=pk)
        except OrderProduct.DoesNotExist:
            return Response({"error": "OrderProduct not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrderProductSerializer(order_product)
        return Response(serializer.data)

    def delete(self, request, pk, *args, **kwargs):
        try:
            order_product = OrderProduct.objects.get(pk=pk)
        except OrderProduct.DoesNotExist:
            return Response({"error": "OrderProduct not found"}, status=status.HTTP_404_NOT_FOUND)

        order_product.delete()
        return Response({"message": "OrderProduct deleted successfully"}, status=status.HTTP_204_NO_CONTENT)


# Payment View
class PaymentCreateAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = PaymentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PaymentDetailAPIView(APIView):
    def get(self, request, pk, *args, **kwargs):
        try:
            payment = Payment.objects.get(pk=pk)
        except Payment.DoesNotExist:
            return Response({"error": "Payment not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = PaymentSerializer(payment)
        return Response(serializer.data)


# Delivery View
class DeliveryCreateAPIView(APIView):
    def post(self, request, *args, **kwargs):
        serializer = DeliverySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class DeliveryDetailAPIView(APIView):
    def get(self, request, pk, *args, **kwargs):
        try:
            delivery = Delivery.objects.get(pk=pk)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = DeliverySerializer(delivery)
        return Response(serializer.data)

    def put(self, request, pk, *args, **kwargs):
        try:
            delivery = Delivery.objects.get(pk=pk)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = DeliverySerializer(delivery, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk, *args, **kwargs):
        try:
            delivery = Delivery.objects.get(pk=pk)
        except Delivery.DoesNotExist:
            return Response({"error": "Delivery not found"}, status=status.HTTP_404_NOT_FOUND)

        delivery.delete()
        return Response({"message": "Delivery deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
    
    # View for retrieving authenticated user's order history
class UserOrderHistoryAPIView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access this view

    def get(self, request, *args, **kwargs):
        # Retrieve all orders associated with the authenticated buyer
        user = request.user
        try:
            buyer = user.buyer  # Assuming `Buyer` is related to `User` with OneToOneField
            orders = Orders.objects.filter(buyer=buyer).order_by('-order_date')  # Get all orders for the buyer
            serializer = OrdersSerializer(orders, many=True)  # Serialize multiple orders
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Buyer.DoesNotExist:
            return Response({"error": "No orders found for this user."}, status=status.HTTP_404_NOT_FOUND)
        
# View for retrieving all orders related to the authenticated farmer's farm
class FarmerOrdersAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # Check if the user is a farmer
        if not hasattr(request.user, 'farmer'):
            return Response({"error": "Access denied. Only farmers can access this information."}, status=status.HTTP_403_FORBIDDEN)
        
        # Retrieve the authenticated farmer's farm
        try:
            farm = Farm.objects.get(farmer=request.user.farmer)
        except Farm.DoesNotExist:
            return Response({"error": "Farm not found for this farmer."}, status=status.HTTP_404_NOT_FOUND)
        
        # Retrieve all products belonging to the farmer's farm
        farm_products = Product.objects.filter(farm=farm)
        
        # Retrieve all OrderProduct entries that include products from this farm
        order_products = OrderProduct.objects.filter(product__in=farm_products)
        
        # Collect all unique orders that contain these products
        orders = Orders.objects.filter(id__in=order_products.values('order').distinct())
        
        # Serialize and return all orders related to the farmer's farm
        serializer = OrdersSerializer(orders, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
