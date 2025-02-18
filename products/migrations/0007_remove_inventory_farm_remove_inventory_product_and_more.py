# Generated by Django 4.2 on 2024-11-30 17:21

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        ("users", "0006_farmer_farm_location_farmer_farm_size"),
        ("products", "0006_alter_farm_farmer"),
    ]

    operations = [
        migrations.RemoveField(
            model_name="inventory",
            name="farm",
        ),
        migrations.RemoveField(
            model_name="inventory",
            name="product",
        ),
        migrations.RemoveField(
            model_name="product",
            name="farm",
        ),
        migrations.AddField(
            model_name="product",
            name="farmer",
            field=models.ForeignKey(
                default=None,
                on_delete=django.db.models.deletion.CASCADE,
                to="users.farmer",
            ),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name="product",
            name="quantity",
            field=models.FloatField(default=0),
        ),
        migrations.DeleteModel(
            name="Farm",
        ),
        migrations.DeleteModel(
            name="Inventory",
        ),
    ]
