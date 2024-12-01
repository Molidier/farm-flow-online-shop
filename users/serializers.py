from rest_framework import serializers
from .models import User, Farmer, Buyer, OTP

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    
    class Meta:
        model = User
        fields = ['id', 'first_name', 'last_name', 'email', 'phone_number', 'password', 'image']

class FarmerSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Farmer
        fields = ['id', 'user', 'Fname', 'farm_location', 'farm_size']  # Include new fields

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        image = user_data.pop('image', None)
        user = User.objects.create_user(**user_data, role="farmer")  # Set role to "farmer"
        farmer = Farmer.objects.create(user=user, **validated_data)
        if image:
            user.image = image
            user.save()
        return farmer


class BuyerSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Buyer
        fields = ['id', 'user', 'deliveryAdress']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        user = User.objects.create_user(**user_data, role="buyer")  # Set role to "buyer"
        buyer = Buyer.objects.create(user=user, **validated_data)
        return buyer

    def update(self, instance, validated_data):
        # Extract and handle user data separately
        user_data = validated_data.pop('user', None)
        
        if user_data:
            # Access the User instance related to the Buyer
            user = instance.user
            # Update fields on the User instance
            for attr, value in user_data.items():
                setattr(user, attr, value)
            user.save()  # Save User with updated fields

        # Update remaining Buyer fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        return instance

class VerifyOTPSerializer(serializers.ModelSerializer):
    class Meta:
        model = OTP
        fields = ['id', 'email', 'otp', 'created_at']
        read_only_fields = ['created_at']
