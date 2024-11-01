from django.shortcuts import render, redirect
from django.contrib.auth.models import User
from django.contrib.auth import login
from django.contrib import messages

from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status

#for login
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate

#buyer register function
@api_view(['POST'])
def register_c(request):
    #if request.method == 'POST':
        firstname = request.POST['firstname']
        secondname = request.POST['secondname']
        email = request.POST['email']
        phoneNumber = request.POST['phoneNumber']
        deliveryAddress = request.POST['deliveryAddress']

        if not all([firstname, secondname, email, phoneNumber, deliveryAddress, paymentMethod]):
            # Checks if any of the variables (username, password, email) is missing or empty.
            # `all()` returns True only if all elements in the list are non-empty and non-None.
            # If any field is missing, it returns a JSON response with an error message.
            # The response status is set to 400, indicating a "Bad Request" due to missing fields.
            return Response({'error': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

        # If all fields are provided, proceed to create a new user
        user = User.objects.create_user(firstname=firstname,
                                        secondname = secondname, 
                                        email=email,
                                        phoneNumber=phoneNumber, 
                                        deliveryAddress=deliveryAddress, 
                                        )
        # `create_user` is a Django helper method that creates a new user object with the provided
        # username, password, and email, and then saves it to the database.
        
        user.save()
        # Saves the newly created user object to the database. This line is technically optional
        # because `create_user` already saves the user, but it’s often included for clarity.

        token = Token.objects.create(user=user) #Generate a token for the new user
        # Generates a new token associated with the newly created user.
        # `Token.objects.create()` is used to create an authentication token that can be returned to
        # the mobile app, allowing the user to authenticate future requests.
                                        
        
        '''
            login(request, user) # automatically login user after registration
            messages.success(request, 'Registration successful!') #Display a success message 
        '''
    #CHANHE LATER
        return Response({'success': 'Registration successful!'}, status=status.HTTP_201_CREATED)
        # Returns a JSON response containing the generated token and a success message.
        # The response status is set to 201, which indicates "Created," signifying that
        # the registration was successful and a new user was created.


#farmer register function
@api_view(['POST'])
def register_f(request):
    #if request.method == 'POST':
        firstname = request.POST['firstname']
        secondname = request.POST['secondname']
        fnumber = request.POST['fnumber']
        femail = request.POST['femail']

        if not all([firstname, secondname, fnumber, femail]):
            # Checks if any of the variables (username, password, email) is missing or empty.
            # `all()` returns True only if all elements in the list are non-empty and non-None.
            # If any field is missing, it returns a JSON response with an error message.
            # The response status is set to 400, indicating a "Bad Request" due to missing fields.
            return Response({'error': 'Missing fields'}, status=status.HTTP_400_BAD_REQUEST)

        # If all fields are provided, proceed to create a new user
        user = User.objects.create_user(firstname = firstname,
                                        secondname = secondname,
                                        fnumber = fnumber,
                                        femail = femail,
                                        )
        # `create_user` is a Django helper method that creates a new user object with the provided
        # username, password, and email, and then saves it to the database.
        
        user.save()
        # Saves the newly created user object to the database. This line is technically optional
        # because `create_user` already saves the user, but it’s often included for clarity.

        token = Token.objects.create(user=user) #Generate a token for the new user
        # Generates a new token associated with the newly created user.
        # `Token.objects.create()` is used to create an authentication token that can be returned to
        # the mobile app, allowing the user to authenticate future requests.
                                        
        '''
            login(request, user) # automatically login user after registration
            messages.success(request, 'Registration successful!') #Display a success message 
        '''
    #CHANHE LATER
        return Response({'success': 'Registration successful!'}, status=status.HTTP_201_CREATED)
        # Returns a JSON response containing the generated token and a success message.
        # The response status is set to 201, which indicates "Created," signifying that
        # the registration was successful and a new user was created.

@api_view(['POST'])
def login_view(request):
    # Defines a view function named `login_view` that handles login requests.
    # The `@api_view(['POST'])` decorator specifies that this view only accepts POST requests.

    email = request.data.get('email')
    # Extracts the 'username' value from the incoming request's data payload (JSON or form data).
    # If the 'username' field is missing, it will return `None`.

    password = request.data.get('password')
    # Extracts the 'password' value from the incoming request's data payload.
    # Similar to the username, if the 'password' field is missing, it will return `None`.

    user = authenticate(request, email=email, password=password)
    # Calls the `authenticate` function with the provided username and password.
    # If the credentials are correct, it returns a user object; otherwise, it returns `None`.

    if user is not None:
        # Checks if `user` is valid (i.e., the credentials were correct).
        token, created = Token.objects.get_or_create(user=user)
        # Retrieves or creates a token for the authenticated user. If the user already has a token,
        # `get_or_create` returns the existing one; otherwise, it creates a new token.
        # `token.key` is the unique token string that will be sent to the client.

        return Response({'token': token.key}, status=status.HTTP_200_OK)
        # Returns a JSON response containing the token string. The status is set to 200 OK,
        # indicating a successful login.

    else:
        return Response({'error': 'Invalid username or password'}, status=status.HTTP_400_BAD_REQUEST)
        # If the authentication fails (e.g., wrong username or password), a JSON response is returned
        # with an error message. The status is set to 400 Bad Request, indicating invalid credentials.
# Create your views here.
