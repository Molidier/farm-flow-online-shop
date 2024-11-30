from django.urls import path
from .views import ChatView, MessageView

urlpatterns = [
    path('', ChatView.as_view(), name='chat'),
    path('<int:chat_id>/', MessageView.as_view(), name='message'),
]
