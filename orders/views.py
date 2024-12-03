from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Order
from .serializers import OrderSerializer, OrderUpdateSerializer
from users.models import Buyer, User, Farmer
from products.models import Product, Cart
from django.db.models import Sum, Count
from datetime import datetime
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
from io import BytesIO
from django.http import FileResponse

def get_farmer_sales_data(farmer):
    orders = Order.objects.filter(cart__items__product__farmer=farmer, status="COMPLETED")
    total_revenue = orders.aggregate(Sum('total_price'))['total_price__sum'] or 0
    total_orders = orders.count()
    total_products_sold = orders.aggregate(Sum('cart__items__quantity'))['cart__items__quantity__sum'] or 0

    # Group orders by date for more detailed reporting
    orders_by_date = orders.values('created_at__date').annotate(
        total_revenue=Sum('total_price'),
        total_orders=Count('id'),
    )

    return {
        "total_revenue": total_revenue,
        "total_orders": total_orders,
        "total_products_sold": total_products_sold,
        "orders_by_date": orders_by_date,
    }

def generate_pdf_report(data, farmer_name):
    buffer = BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=A4)
    pdf.setTitle(f"{farmer_name} Sales Report")

    # Header
    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawString(50, 800, f"Sales Report for {farmer_name}")
    pdf.setFont("Helvetica", 12)
    pdf.drawString(50, 780, f"Date: {datetime.now().strftime('%Y-%m-%d')}")

    # Summary
    pdf.drawString(50, 750, f"Total Revenue: {data['total_revenue']}")
    pdf.drawString(50, 730, f"Total Orders: {data['total_orders']}")
    pdf.drawString(50, 710, f"Total Products Sold: {data['total_products_sold']}")

    # Orders by Date
    pdf.drawString(50, 680, "Orders by Date:")
    y = 660
    for order in data['orders_by_date']:
        pdf.drawString(50, y, f"- {order['created_at__date']}: {order['total_orders']} orders, revenue: {order['total_revenue']}")
        y -= 20

    pdf.save()
    buffer.seek(0)
    return buffer

class FarmerSalesReportView(APIView):

    def get(self, request, *args, **kwargs):
        try:
            farmer = Farmer.objects.get(id=kwargs['farmer_id'])

            # Fetch sales data
            sales_data = get_farmer_sales_data(farmer)

            # Generate PDF
            pdf_buffer = generate_pdf_report(sales_data, farmer_name=farmer.user.first_name)

            # Return the PDF as a downloadable file
            response = FileResponse(pdf_buffer, as_attachment=True, filename="sales_report.pdf")
            return response

        except Farmer.DoesNotExist:
            return Response({"error": "Farmer not found."}, status=404)

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
            order = Order.objects.create(cart=cart, buyer=cart.buyer, 
                    delivery_address=request.data.get('delivery_address', ''),
                    payment_method=request.data.get('payment_method', 'Cash'),
                    delivery_type=request.data.get('delivery_type', 'Home Delivery'),)
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


