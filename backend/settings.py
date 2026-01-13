"""Django settings for Sellefli Backend.
Configured for Render.com hosting with Supabase PostgreSQL.
"""
from pathlib import Path
import os

# Load environment variables from .env files if present (local dev convenience),
# without requiring python-dotenv.
_env_paths = [Path(__file__).resolve().parent / ".env", Path(__file__).resolve().parent.parent / ".env"]
for _env in _env_paths:
    if _env.is_file():
        with _env.open() as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                if "=" not in line:
                    continue
                key, val = line.split("=", 1)
                os.environ.setdefault(key.strip(), val.strip())

BASE_DIR = Path(__file__).resolve().parent

# Security settings - use environment variables in production
SECRET_KEY = os.getenv("SECRET_KEY", "CHANGE_ME_LATER_dev_only_key_12345")
DEBUG = os.getenv("DEBUG", "True").lower() in ("true", "1", "yes")
# Parse ALLOWED_HOSTS from env (comma or semicolon separated), strip whitespace and ignore empty entries.
_raw_allowed_hosts = os.getenv(
    "ALLOWED_HOSTS",
    "localhost,127.0.0.1,10.0.2.2,10.141.254.109,10.237.253.109,172.21.59.109,192.168.1.9,10.156.219.188,10.80.20.225",
)
ALLOWED_HOSTS = [h.strip() for h in _raw_allowed_hosts.replace(";", ",").split(",") if h.strip()]
# Ensure developer testing IPs are present (helps when .env overrides are missing)
for _ip in ("10.237.253.109", "172.21.59.109", "192.168.1.9", "10.156.219.188", "10.80.20.225"):
    if _ip not in ALLOWED_HOSTS:
        ALLOWED_HOSTS.append(_ip)

# Add Render host automatically
RENDER_EXTERNAL_HOSTNAME = os.getenv("RENDER_EXTERNAL_HOSTNAME")
if RENDER_EXTERNAL_HOSTNAME:
    ALLOWED_HOSTS.append(RENDER_EXTERNAL_HOSTNAME)

# CSRF trusted origins for production
CSRF_TRUSTED_ORIGINS = []
if RENDER_EXTERNAL_HOSTNAME:
    CSRF_TRUSTED_ORIGINS.append(f"https://{RENDER_EXTERNAL_HOSTNAME}")

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "corsheaders",
    "rest_framework",
    "users",
    "items",
    "item_images",
    "bookings",
    "ratings",
    "notifications",
]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",  # Serve static files in production
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

CORS_ALLOW_ALL_ORIGINS = True

ROOT_URLCONF = "urls"
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
    }
]

WSGI_APPLICATION = "wsgi.application"
ASGI_APPLICATION = "asgi.application"

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.getenv("SUPABASE_DB_NAME", "postgres"),
        "USER": os.getenv("SUPABASE_DB_USER", "postgres.usddlozrhceftmnhnknw"),
        "PASSWORD": os.getenv("SUPABASE_DB_PASSWORD", "AC672qRlo0cjtlzG"),
        "HOST": os.getenv("SUPABASE_DB_HOST", "aws-1-eu-central-1.pooler.supabase.com"),
        "PORT": os.getenv("SUPABASE_DB_PORT", "6543"),  # Use Supabase pooler port for better performance
        "OPTIONS": {
            "sslmode": os.getenv("SUPABASE_DB_SSLMODE", "require"),
        },
        "CONN_MAX_AGE": 600,  # Keep connections alive for 10 minutes
        "CONN_HEALTH_CHECKS": True,  # Check connection health before use
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

AUTH_USER_MODEL = "users.User"

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True

STATIC_URL = "static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

# WhiteNoise configuration for static files
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

# Security settings for production
if not DEBUG:
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
    SECURE_SSL_REDIRECT = True
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    SECURE_BROWSER_XSS_FILTER = True
    SECURE_CONTENT_TYPE_NOSNIFF = True
    X_FRAME_OPTIONS = "DENY"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# Supabase JWT Secret for verifying access tokens
SUPABASE_JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET", "zHhSOVlj/BQ6paZTPtfKFz7P3BNFrAEyEJeYkOKhfHgphqzBjaFfT/AUKFwKlbrJUsJysAcjLhJUiLiR2YJl3A==")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

# Firebase Cloud Messaging for push notifications
FCM_SERVER_KEY = os.getenv("FCM_SERVER_KEY")

REST_FRAMEWORK = {
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 10,
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "users.authentication.SupabaseAuthentication",
        "rest_framework.authentication.SessionAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_THROTTLE_CLASSES": [
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
    ],
    "DEFAULT_THROTTLE_RATES": {
        "anon": "100/hour",
        "user": "1000/hour",
    },
    "EXCEPTION_HANDLER": "rest_framework.views.exception_handler",
}

# Logging configuration
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
        },
    },
    "loggers": {
        "users.authentication": {
            "handlers": ["console"],
            "level": "DEBUG",
        },
    },
}
