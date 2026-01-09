import logging
import jwt
from datetime import datetime
from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

logger = logging.getLogger(__name__)
User = get_user_model()


class SupabaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            logger.debug("No Authorization header found")
            return None

        try:
            prefix, token = auth_header.split()
            if prefix.lower() != 'bearer':
                logger.debug(f"Invalid auth prefix: {prefix}")
                return None
        except ValueError:
            logger.debug("Could not parse Authorization header")
            return None

        logger.info(f"Token received (first 50 chars): {token[:50]}...")
        
        # First, decode WITHOUT verification to see what's in the token
        try:
            unverified = jwt.decode(token, options={"verify_signature": False})
            header = jwt.get_unverified_header(token)
            logger.info(f"Token header: {header}")
            logger.info(f"Token payload (unverified): sub={unverified.get('sub')}, email={unverified.get('email')}, role={unverified.get('role')}, aud={unverified.get('aud')}")
            
            # Check expiration manually
            exp = unverified.get('exp', 0)
            now = datetime.utcnow().timestamp()
            if exp > now:
                logger.info(f"Token NOT expired. Expires in {int(exp - now)} seconds")
            else:
                logger.warning(f"Token EXPIRED {int(now - exp)} seconds ago")
        except Exception as e:
            logger.error(f"Failed to decode token (unverified): {e}")
        
        # Now verify with JWT secret
        jwt_secret = settings.SUPABASE_JWT_SECRET
        logger.info(f"JWT secret (first 20 chars): {jwt_secret[:20]}...")
        
        try:
            # Try without audience first to isolate the issue
            payload = jwt.decode(
                token,
                jwt_secret,
                algorithms=["HS256"],
                options={"verify_aud": False}
            )
            logger.info(f"Token verified successfully! user_id: {payload.get('sub')}")
            return self._get_or_create_user(payload, token)
            
        except jwt.ExpiredSignatureError:
            logger.warning("Token has expired (signature was valid though)")
            raise AuthenticationFailed('Token has expired')
        except jwt.InvalidSignatureError:
            logger.error("INVALID SIGNATURE - Wrong JWT secret!")
            raise AuthenticationFailed('Invalid token signature')
        except jwt.InvalidTokenError as e:
            logger.error(f"Token validation failed: {type(e).__name__}: {e}")
            raise AuthenticationFailed(f'Invalid token: {str(e)}')
        
        return self._get_or_create_user(payload, token)
    
    def _get_or_create_user(self, payload, token):
        user_id = payload.get('sub')
        if not user_id:
            raise AuthenticationFailed('User ID not found in token')

        try:
            user = User.objects.get(id=user_id)
            logger.info(f"Found existing user: {user_id}")
        except User.DoesNotExist:
            # Create user if they don't exist (JIT provisioning)
            email = payload.get('email')
            phone = payload.get('phone')  # Default to None if missing
            username = payload.get('user_metadata', {}).get('username') or email or f"user_{user_id[:8]}"
            
            logger.info(f"Creating new user: {user_id}, email: {email}")
            user = User.objects.create(
                id=user_id,
                email=email,
                username=username,
                phone=phone
            )

        return (user, token)
