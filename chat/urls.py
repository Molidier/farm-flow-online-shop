from django.urls import path
from .views import ChatView, MessageView, FileUploadView

urlpatterns = [
    path('', ChatView.as_view(), name='chat'),
    path('<int:chat_id>/', MessageView.as_view(), name='message'),
    path('upload/', FileUploadView.as_view(), name='file-upload'),

]
