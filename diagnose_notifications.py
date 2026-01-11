"""
Quick diagnostic to check Supabase notification setup.
Run this to verify the database schema is ready.
"""
import os
import sys

# Setup Django
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')

try:
    import django
    django.setup()
    
    from django.db import connection
    from users.models import User
    
    print("\n" + "="*70)
    print("  NOTIFICATION SYSTEM DIAGNOSTIC")
    print("="*70 + "\n")
    
    # Test 1: Database connection
    print("Test 1: Database Connection")
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT version();")
            version = cursor.fetchone()[0]
            print(f"✅ Connected to PostgreSQL: {version[:50]}...")
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        sys.exit(1)
    
    # Test 2: Check if notifications table exists
    print("\nTest 2: Notifications Table")
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = 'notifications'
                );
            """)
            exists = cursor.fetchone()[0]
            if exists:
                cursor.execute("SELECT COUNT(*) FROM notifications;")
                count = cursor.fetchone()[0]
                print(f"✅ notifications table exists ({count} records)")
            else:
                print("❌ notifications table NOT FOUND")
                print("\n⚠️  ACTION REQUIRED:")
                print("   1. Go to: https://usddlozrhceftmnhnknw.supabase.co")
                print("   2. Navigate to: SQL Editor")
                print("   3. Copy file: backend/notifications/supabase_setup.sql")
                print("   4. Paste and click RUN")
                sys.exit(1)
    except Exception as e:
        print(f"❌ Error checking notifications table: {e}")
        sys.exit(1)
    
    # Test 3: Check if notification_events table exists
    print("\nTest 3: Notification Events Table (for Realtime)")
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = 'notification_events'
                );
            """)
            exists = cursor.fetchone()[0]
            if exists:
                cursor.execute("SELECT COUNT(*) FROM notification_events;")
                count = cursor.fetchone()[0]
                print(f"✅ notification_events table exists ({count} records)")
            else:
                print("❌ notification_events table NOT FOUND")
                print("   This table is required for realtime notifications")
                sys.exit(1)
    except Exception as e:
        print(f"❌ Error checking notification_events table: {e}")
    
    # Test 4: Check if user_devices table exists
    print("\nTest 4: User Devices Table (for Push Notifications)")
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables 
                    WHERE table_schema = 'public' 
                    AND table_name = 'user_devices'
                );
            """)
            exists = cursor.fetchone()[0]
            if exists:
                cursor.execute("SELECT COUNT(*) FROM user_devices;")
                count = cursor.fetchone()[0]
                print(f"✅ user_devices table exists ({count} devices)")
            else:
                print("⚠️  user_devices table NOT FOUND (optional for FCM)")
    except Exception as e:
        print(f"⚠️  Error checking user_devices table: {e}")
    
    # Test 5: Check for users
    print("\nTest 5: User Accounts")
    try:
        user_count = User.objects.count()
        if user_count > 0:
            print(f"✅ {user_count} users in database")
            test_user = User.objects.first()
            print(f"   Sample user: {test_user.username} (ID: {test_user.id})")
        else:
            print("⚠️  No users found in database")
            print("   Create a user account first to test notifications")
    except Exception as e:
        print(f"❌ Error querying users: {e}")
    
    # Test 6: Check RLS policies
    print("\nTest 6: Row Level Security (RLS) Policies")
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT 
                    tablename, 
                    policyname,
                    cmd
                FROM pg_policies 
                WHERE schemaname = 'public' 
                AND tablename IN ('notifications', 'notification_events', 'user_devices')
                ORDER BY tablename, policyname;
            """)
            policies = cursor.fetchall()
            if policies:
                print(f"✅ {len(policies)} RLS policies found:")
                for table, policy, cmd in policies:
                    print(f"   - {table}: {policy} ({cmd})")
            else:
                print("⚠️  No RLS policies found")
                print("   RLS policies are recommended for security")
    except Exception as e:
        print(f"⚠️  Could not check RLS policies: {e}")
    
    print("\n" + "="*70)
    print("  DIAGNOSTIC COMPLETE")
    print("="*70 + "\n")
    
    print("Summary:")
    print("✅ = Working correctly")
    print("⚠️  = Warning (may need attention)")
    print("❌ = Critical issue (must be fixed)")
    
    print("\nNext Steps:")
    print("1. If tables are missing, run the SQL setup in Supabase")
    print("2. Test from Flutter: flutter run")
    print("3. Create a test notification via Django admin or API")
    print("4. Check the Flutter app for real-time updates")
    
except Exception as e:
    print(f"\n❌ FATAL ERROR: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
