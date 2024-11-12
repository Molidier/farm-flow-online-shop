# from django.contrib import admin
# from .models import Orders, OrderProduct, Payment, Delivery

# class OrdersAdmin(admin.ModelAdmin):
#     list_display = ('id', 'buyer', 'order_date', 'order_status', 'total_amount')
#     search_fields = ('buyer__user__first_name', 'buyer__user__last_name', 'id')
#     list_filter = ('order_status', 'order_date')

# class OrderProductAdmin(admin.ModelAdmin):
#     list_display = ('order', 'product', 'quantity_ordered', 'price_at_purchase')
#     search_fields = ('order__id', 'product__name')
#     list_filter = ('product',)

# class PaymentAdmin(admin.ModelAdmin):
#     list_display = ('order', 'payment_date', 'payment_method', 'payment_amount')
#     search_fields = ('order__id', 'payment_method')
#     list_filter = ('payment_method', 'payment_date')

# class DeliveryAdmin(admin.ModelAdmin):
#     list_display = ('order', 'delivery_type', 'delivery_date', 'delivery_status', 'delivery_cost')
#     search_fields = ('order__id', 'delivery_type', 'delivery_status')
#     list_filter = ('delivery_type', 'delivery_status', 'delivery_date')

# # Register the models with the custom admin classes
# admin.site.register(Orders, OrdersAdmin)
# admin.site.register(OrderProduct, OrderProductAdmin)
# admin.site.register(Payment, PaymentAdmin)
# admin.site.register(Delivery, DeliveryAdmin)
