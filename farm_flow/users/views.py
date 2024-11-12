from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Farmer, Buyer, User
from .serializers import FarmerSerializer, BuyerSerializer, UserSerializer

# Register a new farmer
class RegisterFarmerAPIView(APIView):
    permission_classes = []  # No permissions required, so anyone can access this endpoint

    def post(self, request, *args, **kwargs):
        # Initialize serializer with request data for creating a farmer
        serializer = FarmerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()  # Save the new farmer if data is valid
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # Return validation errors if data is invalid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Register a new buyer
class RegisterBuyerAPIView(APIView):
    permission_classes = []  # No permissions required, so anyone can access this endpoint

    def post(self, request, *args, **kwargs):
        # Initialize serializer with request data for creating a buyer
        serializer = BuyerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()  # Save the new buyer if data is valid
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # Return validation errors if data is invalid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Farmer's user page view to retrieve and update their profile
class FarmerUserPageView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access this endpoint

    def get(self, request, *args, **kwargs):
        # Ensure the user is a farmer by checking their role
        if request.user.role != 'farmer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        # Retrieve the farmer profile linked to the authenticated user
        try:
            farmer = Farmer.objects.get(user=request.user)
            serializer = UserSerializer(farmer.user)  # Use UserSerializer for farmer's user info
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Farmer.DoesNotExist:
            return Response({"error": "Farmer profile not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, *args, **kwargs):
        # Ensure the user is a farmer by checking their role
        if request.user.role != 'farmer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        # Update the farmer's profile information
        try:
            farmer = Farmer.objects.get(user=request.user)
            # Partially update the farmer's user data
            serializer = UserSerializer(farmer.user, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()  # Save the updated information if valid
                return Response(serializer.data, status=status.HTTP_200_OK)
            # Return validation errors if data is invalid
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Farmer.DoesNotExist:
            return Response({"error": "Farmer profile not found"}, status=status.HTTP_404_NOT_FOUND)

# Buyer's user page view to retrieve and update their profile
class BuyerUserPageView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access this endpoint

    def get(self, request, *args, **kwargs):
        # Ensure the user is a buyer by checking their role
        if request.user.role != 'buyer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        # Retrieve the buyer profile linked to the authenticated user
        try:
            buyer = Buyer.objects.get(user=request.user)
            serializer = BuyerSerializer(buyer)  # Use BuyerSerializer to include deliveryAdress
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Buyer.DoesNotExist:
            return Response({"error": "Buyer profile not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, *args, **kwargs):
        # Ensure the user is a buyer by checking their role
        if request.user.role != 'buyer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        # Update the buyer's profile information
        try:
            buyer = Buyer.objects.get(user=request.user)
            # Partially update the buyer's user data
            serializer = BuyerSerializer(buyer, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()  # Save the updated information if valid
                return Response(serializer.data, status=status.HTTP_200_OK)
            # Return validation errors if data is invalid
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Buyer.DoesNotExist:
            return Response({"error": "Buyer profile not found"}, status=status.HTTP_404_NOT_FOUND)
