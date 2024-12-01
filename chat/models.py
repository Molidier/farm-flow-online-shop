from django.db import models
from users.models import User

class Chat(models.Model):
    farmer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_farmer')
    buyer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_buyer')
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.farmer} - {self.buyer} chat"
    
    class Meta:
        unique_together = ['farmer', 'buyer']
        app_label = 'chat'
    

class Message(models.Model):
    chat = models.ForeignKey(Chat, on_delete=models.CASCADE, related_name='chat_message')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='message_sender')
    message = models.TextField(blank=True, null=True)
    attachment = models.URLField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.sender} - {self.chat} message"
    
    class Meta:
        ordering = ['timestamp']
        app_label = 'chat'
