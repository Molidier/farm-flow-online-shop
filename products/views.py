from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from .models import Product, Category, Cart, CartItem
from .serializers import ProductSerializer, CategorySerializer, CartItemSerializer, CartSerializer
from users.models import User, Buyer


class CategoryListCreateAPIView(APIView):
    permission_classes = [IsAuthenticated]

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


class ProductCreateAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        serializer = ProductSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProductDetailAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk)
            serializer = ProductSerializer(product)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Product.DoesNotExist:
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk)
            serializer = ProductSerializer(product, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Product.DoesNotExist:
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)

    def delete(self, request, pk, *args, **kwargs):
        try:
            product = Product.objects.get(pk=pk)
            product.delete()
            return Response({"message": "Product deleted successfully"}, status=status.HTTP_204_NO_CONTENT)
        except Product.DoesNotExist:
            return Response({"error": "Product not found"}, status=status.HTTP_404_NOT_FOUND)


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
        
class BargainRequestView(APIView):
    permission_classes = [IsAuthenticated]
    def patch(self, request, *args, **kwargs):
        try:
            cart_item = CartItem.objects.get(id=kwargs['item_id'], cart__buyer=request.user.buyer)
        except CartItem.DoesNotExist:
            return Response({"error": "Cart item not found."}, status=status.HTTP_404_NOT_FOUND)

        serializer = CartItemSerializer(cart_item, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class BargainResponseView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request, *args, **kwargs):
        # Ensure only farmers can view bargain requests
        if not request.user.role == 'farmer': 
            return Response({"error": "Unauthorized action."}, status=status.HTTP_403_FORBIDDEN)
        # Fetch all pending bargain requests for products owned by the farmer
        pending_bargains = CartItem.objects.filter(
            product__farmer=request.user.farmer, 
            is_bargain_requested=True,
            bargain_status='PENDING'
        ).select_related('product', 'cart')
         # Serialize the results
        serializer = CartItemSerializer(pending_bargains, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def patch(self, request, *args, **kwargs):
        try:
            cart_item = CartItem.objects.get(id=kwargs['item_id'])
        except CartItem.DoesNotExist:
            return Response({"error": "Cart item not found."}, status=status.HTTP_404_NOT_FOUND)

        # Ensure only farmers can verify the bargain
        if not request.user.role == 'farmer':  # Assuming `is_farmer` is a field in the User model
            return Response({"error": "Unauthorized action."}, status=status.HTTP_403_FORBIDDEN)

        action = request.data.get('action')
        if action == 'ACCEPT':
            cart_item.price_per_unit = cart_item.requested_price
            cart_item.bargain_status = 'ACCEPTED'
        elif action == 'REJECT':
            cart_item.bargain_status = 'REJECTED'
        else:
            return Response({"error": "Invalid action."}, status=status.HTTP_400_BAD_REQUEST)
        
        cart_item.is_bargain_requested = False
        cart_item.requested_price = None
        cart_item.save()
        return Response({"message": "Bargain updated successfully."}, status=status.HTTP_200_OK)

        
