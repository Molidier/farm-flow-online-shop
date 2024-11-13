# from django.contrib import admin
# from farm_flow.admin import custom_admin_site
# from .models import Farm, Product, Inventory, Cart, CartItem

# class FarmAdmin(admin.ModelAdmin):
#     list_display = ('farm_name', 'farmer', 'farm_location', 'farm_passport')
#     search_fields = ('farm_name', 'farmer__user__first_name', 'farm_passport')

# class ProductAdmin(admin.ModelAdmin):
#     list_display = ('name', 'farm', 'category', 'price')
#     search_fields = ('name', 'category', 'farm__farm_name')
#     list_filter = ('category',)

# class InventoryAdmin(admin.ModelAdmin):
#     list_display = ('product', 'farm', 'quantity', 'availability')
#     list_filter = ('availability',)
#     search_fields = ('product__name', 'farm__farm_name')

# class CartAdmin(admin.ModelAdmin):
#     list_display = ('buyer', 'created_date', 'cart_status')
#     list_filter = ('cart_status',)
#     search_fields = ('buyer__user__first_name', 'buyer__user__last_name')

# class CartItemAdmin(admin.ModelAdmin):
#     list_display = ('cart', 'product', 'quantity', 'price_per_unit', 'verified', 'admin')
#     list_filter = ('verified',)
#     search_fields = ('product__name', 'cart__buyer__user__first_name', 'cart__buyer__user__last_name')

# # Register the models with the custom admin classes
# custom_admin_site.register(Farm, FarmAdmin)
# custom_admin_site.register(Product, ProductAdmin)
# custom_admin_site.register(Inventory, InventoryAdmin)
# custom_admin_site.register(Cart, CartAdmin)
# custom_admin_site.register(CartItem, CartItemAdmin)
