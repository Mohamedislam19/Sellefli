"""
Paste a user token here and run this script to test authentication.
Usage: python test_auth.py
"""
import jwt
import sys
from datetime import datetime

# The JWT secret from Supabase Dashboard
JWT_SECRET = 'zHhSOVlj/BQ6paZTPtfKFz7P3BNFrAEyEJeYkOKhfHgphqzBjaFfT/AUKFwKlbrJUsJysAcjLhJUiLiR2YJl3A=='

# Paste the full token here (from Flutter logs or network inspection)
TOKEN = input("Paste the full JWT token: ").strip()

print("\n" + "="*60)
print("STEP 1: Decode WITHOUT verification")
print("="*60)
try:
    unverified = jwt.decode(TOKEN, options={"verify_signature": False})
    print(f"Header: {jwt.get_unverified_header(TOKEN)}")
    print(f"Payload: {unverified}")
    
    # Check expiration
    exp = unverified.get('exp', 0)
    now = datetime.utcnow().timestamp()
    if exp > now:
        print(f"\n✓ Token NOT expired. Expires in {int(exp - now)} seconds")
    else:
        print(f"\n✗ Token EXPIRED {int(now - exp)} seconds ago")
    
    print(f"\nUser ID (sub): {unverified.get('sub')}")
    print(f"Email: {unverified.get('email')}")
    print(f"Role: {unverified.get('role')}")
    print(f"Audience: {unverified.get('aud')}")
except Exception as e:
    print(f"Error decoding: {e}")
    sys.exit(1)

print("\n" + "="*60)
print("STEP 2: Verify WITH secret (no audience check)")
print("="*60)
try:
    verified = jwt.decode(
        TOKEN, 
        JWT_SECRET, 
        algorithms=["HS256"],
        options={"verify_aud": False}
    )
    print("✓ SUCCESS! Token verified with JWT secret")
    print(f"Payload: {verified}")
except jwt.ExpiredSignatureError:
    print("✗ Token has expired (signature was valid)")
except jwt.InvalidSignatureError:
    print("✗ Invalid signature - WRONG JWT SECRET")
except Exception as e:
    print(f"✗ Error: {type(e).__name__}: {e}")

print("\n" + "="*60)
print("STEP 3: Verify WITH audience='authenticated'")
print("="*60)
try:
    verified = jwt.decode(
        TOKEN, 
        JWT_SECRET, 
        algorithms=["HS256"],
        audience="authenticated"
    )
    print("✓ SUCCESS! Token verified with audience check")
except jwt.InvalidAudienceError:
    print("✗ Invalid audience - token audience doesn't match 'authenticated'")
except jwt.ExpiredSignatureError:
    print("✗ Token has expired")
except jwt.InvalidSignatureError:
    print("✗ Invalid signature")
except Exception as e:
    print(f"✗ Error: {type(e).__name__}: {e}")
