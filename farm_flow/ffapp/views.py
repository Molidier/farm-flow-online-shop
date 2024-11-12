from django.conf import settings
from django.shortcuts import render, redirect
from django.contrib.auth.models import User
from django.contrib.auth import login
from django.contrib import messages
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
import requests  # If you need to make an external request using the API key

# Example use of the API key in the `register_c` function
@api_view(['POST'])
def register_c(request):
    firstname = request.POST.get('firstname')
    secondname = request.POST.get('secondname')
    email = request.POST.get('email')
    phoneNumber = request.POST.get('phoneNumber')
    deliveryAddress = request.POST.get('deliveryAddress')

    # Check for required fields
    if not all([firstname, secondname, email, phoneNumber, deliveryAddress]):
        return Response({'error': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

    # Example: Using the API key to make an external request
    api_key = settings.FARM_FLOW_API_KEY
    if api_key:
        # Sample URL for demonstration purposes
        url = f"https://example.com/api/resource?api_key={api_key}"
        # Make an external API call if required
        response = requests.get(url)
        if response.status_code == 200:
            # Proceed if the external API request is successful
            pass
        else:
            return Response({'error': 'External API request failed'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    # Create and save the new user
    user = User.objects.create_user(
        first_name=firstname,
        last_name=secondname,
        email=email,
        username=phoneNumber  # Assuming `phoneNumber` as the username
    )
    user.save()
    
    # Generate a token for the new user
    token = Token.objects.create(user=user)
    
    return Response({'success': 'Registration successful!', 'token': token.key}, status=status.HTTP_201_CREATED)


# The farmer registration function (similar structure as register_c)
@api_view(['POST'])
def register_f(request):
    firstname = request.POST.get('firstname')
    secondname = request.POST.get('secondname')
    fnumber = request.POST.get('fnumber')
    femail = request.POST.get('femail')

    if not all([firstname, secondname, fnumber, femail]):
        return Response({'error': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

    user = User.objects.create_user(
        first_name=firstname,
        last_name=secondname,
        email=femail,
        username=fnumber  # Assuming `fnumber` as the username
    )
    user.save()

    # Generate a token for the new user
    token = Token.objects.create(user=user)
    
    return Response({'success': 'Registration successful!', 'token': token.key}, status=status.HTTP_201_CREATED)


@api_view(['POST'])
def login_view(request):
    email = request.data.get('email')
    password = request.data.get('password')

    user = authenticate(request, email=email, password=password)
    if user is not None:
        token, created = Token.objects.get_or_create(user=user)
        return Response({'token': token.key}, status=status.HTTP_200_OK)
    else:
        return Response({'error': 'Invalid username or password'}, status=status.HTTP_400_BAD_REQUEST)
