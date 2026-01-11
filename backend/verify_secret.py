import jwt
import base64

jwt_secret = 'zHhSOVlj/BQ6paZTPtfKFz7P3BNFrAEyEJeYkOKhfHgphqzBjaFfT/AUKFwKlbrJUsJysAcjLhJUiLiR2YJl3A=='
service_role_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzZGRsb3pyaGNlZnRtbmhua253Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Mzk4OTk1MiwiZXhwIjoyMDc5NTY1OTUyfQ.uOEpqEpoxtKzxqMY6__HE5vhLlR3F1WHSjMorNI9IV4'

print('Testing if JWT secret can verify service_role_key...')
print(f'JWT secret length: {len(jwt_secret)}')

# Try raw secret
try:
    payload = jwt.decode(service_role_key, jwt_secret, algorithms=['HS256'], options={'verify_aud': False})
    print('SUCCESS with raw secret:', payload)
except Exception as e:
    print('FAILED with raw secret:', e)

# Try base64 decoded
try:
    decoded_secret = base64.b64decode(jwt_secret)
    payload = jwt.decode(service_role_key, decoded_secret, algorithms=['HS256'], options={'verify_aud': False})
    print('SUCCESS with base64 decoded:', payload)
except Exception as e:
    print('FAILED with base64 decoded:', e)

print('\n*** The JWT secret in .env is WRONG if both tests failed ***')
print('Please get the correct secret from:')
print('Supabase Dashboard -> Settings -> API -> JWT Settings -> JWT Secret')
