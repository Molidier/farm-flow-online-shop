# Generated by Django 4.2 on 2024-11-30 16:37

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):
    dependencies = [
        ("users", "0003_approvedfarmer_pendingfarmer_rejectedfarmer_and_more"),
    ]

    operations = [
        migrations.AlterField(
            model_name="otp",
            name="email",
            field=models.EmailField(default=django.utils.timezone.now, max_length=254),
        ),
    ]
