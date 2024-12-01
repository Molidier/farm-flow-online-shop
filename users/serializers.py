from rest_framework import serializers
from .models import User, Farmer, Buyer, OTP

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'first_name', 'last_name', 'email', 'phone_number', 'password', 'role', 'image']
        read_only_fields = ['id', 'role']  # Prevent role from being modified after creation


class FarmerSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Farmer
        fields = ['id', 'user', 'Fname', 'farm_location', 'farm_size']

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
        # Handle user data updates
        user_data = validated_data.pop('user', None)
        if user_data:
            user = instance.user
            for attr, value in user_data.items():
                setattr(user, attr, value)
            user.save()

        # Handle remaining buyer data updates
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        return instance


class VerifyOTPSerializer(serializers.ModelSerializer):
    class Meta:
        model = OTP
        fields = ['id', 'email', 'otp', 'created_at']
        read_only_fields = ['created_at']
