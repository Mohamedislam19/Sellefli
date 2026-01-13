# Render Deployment Guide for Sellefli Backend

## Overview

This guide walks you through deploying the Sellefli Django backend on [Render.com](https://render.com).

---

## Prerequisites

1. Your existing GitHub repository with the Sellefli project
2. A Render account (free tier available at [render.com](https://render.com))
3. Your Supabase credentials ready

---

## Step 1: Push Backend Changes to GitHub

Since your repo already exists, commit and push the backend deployment files:

```bash
# Navigate to project root (where your repo is)
cd d:/Sellefli

# Add the new backend deployment files
git add backend/requirements.txt backend/build.sh backend/render.yaml backend/Procfile backend/runtime.txt backend/.gitignore

# Commit changes
git commit -m "Add Render deployment configuration"

# Push to GitHub (use your current branch - main, master, or any other)
git push origin YOUR_BRANCH_NAME
```

**Note:** You can use any branch name (main, master, develop, etc.). Render lets you select which branch to deploy from.

---

## Step 2: Create a New Web Service on Render

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your existing GitHub repository
4. Configure the service:

| Setting            | Value                                                                                  |
| ------------------ | -------------------------------------------------------------------------------------- |
| **Name**           | `sellefli-backend`                                                                     |
| **Region**         | Frankfurt (EU) - closest to Supabase                                                   |
| **Branch**         | Your branch name (main/master/etc.) - **you can choose any branch**                    |
| **Root Directory** | `backend`                                                                              |
| **Runtime**        | Python 3                                                                               |
| **Build Command**  | `./build.sh`                                                                           |
| **Start Command**  | `gunicorn wsgi:application --bind 0.0.0.0:$PORT --workers 2 --threads 4 --timeout 120` |
| **Plan**           | Free (or Starter for production)                                                       |

---

## Step 3: Set Environment Variables

In Render Dashboard → Your Service → **Environment** tab, add these variables:

### Required Variables

| Key             | Value                                          | Description        |
| --------------- | ---------------------------------------------- | ------------------ |
| `SECRET_KEY`    | _(auto-generated or set custom)_               | Django secret key  |
| `DEBUG`         | `False`                                        | Disable debug mode |
| `ALLOWED_HOSTS` | `sellefli-backend.onrender.com,*.onrender.com` | Your Render domain |

### Supabase Database Variables

| Key                    | Value                                    |
| ---------------------- | ---------------------------------------- |
| `SUPABASE_DB_NAME`     | `postgres`                               |
| `SUPABASE_DB_USER`     | `postgres.usddlozrhceftmnhnknw`          |
| `SUPABASE_DB_PASSWORD` | Your Supabase database password          |
| `SUPABASE_DB_HOST`     | `aws-1-eu-central-1.pooler.supabase.com` |
| `SUPABASE_DB_PORT`     | `6543`                                   |

### Supabase API Variables

| Key                         | Value                                      |
| --------------------------- | ------------------------------------------ |
| `SUPABASE_URL`              | `https://usddlozrhceftmnhnknw.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Your service role key                      |
| `SUPABASE_JWT_SECRET`       | Your JWT secret                            |

### Optional Variables

| Key              | Value        | Description            |
| ---------------- | ------------ | ---------------------- |
| `FCM_SERVER_KEY` | Your FCM key | For push notifications |

---

## Step 4: Deploy

1. Click **"Create Web Service"**
2. Render will automatically:

   - Install dependencies from `requirements.txt`
   - Run `./build.sh` (migrations + static files)
   - Start the Gunicorn server

3. Wait for deployment to complete (usually 2-5 minutes)

---

## Step 5: Verify Deployment

Once deployed, test the health endpoint:

```bash
curl https://sellefli-backend.onrender.com/api/health/
```

Expected response:

```json
{ "status": "healthy", "service": "sellefli-backend" }
```

---

## Step 6: Update Flutter App

Update your Flutter app to use the Render URL:

```dart
// In your API configuration file
const String baseUrl = 'https://sellefli-backend.onrender.com';
```

---

## Files Created for Render

| File               | Purpose                                         |
| ------------------ | ----------------------------------------------- |
| `requirements.txt` | Python dependencies                             |
| `render.yaml`      | Render Blueprint (optional auto-deploy config)  |
| `build.sh`         | Build script for migrations & static files      |
| `Procfile`         | Process definition (alternative to render.yaml) |
| `runtime.txt`      | Python version specification                    |

---

## Troubleshooting

### Cold Starts (Free Tier)

- Free tier services spin down after 15 minutes of inactivity
- First request after spin-down takes 30-60 seconds
- Solution: Upgrade to Starter plan ($7/month) for always-on

### Database Connection Issues

- Ensure `SUPABASE_DB_PORT` is `6543` (pooler port)
- Check that Supabase allows connections from Render IPs

### Static Files Not Loading

- Verify `whitenoise` is in requirements.txt
- Check that `collectstatic` ran in build logs

### Logs

View logs in Render Dashboard → Your Service → **Logs** tab

---

## Production Checklist

- [ ] Set `DEBUG=False`
- [ ] Use strong `SECRET_KEY`
- [ ] Configure proper `ALLOWED_HOSTS`
- [ ] Set up Supabase environment variables
- [ ] Test health endpoint
- [ ] Test API endpoints from Flutter app
- [ ] Consider upgrading from Free tier for production

---

## Support

- [Render Documentation](https://render.com/docs)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
