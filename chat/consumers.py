import json
from channels.generic.websocket import WebsocketConsumer
from asgiref.sync import async_to_sync
from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.authentication import JWTTokenUserAuthentication
from .models import Chat, Message
from users.models import User

class ChatConsumer(WebsocketConsumer):
    def connect(self):
        # Extract the token from the Authorization header
        token = None
        for header in self.scope['headers']:
            if header[0] == b'authorization':
                token = header[1].decode('utf-8').split(' ')[1]  # Get token after "Bearer "
                break

        if not token:
            self.close()  # Close connection if no token is provided
            return

        # Authenticate the user using the token
        self.user = self.authenticate_user(token)
        if isinstance(self.user, AnonymousUser):
            self.close()  # Close the connection if the token is invalid
            return

        self.chat_id = self.scope['url_route']['kwargs']['chat_id']
        self.chat_group_name = f'chat_{self.chat_id}'

        # Join the chat group
        async_to_sync(self.channel_layer.group_add)(
            self.chat_group_name,
            self.channel_name
        )
        self.accept()

    def authenticate_user(self, token):
        """Authenticate user using the provided token"""
        try:
            # Validate the token and get user ID
            validated_token = JWTTokenUserAuthentication().get_validated_token(token)
            user_id = validated_token.get("user_id")
            
            # Fetch the user instance from the database
            user = User.objects.get(id=user_id)
            return user
        except User.DoesNotExist:
            print(f"User with ID {user_id} does not exist.")
            return AnonymousUser()
        except Exception as e:
            print(f"Authentication failed: {e}")
            return AnonymousUser()


    def disconnect(self, close_code):
        # Leave the chat group
        async_to_sync(self.channel_layer.group_discard)(
            self.chat_group_name,
            self.channel_name
        )

    def receive(self, text_data):
        data = json.loads(text_data)
        message = data.get('message', '')
        attachment = data.get('attachment', None)  # This is the file URL

        # Save message to the database
        chat = Chat.objects.get(id=self.chat_id)
        msg = Message.objects.create(chat=chat, sender=self.user, message=message, attachment=attachment)

        # Broadcast message to the group
        async_to_sync(self.channel_layer.group_send)(
            self.chat_group_name,
            {
                'type': 'chat_message',
                'message': msg.message,
                'sender': self.user.first_name,
                'timestamp': msg.timestamp.isoformat(),
                'attachment': msg.attachment,  # File URL
            }
        )


    def chat_message(self, event):
        # Send message to WebSocket
        self.send(text_data=json.dumps(event))
