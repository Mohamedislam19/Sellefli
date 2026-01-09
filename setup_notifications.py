#!/usr/bin/env python
"""
Notification System Setup Script
Automates the setup process for Selefli notification system.

Usage:
    python setup_notifications.py
"""

import os
import sys
import subprocess
from pathlib import Path


def print_header(text):
    """Print formatted header."""
    print("\n" + "=" * 60)
    print(f"  {text}")
    print("=" * 60 + "\n")


def print_step(step, text):
    """Print step information."""
    print(f"[{step}] {text}")


def run_command(cmd, description):
    """Run a shell command and handle errors."""
    print(f"  Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"  ❌ Error: {result.stderr}")
        return False
    
    if result.stdout:
        print(f"  ✅ {result.stdout.strip()}")
    return True


def check_django_installation():
    """Check if Django is installed."""
    try:
        import django
        print(f"  ✅ Django {django.get_version()} installed")
        return True
    except ImportError:
        print("  ❌ Django not installed")
        return False


def check_environment_file():
    """Check if .env file exists."""
    env_path = Path(__file__).parent / "backend" / ".env"
    
    if env_path.exists():
        print(f"  ✅ .env file found at {env_path}")
        return True
    else:
        print(f"  ⚠️  .env file not found at {env_path}")
        print("     You'll need to create it and add FCM_SERVER_KEY")
        return False


def create_migrations():
    """Create and run migrations."""
    print_step(3, "Creating database migrations...")
    
    if not run_command(
        "python backend/manage.py makemigrations notifications",
        "Creating migrations"
    ):
        return False
    
    return True


def run_migrations():
    """Run database migrations."""
    print_step(4, "Running database migrations...")
    
    if not run_command(
        "python backend/manage.py migrate",
        "Applying migrations"
    ):
        return False
    
    return True


def display_env_setup():
    """Display environment variable setup instructions."""
    print_step(5, "Environment Configuration")
    
    print("\n  Add these variables to backend/.env:\n")
    print("  # Required for push notifications")
    print("  FCM_SERVER_KEY=AAAA...your-firebase-server-key")
    print("\n  # Optional - for Supabase Realtime")
    print("  SUPABASE_URL=https://your-project.supabase.co")
    print("  SUPABASE_SERVICE_ROLE_KEY=your-service-role-key")
    print("\n  Get FCM Server Key from:")
    print("  Firebase Console → Project Settings → Cloud Messaging")
    print()


def display_next_steps():
    """Display next steps."""
    print_header("Next Steps")
    
    print("1. Add FCM_SERVER_KEY to backend/.env")
    print("2. Restart Django server: python backend/manage.py runserver")
    print("3. Test API: curl http://localhost:8000/api/notifications/")
    print("4. Read documentation:")
    print("   - backend/notifications/NOTIFICATION_SYSTEM_DOCS.md")
    print("   - backend/notifications/SETUP_GUIDE.md")
    print("   - NOTIFICATION_API_REFERENCE.md")
    print()


def main():
    """Main setup function."""
    print_header("Selefli Notification System Setup")
    
    # Step 1: Check Django
    print_step(1, "Checking Django installation...")
    if not check_django_installation():
        print("\n❌ Setup failed: Django not installed")
        print("Install Django: pip install django djangorestframework")
        return 1
    
    # Step 2: Check environment
    print_step(2, "Checking environment configuration...")
    env_exists = check_environment_file()
    
    # Step 3: Create migrations
    if not create_migrations():
        print("\n❌ Setup failed: Could not create migrations")
        return 1
    
    # Step 4: Run migrations
    if not run_migrations():
        print("\n❌ Setup failed: Could not run migrations")
        return 1
    
    # Step 5: Environment setup
    if not env_exists:
        display_env_setup()
    
    # Success
    print_header("✅ Setup Complete!")
    display_next_steps()
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
