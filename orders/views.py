from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Order, Payment, Delivery
from .serializers import OrderSerializer, PaymentSerializer, DeliverySerializer
from users.models import Buyer, User
from products.models import Product, Cart

class OrderView(APIView):
    permission_classes = [IsAuthenticated]
    def post(self, request, *args, **kwargs):
        try:
            cart = Cart.objects.get(id=kwargs['cart_id'], buyer=request.user.buyer)
        except Cart.DoesNotExist:
            return Response({"error": "Cart not found."}, status=status.HTTP_404_NOT_FOUND)

        # create an order from the cart
        try:
            if hasattr(cart, 'order'):
                raise ValueError("An order has already been created for this cart.")

            # Ensure all items in the cart are verified
            if any(item.is_bargain_requested for item in cart.items.all()):
                raise ValueError("Not all items in the cart are verified. Some are still pending for the bargain")

            # Create and return the new order
            order = Order.objects.create(cart=cart, buyer=cart.buyer)
            
        except ValueError as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

        serializer = OrderSerializer(order)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    #to get all the orders made by buyer
    def get(self, request, *args, **kwargs):
        orders = Order.objects.filter(buyer=request.user.buyer)
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

# user order history view
class UserOrderHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        try:
            buyer = user.buyer
            orders = Order.objects.filter(buyer=buyer, status='CONFIRMED').order_by('-order_date')
            serializer = OrderSerializer(orders, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Buyer.DoesNotExist:
            return Response({"error": "No orders found for this user."}, status=status.HTTP_404_NOT_FOUND)

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


