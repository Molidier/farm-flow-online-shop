from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Orders, OrderProduct, Payment, Delivery
from .serializers import OrdersSerializer, OrderProductSerializer, PaymentSerializer, DeliverySerializer
from users.models import Buyer
from products.models import Product

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

# User Order History View
class UserOrderHistoryAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        try:
            buyer = user.buyer
            orders = Orders.objects.filter(buyer=buyer).order_by('-order_date')
            serializer = OrdersSerializer(orders, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Buyer.DoesNotExist:
            return Response({"error": "No orders found for this user."}, status=status.HTTP_404_NOT_FOUND)
