"""
Suggestions API endpoints
"""

from fastapi import APIRouter, HTTPException, Depends, status, Query
from pydantic import BaseModel
from typing import Optional, List
from bson import ObjectId

from app.auth import get_current_user
from app.database import get_suggestions_collection
from app.services.suggestion_service import SuggestionService

router = APIRouter(prefix="/api/suggestions", tags=["Suggestions"])


# Response Models
class MacrosModel(BaseModel):
    protein: float
    carbs: float
    fat: float
    fiber: float
    sugar: float


class SuggestionResponse(BaseModel):
    id: str
    type: str
    title: str
    description: str
    calories: int
    macros: MacrosModel
    ingredients: List[str]
    prep_time: Optional[str]
    image_url: Optional[str]
    is_favorite: bool


class AlternativeResponse(BaseModel):
    name: str
    calories: int
    calories_saved: int
    reduction_percent: int
    reason: str


@router.get("", response_model=List[SuggestionResponse])
async def get_suggestions(
    meal_type: Optional[str] = Query(None, regex="^(breakfast|lunch|dinner|snack|any)$"),
    remaining_calories: Optional[int] = Query(None, ge=0),
    current_user: dict = Depends(get_current_user)
):
    """
    Get meal suggestions based on remaining calories

    - **meal_type**: Filter by meal type (breakfast, lunch, dinner, snack, any)
    - **remaining_calories**: Maximum calories for suggestions
    """
    suggestions_collection = get_suggestions_collection()
    user_id = ObjectId(current_user["user_id"])

    # Get user's remaining calories if not provided
    if remaining_calories is None:
        remaining_calories = 500  # Default

    # Get suggestions from database
    cursor = suggestions_collection.find({
        "user_id": user_id,
        "calories": {"$lte": remaining_calories}
    })

    if meal_type and meal_type != "any":
        cursor = suggestions_collection.find({
            "user_id": user_id,
            "type": meal_type,
            "calories": {"$lte": remaining_calories}
        })

    suggestions = []
    async for doc in cursor:
        doc["id"] = str(doc["_id"])
        del doc["_id"]
        del doc["user_id"]
        suggestions.append(SuggestionResponse(**doc))

    # If no custom suggestions, use service defaults
    if not suggestions:
        suggestion_service = SuggestionService(suggestions_collection)
        suggestions_data = await suggestion_service.get_meal_suggestions(
            str(user_id),
            remaining_calories,
            meal_type or "any"
        )

        for s in suggestions_data:
            suggestions.append(SuggestionResponse(
                id=s.get("id", ""),
                type=s.get("type", "meal"),
                title=s.get("title", ""),
                description=s.get("description", ""),
                calories=s.get("calories", 0),
                macros=MacrosModel(**s.get("macros", {"protein": 0, "carbs": 0, "fat": 0, "fiber": 0, "sugar": 0})),
                ingredients=s.get("ingredients", []),
                prep_time=s.get("prep_time"),
                image_url=s.get("image_url"),
                is_favorite=s.get("is_favorite", False)
            ))

    return suggestions[:10]


@router.get("/meal")
async def get_meal_suggestions(
    remaining_calories: int = Query(..., ge=0),
    current_user: dict = Depends(get_current_user)
):
    """
    Get meal suggestions specifically

    - **remaining_calories**: Maximum calories for suggestions
    """
    suggestions_collection = get_suggestions_collection()
    user_id = ObjectId(current_user["user_id"])

    suggestion_service = SuggestionService(suggestions_collection)
    suggestions = await suggestion_service.get_meal_suggestions(
        str(user_id),
        remaining_calories,
        "any"
    )

    return suggestions


@router.get("/recipe")
async def get_recipe_suggestions(
    ingredients: List[str] = Query(...),
    max_calories: int = Query(500, ge=0),
    current_user: dict = Depends(get_current_user)
):
    """
    Get recipe suggestions based on available ingredients

    - **ingredients**: List of available ingredients
    - **max_calories**: Maximum calories for recipes
    """
    suggestions_collection = get_suggestions_collection()
    user_id = ObjectId(current_user["user_id"])

    suggestion_service = SuggestionService(suggestions_collection)
    recipes = await suggestion_service.get_recipe_suggestions(
        ingredients,
        max_calories
    )

    return recipes


@router.get("/alternative/{food_name}", response_model=List[AlternativeResponse])
async def get_alternative_suggestions(
    food_name: str,
    current_calories: int = Query(..., ge=0),
    current_user: dict = Depends(get_current_user)
):
    """
    Get healthier alternatives for a food item

    - **food_name**: Name of the food to find alternatives for
    - **current_calories**: Current calorie count of the food
    """
    suggestions_collection = get_suggestions_collection()

    suggestion_service = SuggestionService(suggestions_collection)
    alternatives = await suggestion_service.get_alternative_suggestions(
        food_name,
        current_calories
    )

    return [
        AlternativeResponse(**alt) for alt in alternatives
    ]


@router.post("/favorite/{suggestion_id}")
async def toggle_favorite(
    suggestion_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Toggle favorite status of a suggestion

    - **suggestion_id**: ID of the suggestion
    """
    suggestions_collection = get_suggestions_collection()
    user_id = ObjectId(current_user["user_id"])

    try:
        doc = await suggestions_collection.find_one({
            "_id": ObjectId(suggestion_id),
            "user_id": user_id
        })
    except:
        raise HTTPException(
            status_code=400,
            detail="Invalid suggestion ID"
        )

    if not doc:
        raise HTTPException(
            status_code=404,
            detail="Suggestion not found"
        )

    # Toggle favorite status
    new_status = not doc.get("is_favorite", False)
    await suggestions_collection.update_one(
        {"_id": ObjectId(suggestion_id)},
        {"$set": {"is_favorite": new_status}}
    )

    return {
        "message": "Favorite status updated",
        "is_favorite": new_status
    }


@router.get("/favorites", response_model=List[SuggestionResponse])
async def get_favorites(current_user: dict = Depends(get_current_user)):
    """
    Get user's favorite suggestions
    """
    suggestions_collection = get_suggestions_collection()
    user_id = ObjectId(current_user["user_id"])

    cursor = suggestions_collection.find({
        "user_id": user_id,
        "is_favorite": True
    })

    favorites = []
    async for doc in cursor:
        doc["id"] = str(doc["_id"])
        del doc["_id"]
        del doc["user_id"]
        favorites.append(SuggestionResponse(**doc))

    return favorites
