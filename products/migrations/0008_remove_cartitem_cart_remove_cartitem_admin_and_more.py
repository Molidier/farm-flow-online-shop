# Generated by Django 5.1.3 on 2024-11-30 18:22

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0007_remove_inventory_farm_remove_inventory_product_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='cartitem',
            name='cart',
        ),
        migrations.RemoveField(
            model_name='cartitem',
            name='admin',
        ),
        migrations.RemoveField(
            model_name='cartitem',
            name='product',
        ),
        migrations.DeleteModel(
            name='Cart',
        ),
        migrations.DeleteModel(
            name='CartItem',
        ),
    ]
