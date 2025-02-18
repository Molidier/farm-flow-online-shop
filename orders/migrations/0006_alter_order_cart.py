# Generated by Django 5.1.3 on 2024-12-01 08:33

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('orders', '0005_alter_order_cart'),
        ('products', '0009_cart_cartitem'),
    ]

    operations = [
        migrations.AlterField(
            model_name='order',
            name='cart',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='order', to='products.cart'),
        ),
    ]
