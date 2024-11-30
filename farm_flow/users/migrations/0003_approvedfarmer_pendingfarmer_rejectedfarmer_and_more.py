# Generated by Django 4.2 on 2024-11-30 16:35

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("users", "0002_farmer_farm_location_farmer_farm_size"),
    ]

    operations = [
        migrations.CreateModel(
            name="ApprovedFarmer",
            fields=[],
            options={
                "verbose_name": "Approved Farmer",
                "verbose_name_plural": "Approved Farmers",
                "proxy": True,
                "indexes": [],
                "constraints": [],
            },
            bases=("users.farmer",),
        ),
        migrations.CreateModel(
            name="PendingFarmer",
            fields=[],
            options={
                "verbose_name": "Pending Farmer",
                "verbose_name_plural": "Pending Farmers",
                "proxy": True,
                "indexes": [],
                "constraints": [],
            },
            bases=("users.farmer",),
        ),
        migrations.CreateModel(
            name="RejectedFarmer",
            fields=[],
            options={
                "verbose_name": "Rejected Farmer",
                "verbose_name_plural": "Rejected Farmers",
                "proxy": True,
                "indexes": [],
                "constraints": [],
            },
            bases=("users.farmer",),
        ),
        migrations.RemoveField(
            model_name="otp",
            name="phone_number",
        ),
        migrations.AddField(
            model_name="otp",
            name="email",
            field=models.EmailField(default=None, max_length=254),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name="user",
            name="is_active",
            field=models.CharField(
                choices=[
                    ("pending", "Pending"),
                    ("approved", "Approved"),
                    ("rejected", "Rejected"),
                ],
                default="pending",
                max_length=10,
            ),
        ),
    ]
