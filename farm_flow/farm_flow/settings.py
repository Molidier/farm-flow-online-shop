from datetime import timedelta

from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = "django-insecure-t@8^35u+wlu$%d8w4sru1l2k1=z7-0px9wx809mkrva1tfu^0q"

CORS_ALLOW_ALL_ORIGINS = True

DEBUG = True

ALLOWED_HOSTS = ["*"]


REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": ("rest_framework_simplejwt.authentication.JWTAuthentication",),
}


SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=5),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=1),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
}


INSTALLED_APPS = [
    "rest_framework.authtoken",
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "debug_toolbar",
    "corsheaders",
    "rest_framework",
    "rest_framework_simplejwt",
    "ffapp",
    "users",
    "orders",
    "products",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "debug_toolbar.middleware.DebugToolbarMiddleware",
]

ROOT_URLCONF = "farm_flow.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "farm_flow.wsgi.application"


# Database
# https://docs.djangoproject.com/en/5.1/ref/settings/#databases

# AIVEN SETUP SENDED BY RASIK

"""
{
    "Servers": {
        "1": {
            "Name": "CONNECTION_NAME",
            "Group": "GROUP_TEST",
            "Host": "team-f-nu-fa60.h.aivencloud.com",
            "Port": 24680,
            "MaintenanceDB": "defaultdb",
            "Username": "avnadmin",
            "SSLMode": "require"
        }
    }
}


password: AVNS_rAufI3FoPxaQsyguzJN
"""
# CHANGE -> if needed
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",  # Use the PostgreSQL backend
        "NAME": "latest",  # Name of the database
        "USER": "avnadmin",  # Username provided by Aiven
        "PASSWORD": "AVNS_rAufI3FoPxaQsyguzJN",  # Replace with the actual password
        "HOST": "team-f-nu-fa60.h.aivencloud.com",  # Aiven host
        "PORT": 24680,  # Port number from Aiven configuration
        "OPTIONS": {
            "sslmode": "require",  # Enforce SSL mode for secure connection
        },
    }
}


# Password validation
# https://docs.djangoproject.com/en/5.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.1/topics/i18n/

LANGUAGE_CODE = "en-us"

TIME_ZONE = "UTC"

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.1/howto/static-files/

STATIC_URL = "static/"

# Default primary key field type
# https://docs.djangoproject.com/en/5.1/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

AUTH_USER_MODEL = "users.User"

#To be able to add images

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

