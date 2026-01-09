import jwt
import base64
import os

# Hardcode the secret for testing
jwt_secret = 'PgxPBiG3p19WxjhKRazA2p0cK8nAVTcaYHGOV1AChz+y9NxF+TLT8i+3RWPBBhm0wvZB6FRVsXQyZnI53aCj3A=='
print(f"JWT Secret (first 30 chars): {jwt_secret[:30]}...")
print(f"JWT Secret length: {len(jwt_secret)}")

# If you have a real user token from Flutter, paste it here
real_token = input("\nPaste a real user access token from Flutter (or press Enter to skip): ").strip()

if real_token:
    print(f"\n--- Decoding real token ---")
    print(f"Token length: {len(real_token)}")
    print(f"Token (first 50 chars): {real_token[:50]}...")
    
    # First decode without verification to see payload
    try:
        unverified = jwt.decode(real_token, options={"verify_signature": False})
        print(f"Unverified payload: {unverified}")
    except Exception as e:
        print(f"Could not decode token: {e}")
    
    # Try verifying with raw secret
    print("\n--- Trying to verify ---")
    try:
        payload = jwt.decode(real_token, jwt_secret, algorithms=["HS256"], audience="authenticated")
        print(f"1. Raw secret: SUCCESS! {payload}")
    except Exception as e:
        print(f"1. Raw secret failed: {e}")
    
    # Try with base64 decoded secret
    try:
        decoded_secret = base64.b64decode(jwt_secret)
        payload = jwt.decode(real_token, decoded_secret, algorithms=["HS256"], audience="authenticated")
        print(f"2. Base64 decoded: SUCCESS! {payload}")
    except Exception as e:
        print(f"2. Base64 decoded failed: {e}")
    
    # Try without audience
    try:
        payload = jwt.decode(real_token, jwt_secret, algorithms=["HS256"], options={"verify_aud": False})
        print(f"3. No audience: SUCCESS! {payload}")
    except Exception as e:
        print(f"3. No audience failed: {e}")
else:
    print("\nNo token provided, running self-test only")
    
    # Test payload similar to what Supabase sends
    test_payload = {'sub': 'test-user-id', 'aud': 'authenticated'}

    print("\n--- Testing different approaches ---")

    # Approach 1: Use secret as-is
    try:
        token = jwt.encode(test_payload, jwt_secret, algorithm='HS256')
        decoded = jwt.decode(token, jwt_secret, algorithms=['HS256'], audience='authenticated')
        print(f"1. Raw secret works: {decoded}")
    except Exception as e:
        print(f"1. Raw secret failed: {e}")

    # Approach 2: Base64 decode the secret
    try:
        decoded_secret = base64.b64decode(jwt_secret)
        token = jwt.encode(test_payload, decoded_secret, algorithm='HS256')
        decoded = jwt.decode(token, decoded_secret, algorithms=['HS256'], audience='authenticated')
        print(f"2. Base64 decoded secret works: {decoded}")
    except Exception as e:
        print(f"2. Base64 decoded secret failed: {e}")
