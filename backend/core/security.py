from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from backend.core.config import settings
from supabase import create_client, Client

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        
        # Verify user in Supabase
        user = supabase.auth.get_user(token)
        if not user:
            raise credentials_exception
        
        # Get profile for role
        profile = supabase.table("profiles").select("*").eq("id", user_id).single().execute()
        return profile.data
    except JWTError:
        raise credentials_exception

def RoleChecker(allowed_roles: list):
    def role_checker(user: dict = Depends(get_current_user)):
        if user.get("role") not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have enough permissions"
            )
        return user
    return role_checker
