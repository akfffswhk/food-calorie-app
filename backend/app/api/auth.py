"""
Authentication API endpoints
"""

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from bson import ObjectId

from app.auth import (
    verify_password,
    get_password_hash,
    create_access_token,
    decode_access_token,
    get_current_user
)
from app.database import get_users_collection, get_sessions_collection

router = APIRouter(prefix="/api/auth", tags=["Authentication"])


# Request/Response Models
class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=100)
    username: Optional[str] = None


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: str
    email: str
    username: Optional[str] = None
    daily_calorie_goal: int = 2000
    dietary_preferences: list = []
    allergies: list = []
    created_at: datetime


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class ErrorResponse(BaseModel):
    detail: str


@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegisterRequest):
    """
    Register a new user

    - **email**: User's email address (must be unique)
    - **password**: User's password (min 6 characters)
    - **username**: Optional username
    """
    users_collection = get_users_collection()

    # Check if user already exists
    existing_user = await users_collection.find_one({"email": user_data.email})
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Check if username is taken (if provided)
    if user_data.username:
        existing_username = await users_collection.find_one({"username": user_data.username})
        if existing_username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already taken"
            )

    # Create new user
    user_document = {
        "email": user_data.email,
        "password_hash": get_password_hash(user_data.password),
        "username": user_data.username,
        "daily_calorie_goal": 2000,
        "dietary_preferences": [],
        "allergies": [],
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
        "is_active": True
    }

    result = await users_collection.insert_one(user_document)
    user_id = str(result.inserted_id)

    # Create access token
    token_data = {
        "sub": user_id,
        "email": user_data.email,
        "username": user_data.username
    }
    access_token = create_access_token(token_data)

    # Return user data
    user_response = UserResponse(
        id=user_id,
        email=user_data.email,
        username=user_data.username,
        daily_calorie_goal=2000,
        dietary_preferences=[],
        allergies=[],
        created_at=user_document["created_at"]
    )

    return AuthResponse(
        access_token=access_token,
        user=user_response
    )


@router.post("/login", response_model=AuthResponse)
async def login(credentials: UserLoginRequest):
    """
    Login with email and password

    - **email**: User's email address
    - **password**: User's password
    """
    users_collection = get_users_collection()

    # Find user by email
    user = await users_collection.find_one({"email": credentials.email})
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Verify password
    if not verify_password(credentials.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Check if user is active
    if not user.get("is_active", True):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is deactivated"
        )

    user_id = str(user["_id"])

    # Create access token
    token_data = {
        "sub": user_id,
        "email": user["email"],
        "username": user.get("username")
    }
    access_token = create_access_token(token_data)

    # Store session (optional - for session management)
    sessions_collection = get_sessions_collection()
    await sessions_collection.insert_one({
        "user_id": ObjectId(user_id),
        "token": access_token,
        "created_at": datetime.utcnow(),
        "expires_at": datetime.utcnow(),  # Will be updated with actual expiry
        "is_active": True
    })

    # Return user data
    user_response = UserResponse(
        id=user_id,
        email=user["email"],
        username=user.get("username"),
        daily_calorie_goal=user.get("daily_calorie_goal", 2000),
        dietary_preferences=user.get("dietary_preferences", []),
        allergies=user.get("allergies", []),
        created_at=user["created_at"]
    )

    return AuthResponse(
        access_token=access_token,
        user=user_response
    )


@router.post("/logout")
async def logout(current_user: dict = Depends(get_current_user)):
    """
    Logout the current user

    Invalidates the current session
    """
    sessions_collection = get_sessions_collection()

    # Deactivate all sessions for this user
    await sessions_collection.update_many(
        {"user_id": ObjectId(current_user["user_id"])},
        {"$set": {"is_active": False}}
    )

    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: dict = Depends(get_current_user)):
    """
    Get current user information

    Returns the profile of the authenticated user
    """
    users_collection = get_users_collection()

    user = await users_collection.find_one({"_id": ObjectId(current_user["user_id"])})
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return UserResponse(
        id=str(user["_id"]),
        email=user["email"],
        username=user.get("username"),
        daily_calorie_goal=user.get("daily_calorie_goal", 2000),
        dietary_preferences=user.get("dietary_preferences", []),
        allergies=user.get("allergies", []),
        created_at=user["created_at"]
    )


@router.post("/refresh")
async def refresh_token(current_user: dict = Depends(get_current_user)):
    """
    Refresh the access token

    Returns a new access token for the authenticated user
    """
    users_collection = get_users_collection()

    user = await users_collection.find_one({"_id": ObjectId(current_user["user_id"])})
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    # Create new access token
    token_data = {
        "sub": str(user["_id"]),
        "email": user["email"],
        "username": user.get("username")
    }
    access_token = create_access_token(token_data)

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }
