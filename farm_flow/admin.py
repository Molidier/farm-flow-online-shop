from django.contrib.admin import AdminSite
from users.models import Buyer, ApprovedFarmer, PendingFarmer, User, RejectedFarmer
from users.admin import BuyerAdmin, ApprovedFarmerAdmin, PendingFarmerAdmin, UserAdmin, RejectedFarmerAdmin

# Create a custom AdminSite
class CustomAdminSite(AdminSite):
    site_header = "Farm Flow Admin"
    site_title = "Farm Flow Admin Portal"
    index_title = "Welcome to the Farm Flow Admin Portal"

    def get_app_list(self, request):
        # Define the order for models
        ordering = {
            "Buyers": 1,
            "Pending Farmers": 2,
            "Approved Farmers": 3,
            "Rejected Farmers": 4,
            "Users": 5
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
custom_admin_site.register(PendingFarmer, PendingFarmerAdmin)
custom_admin_site.register(ApprovedFarmer, ApprovedFarmerAdmin)
custom_admin_site.register(RejectedFarmer, RejectedFarmerAdmin)
