"""
Profile API endpoints
"""

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from bson import ObjectId

from app.auth import get_current_user, verify_password, get_password_hash
from app.database import get_users_collection

router = APIRouter(prefix="/api/profile", tags=["Profile"])


# Request/Response Models
class ProfileResponse(BaseModel):
    id: str
    email: str
    username: Optional[str] = None
    daily_calorie_goal: int
    dietary_preferences: List[str]
    allergies: List[str]
    created_at: datetime
    updated_at: datetime


class UpdateProfileRequest(BaseModel):
    username: Optional[str] = None
    dietary_preferences: Optional[List[str]] = None
    allergies: Optional[List[str]] = None


class UpdateGoalsRequest(BaseModel):
    daily_calorie_goal: int = Field(..., ge=1200, le=5000)


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=6, max_length=100)


@router.get("", response_model=ProfileResponse)
async def get_profile(current_user: dict = Depends(get_current_user)):
    """
    Get user profile information
    """
    users_collection = get_users_collection()
    user_id = ObjectId(current_user["user_id"])

    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return ProfileResponse(
        id=str(user["_id"]),
        email=user["email"],
        username=user.get("username"),
        daily_calorie_goal=user.get("daily_calorie_goal", 2000),
        dietary_preferences=user.get("dietary_preferences", []),
        allergies=user.get("allergies", []),
        created_at=user["created_at"],
        updated_at=user["updated_at"]
    )


@router.put("", response_model=ProfileResponse)
async def update_profile(
    profile_data: UpdateProfileRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Update user profile

    - **username**: Optional new username
    - **dietary_preferences**: Optional list of dietary preferences
    - **allergies**: Optional list of allergies
    """
    users_collection = get_users_collection()
    user_id = ObjectId(current_user["user_id"])

    # Check if username is taken (if provided)
    if profile_data.username:
        existing = await users_collection.find_one({
            "username": profile_data.username,
            "_id": {"$ne": user_id}
        })
        if existing:
            raise HTTPException(
                status_code=400,
                detail="Username already taken"
            )

    # Build update document
    update_data = {"updated_at": datetime.utcnow()}
    if profile_data.username is not None:
        update_data["username"] = profile_data.username
    if profile_data.dietary_preferences is not None:
        update_data["dietary_preferences"] = profile_data.dietary_preferences
    if profile_data.allergies is not None:
        update_data["allergies"] = profile_data.allergies

    # Update user
    await users_collection.update_one(
        {"_id": user_id},
        {"$set": update_data}
    )

    # Get updated user
    user = await users_collection.find_one({"_id": user_id})

    return ProfileResponse(
        id=str(user["_id"]),
        email=user["email"],
        username=user.get("username"),
        daily_calorie_goal=user.get("daily_calorie_goal", 2000),
        dietary_preferences=user.get("dietary_preferences", []),
        allergies=user.get("allergies", []),
        created_at=user["created_at"],
        updated_at=user["updated_at"]
    )


@router.put("/goals", response_model=ProfileResponse)
async def update_goals(
    goals_data: UpdateGoalsRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Update user's calorie goals

    - **daily_calorie_goal**: New daily calorie goal (1200-5000)
    """
    users_collection = get_users_collection()
    user_id = ObjectId(current_user["user_id"])

    # Update user
    await users_collection.update_one(
        {"_id": user_id},
        {
            "$set": {
                "daily_calorie_goal": goals_data.daily_calorie_goal,
                "updated_at": datetime.utcnow()
            }
        }
    )

    # Get updated user
    user = await users_collection.find_one({"_id": user_id})

    return ProfileResponse(
        id=str(user["_id"]),
        email=user["email"],
        username=user.get("username"),
        daily_calorie_goal=user["daily_calorie_goal"],
        dietary_preferences=user.get("dietary_preferences", []),
        allergies=user.get("allergies", []),
        created_at=user["created_at"],
        updated_at=user["updated_at"]
    )


@router.post("/change-password")
async def change_password(
    password_data: ChangePasswordRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Change user password

    - **current_password**: Current password for verification
    - **new_password**: New password (min 6 characters)
    """
    users_collection = get_users_collection()
    user_id = ObjectId(current_user["user_id"])

    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # Verify current password
    if not verify_password(password_data.current_password, user["password_hash"]):
        raise HTTPException(
            status_code=400,
            detail="Current password is incorrect"
        )

    # Update password
    await users_collection.update_one(
        {"_id": user_id},
        {
            "$set": {
                "password_hash": get_password_hash(password_data.new_password),
                "updated_at": datetime.utcnow()
            }
        }
    )

    return {"message": "Password changed successfully"}


@router.delete("")
async def delete_account(
    current_user: dict = Depends(get_current_user)
):
    """
    Delete user account

    This will permanently delete the user account and all associated data
    """
    users_collection = get_users_collection()
    user_id = ObjectId(current_user["user_id"])

    # Delete user
    result = await users_collection.delete_one({"_id": user_id})

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # Note: You may want to also delete associated records
    # This is handled by cascading or manual cleanup

    return {"message": "Account deleted successfully"}
