from django.contrib.admin import AdminSite
from users.models import Buyer, VerifiedFarmer, PendingFarmer, User
from users.admin import BuyerAdmin, VerifiedFarmerAdmin, PendingFarmerAdmin, UserAdmin

# Create a custom AdminSite
class CustomAdminSite(AdminSite):
    site_header = "Farm Flow Admin"
    site_title = "Farm Flow Admin Portal"
    index_title = "Welcome to the Farm Flow Admin Portal"

    def get_app_list(self, request):
        # Define the order for models
        ordering = {
            "Buyers": 1,
            "Verified Farmers": 2,
            "Pending Farmers": 3,
            "Users": 4
        }

        # Build the app dictionary
        app_dict = self._build_app_dict(request)

        # Sort apps and models by custom order
        app_list = sorted(app_dict.values(), key=lambda x: x['name'].lower())
        for app in app_list:
            app['models'].sort(key=lambda x: ordering.get(x['name'], 100))  # Default to 100 if not specified

        return app_list

# Instantiate the custom admin site
custom_admin_site = CustomAdminSite(name='custom_admin')

# Register models in the desired order

custom_admin_site.register(User, UserAdmin)
custom_admin_site.register(Buyer, BuyerAdmin)
custom_admin_site.register(VerifiedFarmer, VerifiedFarmerAdmin)
custom_admin_site.register(PendingFarmer, PendingFarmerAdmin)
