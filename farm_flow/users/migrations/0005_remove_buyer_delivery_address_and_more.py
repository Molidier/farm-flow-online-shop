# Generated by Django 5.1.2 on 2024-11-08 07:13

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("users", "0004_farmer_is_verified"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="buyer",
            name="delivery_address",
        ),
        migrations.RemoveField(
            model_name="farmer",
            name="first_name",
        ),
        migrations.AddField(
            model_name="buyer",
            name="deliveryAdress",
            field=models.CharField(default="Default Address", max_length=255),
        ),
        migrations.AddField(
            model_name="farmer",
            name="Fname",
            field=models.CharField(default=None),
            preserve_default=False,
        ),
    ]
