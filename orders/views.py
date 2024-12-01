from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Order
from .serializers import OrderSerializer, OrderUpdateSerializer
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
            order.process_order_with_atomicity()
            
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

       
class ProcessPaymentView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            order = Order.objects.get(id=kwargs['order_id'], buyer=request.user.buyer)
        except Order.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the order is eligible for payment
        if order.payment_status != "PENDING":
            return Response({"error": "Order payment is already processed or failed."}, status=status.HTTP_400_BAD_REQUEST)

        # Simulate payment processing logic (e.g., interacting with a payment gateway)
        # For demonstration, we'll assume the payment is successful
        payment_success = True  # payment gateway logic

        if payment_success:
            order.mark_as_paid()
            return Response({"message": "Payment processed successfully."}, status=status.HTTP_200_OK)
        else:
            order.payment_status = "FAILED"
            order.save()
            return Response({"error": "Payment failed."}, status=status.HTTP_400_BAD_REQUEST)
        

class ProcessDeliveryView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            order = Order.objects.get(id=kwargs['order_id'], buyer=request.user.buyer)
        except Order.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        # Check if the order is eligible for delivery
        if order.status not in ["CONFIRMED", "SHIPPED"]:
            return Response({"error": "Order cannot be delivered at this stage."}, status=status.HTTP_400_BAD_REQUEST)

        delivery_success = True
        
        if delivery_success:
            order.mark_as_delivered()
            return Response({"message": "Order marked as delivered."}, status=status.HTTP_200_OK)
        

class UpdateDeliveryAddressView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, *args, **kwargs):
        try:
            order = Order.objects.get(id=kwargs['order_id'], buyer=request.user.buyer)
        except Order.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        if order.status != "PENDING":
            return Response({"error": "Delivery address cannot be updated for this order."}, status=status.HTTP_400_BAD_REQUEST)

        new_address = request.data.get("delivery_address")
        if not new_address:
            return Response({"error": "Delivery address is required."}, status=status.HTTP_400_BAD_REQUEST)

        order.delivery_address = new_address
        order.save()
        return Response({"message": "Delivery address updated successfully."}, status=status.HTTP_200_OK)

class ConfirmOrderView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        try:
            order = Order.objects.get(id=kwargs['order_id'], buyer=request.user.buyer)
        except Order.DoesNotExist:
            return Response({"error": "Order not found."}, status=status.HTTP_404_NOT_FOUND)

        # Ensure payment and delivery are completed
        if order.payment_status != "PAID":
            return Response({"error": "Payment is not completed for this order."}, status=status.HTTP_400_BAD_REQUEST)

        if order.status != "DELIVERED":
            return Response({"error": "Order has not been delivered yet."}, status=status.HTTP_400_BAD_REQUEST)

        # Mark the order as completed
        order.status = "COMPLETED"
        order.save()
        return Response({"message": "Order confirmed successfully."}, status=status.HTTP_200_OK)


