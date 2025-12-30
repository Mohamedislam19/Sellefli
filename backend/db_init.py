#!/usr/bin/env python
"""
Django database initialization script.
This script handles table creation and migrations for the Sellefli backend.
Run this before starting the Django server for the first time.
"""
import os
import sys
import django


def initialize_database():
    """Initialize the Django database with all migrations."""
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
    django.setup()

    from django.core.management import call_command

    print("=" * 60)
    print("Initializing Sellefli Django Database")
    print("=" * 60)

    try:
        # Run all pending migrations
        print("\n[1/2] Running migrations...")
        call_command("migrate", verbosity=1)
        print("✓ Migrations completed successfully!")

        # Display migration status
        print("\n[2/2] Checking migration status...")
        call_command("showmigrations", verbosity=1)
        print("✓ Database initialization completed successfully!")

        print("\n" + "=" * 60)
        print("Database is ready to use!")
        print("=" * 60)

        return True

    except Exception as e:
        print(f"\n✗ Error during database initialization: {e}")
        return False


if __name__ == "__main__":
    success = initialize_database()
    sys.exit(0 if success else 1)
