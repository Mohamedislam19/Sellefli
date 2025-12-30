"""
Django startup initialization module.
This module ensures the database is properly initialized when the Django application starts.
Call this in your main Django entry point (wsgi.py or asgi.py).
"""
import os
import sys
import django
from pathlib import Path


def ensure_db_initialized():
    """
    Ensure Django database tables are initialized.
    This runs migrations silently if needed.
    """
    if "RUN_MAIN" not in os.environ:
        # Skip during autoreload to avoid double execution
        return

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")

    try:
        django.setup()
        from django.core.management import call_command

        # Silently run migrations
        call_command("migrate", verbosity=0, interactive=False)
        print("[Django] Database tables initialized successfully")

    except Exception as e:
        print(f"[Django] Warning: Could not auto-initialize database: {e}")
        print("[Django] You may need to run: python db_init.py")


def setup_django_app():
    """Complete Django setup including database initialization."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
    django.setup()
    ensure_db_initialized()


if __name__ == "__main__":
    setup_django_app()
