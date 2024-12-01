from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from .models import Farmer, Buyer, User, OTP
from .serializers import FarmerSerializer, BuyerSerializer, UserSerializer, VerifyOTPSerializer
from django.core.mail import send_mail
from django.core.mail import BadHeaderError
from smtplib import SMTPException
import random
from django.shortcuts import get_object_or_404
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser

# Register a new farmer
class RegisterFarmerAPIView(APIView):
    permission_classes = []  # No permissions required, so anyone can access this endpoint
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request, *args, **kwargs):
        serializer = FarmerSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# Register a new buyer
class RegisterBuyerAPIView(APIView):
    permission_classes = []  # No permissions required, so anyone can access this endpoint

    def post(self, request, *args, **kwargs):
        # Initialize serializer with request data for creating a buyer
        serializer = BuyerSerializer(data=request.data)
        if serializer.is_valid():
            buyer = serializer.save()  # Save the new buyer if data is valid
            buyer.user.is_active = "pending"
            buyer.save()

            #send email 
            otp = self.generate_otp()
            self.storeOTP(buyer.user.email, otp)
            self.send_verification_email(request, buyer, otp)

            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # Return validation errors if data is invalid
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def generate_otp(self, length=6):
        return ''.join([str(random.randint(0,9)) for _ in range(length)])
    
    def storeOTP(self, email, otp):
        OTP.objects.create(email=email, otp=otp)
   
    def send_verification_email(self, request, buyer, otp):
        subject = 'Your One-Time Passcode for Farm Flow'
        message = f"Hi {buyer.user.first_name},\n\nYour One-Time Passcode is: {otp}. It will expire in 5 minutes."
        try:
            send_mail(subject, message, 'toksanbayamira4@gmail.com', [buyer.user.email],fail_silently=False)
        except BadHeaderError:
            print("Invalid header found.")
        except SMTPException as e:
            print(f"SMTP error occurred: {e}")
        except Exception as e:
            print(f"An error occurred: {e}")
    

#verifying through email
class VerifyOTPView(APIView):
    permission_classes = []
    def post(self, request, *args, **kwargs):
        serializer = VerifyOTPSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            otp = serializer.validated_data['otp']
            stored_otp = get_object_or_404(OTP, email=email)
            print("stored_otp: ", stored_otp)
            if otp==stored_otp.otp:# and stored_otp.is_valid():
                user = User.objects.get(email=email)
                user.is_active = "approved"
                user.save()
                user_serializer = UserSerializer(user)
                return Response(user_serializer.data, status=status.HTTP_200_OK)
        return Response({"error": "Invalid", "data": serializer.data}, status=status.HTTP_400_BAD_REQUEST)
    

# Farmer's user page view to retrieve and update their profile
# Farmer's user page view to retrieve and update their profile
class FarmerUserPageView(APIView):
    permission_classes = [IsAuthenticated]  # Only authenticated users can access this endpoint

    def get(self, request, *args, **kwargs):
        # Ensure the user is a farmer by checking their role
        if request.user.role != 'farmer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        try:
            # Retrieve the farmer profile linked to the authenticated user
            farmer = Farmer.objects.get(user=request.user)
            serializer = FarmerSerializer(farmer)  # Serialize the farmer's data
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Farmer.DoesNotExist:
            return Response({"error": "Farmer profile not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, *args, **kwargs):
        # Ensure the user is a farmer by checking their role
        if request.user.role != 'farmer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        try:
            # Retrieve the farmer profile linked to the authenticated user
            farmer = Farmer.objects.get(user=request.user)
            serializer = FarmerSerializer(farmer, data=request.data, partial=True)  # Allow partial updates
            if serializer.is_valid():
                # Save the updates
                serializer.save()
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

        try:
            # Retrieve the buyer profile linked to the authenticated user
            buyer = Buyer.objects.get(user=request.user)
            serializer = BuyerSerializer(buyer)  # Serialize the buyer's data
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Buyer.DoesNotExist:
            return Response({"error": "Buyer profile not found"}, status=status.HTTP_404_NOT_FOUND)

    def put(self, request, *args, **kwargs):
        # Ensure the user is a buyer by checking their role
        if request.user.role != 'buyer':
            return Response({"error": "Access denied"}, status=status.HTTP_403_FORBIDDEN)

        try:
            # Retrieve the buyer profile linked to the authenticated user
            buyer = Buyer.objects.get(user=request.user)
            serializer = BuyerSerializer(buyer, data=request.data, partial=True)  # Allow partial updates
            if serializer.is_valid():
                # Save the updates
                serializer.save()
                return Response(serializer.data, status=status.HTTP_200_OK)
            # Return validation errors if data is invalid
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except Buyer.DoesNotExist:
            return Response({"error": "Buyer profile not found"}, status=status.HTTP_404_NOT_FOUND)
