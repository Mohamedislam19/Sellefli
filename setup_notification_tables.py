"""
Automatically execute the notification SQL setup script in Supabase.
This creates all required tables, indexes, and policies.
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
    
    print("\n" + "="*70)
    print("  SETTING UP NOTIFICATION TABLES IN SUPABASE")
    print("="*70 + "\n")
    
    # Read the SQL setup file
    sql_file = os.path.join(os.path.dirname(__file__), 'backend', 'notifications', 'supabase_setup.sql')
    
    print(f"Reading SQL file: {sql_file}")
    with open(sql_file, 'r', encoding='utf-8') as f:
        sql_content = f.read()
    
    print(f"✅ SQL file loaded ({len(sql_content)} characters)\n")
    
    # Execute the SQL
    print("Executing SQL setup script...")
    print("This will create:")
    print("  - notifications table")
    print("  - notification_events table")
    print("  - user_devices table")
    print("  - Indexes for performance")
    print("  - Row Level Security policies")
    print()
    
    with connection.cursor() as cursor:
        try:
            # Execute the entire SQL script
            cursor.execute(sql_content)
            print("✅ SQL script executed successfully!\n")
            
            # Verify tables were created
            print("Verifying tables...")
            
            tables = ['notifications', 'notification_events', 'user_devices']
            for table in tables:
                cursor.execute(f"""
                    SELECT EXISTS (
                        SELECT FROM information_schema.tables 
                        WHERE table_schema = 'public' 
                        AND table_name = '{table}'
                    );
                """)
                exists = cursor.fetchone()[0]
                if exists:
                    cursor.execute(f"SELECT COUNT(*) FROM {table};")
                    count = cursor.fetchone()[0]
                    print(f"  ✅ {table} table created ({count} records)")
                else:
                    print(f"  ❌ {table} table NOT created")
            
            # Check policies
            print("\nVerifying Row Level Security policies...")
            cursor.execute("""
                SELECT COUNT(*) 
                FROM pg_policies 
                WHERE schemaname = 'public' 
                AND tablename IN ('notifications', 'notification_events', 'user_devices');
            """)
            policy_count = cursor.fetchone()[0]
            print(f"  ✅ {policy_count} RLS policies created")
            
            # Check indexes
            print("\nVerifying indexes...")
            cursor.execute("""
                SELECT COUNT(*) 
                FROM pg_indexes 
                WHERE schemaname = 'public' 
                AND tablename IN ('notifications', 'notification_events', 'user_devices');
            """)
            index_count = cursor.fetchone()[0]
            print(f"  ✅ {index_count} indexes created")
            
        except Exception as e:
            print(f"\n❌ Error executing SQL: {e}")
            print("\nThis might happen if tables already exist or if there are permission issues.")
            print("You can try running the SQL manually in Supabase SQL Editor.")
            sys.exit(1)
    
    print("\n" + "="*70)
    print("  SETUP COMPLETE!")
    print("="*70 + "\n")
    
    print("⚠️  IMPORTANT: Enable Realtime in Supabase Dashboard")
    print("1. Go to: https://usddlozrhceftmnhnknw.supabase.co")
    print("2. Navigate to: Database → Replication")
    print("3. Find 'notification_events' table")
    print("4. Toggle Realtime ON")
    print("5. Click Save")
    print()
    print("Then test your notification system with:")
    print("  python diagnose_notifications.py")
    print()
    
except Exception as e:
    print(f"\n❌ FATAL ERROR: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
