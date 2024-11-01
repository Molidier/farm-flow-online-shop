from rest_framework import serializers
from .models import User, Farmer, Buyer

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    class Meta:
        model = User
        fields = ['id', 'first_name', 'last_name', 'email', 'phone_number', 'password']
        

class FarmerSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Farmer
        fields = ['id', 'user', 'verified'] #last one can be deleted ig

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        user = User.objects.create_user(**user_data, role="farmer")  # Set role to "farmer"
        farmer = Farmer.objects.create(user=user, **validated_data)
        return farmer

class BuyerSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Buyer
        fields = ['id', 'user', 'deliveryAdress', 'payment_method']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        user = User.objects.create_user(**user_data, role="buyer")  # Set role to "buyer"
        buyer = Buyer.objects.create(user=user, **validated_data)
        return buyer