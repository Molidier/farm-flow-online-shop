from .models import Chat, Message
from rest_framework import serializers
from users.serializers import UserSerializer

class ChatSerializer(serializers.ModelSerializer):
    farmer_name = serializers.CharField(source='farmer.first_name', read_only=True)
    buyer_name = serializers.CharField(source='buyer.first_name', read_only=True)
    
    class Meta:
        model = Chat
        fields = ["id", "farmer", "farmer_name", "buyer", "buyer_name", "created_at"]
        
        
class MessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source='sender.first_name', read_only=True)
    
    class Meta:
        model = Message
        fields = '__all__'
        read_only_fields = ['timestamp']
        