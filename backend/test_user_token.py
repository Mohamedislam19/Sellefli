import jwt
import json

# Paste the actual token from Flutter console here
# Look for: [ItemRepository] Token (first 50 chars): eyJhbGc...
# Then get the full token
token = input("Paste the full user token from Flutter: ").strip()

if not token:
    print("No token provided")
    exit(1)

# Decode without verification to see what's inside
print("\n--- Decoding token without verification ---")
try:
    unverified = jwt.decode(token, options={"verify_signature": False})
    print(json.dumps(unverified, indent=2))
    print(f"\nAudience: {unverified.get('aud')}")
    print(f"Issuer: {unverified.get('iss')}")
    print(f"User ID (sub): {unverified.get('sub')}")
except Exception as e:
    print(f"Error: {e}")
    exit(1)

# Now try to verify with the JWT secret
jwt_secret = 'zHhSOVlj/BQ6paZTPtfKFz7P3BNFrAEyEJeYkOKhfHgphqzBjaFfT/AUKFwKlbrJUsJysAcjLhJUiLiR2YJl3A=='

print("\n--- Verifying signature ---")
try:
    # Try with audience='authenticated'
    verified = jwt.decode(token, jwt_secret, algorithms=["HS256"], audience="authenticated")
    print("SUCCESS! Token verified with audience='authenticated'")
    print(json.dumps(verified, indent=2))
except jwt.InvalidAudienceError as e:
    print(f"Failed with audience='authenticated': {e}")
    print("\nTrying without audience check...")
    try:
        verified = jwt.decode(token, jwt_secret, algorithms=["HS256"], options={"verify_aud": False})
        print("SUCCESS! Token verified without audience check")
        print(json.dumps(verified, indent=2))
    except Exception as e2:
        print(f"Failed: {e2}")
except Exception as e:
    print(f"Failed: {e}")
