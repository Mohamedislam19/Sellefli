# Django Backend Setup and Database Initialization

## Quick Start

The Sellefli backend uses Django with PostgreSQL (hosted on Supabase).

### Prerequisites

1. **Python 3.8+** installed
2. **PostgreSQL credentials** configured in `.env` file

### Environment Variables

Create a `.env` file in the `backend/` directory with the following variables:

```
SUPABASE_DB_NAME=your_db_name
SUPABASE_DB_USER=your_db_user
SUPABASE_DB_PASSWORD=your_password
SUPABASE_DB_HOST=your_host.supabase.com
SUPABASE_DB_PORT=5432
SUPABASE_DB_SSLMODE=require
```

### Installation & Initialization

1. **Install dependencies:**
   ```bash
   pip install django djangorestframework psycopg2-binary python-dotenv
   ```

2. **Initialize the database tables:**
   ```bash
   python db_init.py
   ```
   
   This will:
   - Apply all Django migrations
   - Create all required tables in PostgreSQL
   - Display migration status

3. **Run the development server:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

## Database Structure

The following Django apps and their tables are initialized:

### Apps
- **users** - User authentication and profiles
- **items** - Item listings with details
- **item_images** - Image management for items
- **bookings** - Booking/reservation system
- **ratings** - Rating and review system

### Running Migrations Manually

If you need to run migrations manually:

```bash
# Show migration status
python manage.py showmigrations

# Apply migrations
python manage.py migrate

# Create a new migration (if model changes are made)
python manage.py makemigrations
```

## Verifying Tables Were Created

After running `db_init.py`, you can verify tables exist by:

1. Checking the migration status (shown in the script output)
2. Accessing the Supabase dashboard
3. Running: `python manage.py dbshell` (requires psql installed)

## Troubleshooting

**Connection Error:** Verify `.env` variables and Supabase credentials
**Migration Error:** Check that all app models are defined correctly
**Permission Error:** Ensure your database user has CREATE TABLE permissions
