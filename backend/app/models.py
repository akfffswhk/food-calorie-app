"""
Database models for MongoDB
"""

from datetime import datetime
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from bson import ObjectId


class PyObjectId(ObjectId):
    """Custom ObjectId for Pydantic"""

    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid ObjectId")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")


class User(BaseModel):
    """User model"""
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    auth0_id: str
    email: str
    daily_calorie_goal: int = 2000
    dietary_preferences: List[str] = []
    allergies: List[str] = []
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


class FoodItemModel(BaseModel):
    """Food item in analysis"""
    name: str
    confidence: float
    portion: str
    estimated_grams: int


class Macros(BaseModel):
    """Macronutrients"""
    protein: float
    carbs: float
    fat: float
    fiber: float = 0
    sugar: float = 0


class Analysis(BaseModel):
    """Food analysis result"""
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    user_id: PyObjectId
    image_url: Optional[str] = None
    meal_type: str = "snack"  # breakfast, lunch, dinner, snack
    calories: int
    macros: Macros
    items: List[FoodItemModel]
    source: str  # lm_studio, hugging_face, fallback
    confidence: float
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


class Suggestion(BaseModel):
    """Meal/recipe suggestion"""
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    user_id: PyObjectId
    type: str  # meal, recipe, alternative
    title: str
    description: str
    calories: int
    macros: Macros
    ingredients: List[str] = []
    prep_time: Optional[str] = None
    image_url: Optional[str] = None
    is_favorite: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}


class DailySummary(BaseModel):
    """Daily calorie summary"""
    id: Optional[PyObjectId] = Field(default_factory=PyObjectId, alias="_id")
    user_id: PyObjectId
    date: datetime
    total_calories: int
    meals: Dict[str, int] = Field(default_factory=lambda: {
        "breakfast": 0,
        "lunch": 0,
        "dinner": 0,
        "snacks": 0
    })
    macros: Macros
    goal_met: bool = False
    streak_days: int = 0

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
