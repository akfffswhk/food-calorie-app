"""
Suggestion service for meal recommendations
"""

from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
import random


class SuggestionService:
    """Service for generating food suggestions"""

    def __init__(self, db):
        self.db = db

    async def get_meal_suggestions(
        self,
        user_id: str,
        remaining_calories: int,
        meal_type: str = "any"
    ) -> List[Dict[str, Any]]:
        """
        Get meal suggestions based on remaining calories

        Args:
            user_id: User ID
            remaining_calories: Calories remaining for the day
            meal_type: breakfast, lunch, dinner, snack, or any
        """
        # Get user preferences
        user = await self.db.users.find_one({"_id": user_id})
        preferences = user.get("dietary_preferences", []) if user else []
        allergies = user.get("allergies", []) if user else []

        # Get suggestions from database or generate
        suggestions = await self._generate_suggestions(
            remaining_calories,
            meal_type,
            preferences,
            allergies
        )

        return suggestions

    async def _generate_suggestions(
        self,
        remaining_calories: int,
        meal_type: str,
        preferences: List[str],
        allergies: List[str]
    ) -> List[Dict[str, Any]]:
        """Generate meal suggestions"""
        suggestions = []

        # Base meal database (in production, this would be in MongoDB)
        meal_database = self._get_meal_database()

        # Filter by meal type
        if meal_type != "any":
            meal_database = [m for m in meal_database if m["type"] == meal_type]

        # Filter by calorie limit
        meal_database = [
            m for m in meal_database
            if m["calories"] <= remaining_calories
        ]

        # Filter by preferences
        if preferences:
            meal_database = [
                m for m in meal_database
                if any(p in m["tags"] for p in preferences)
            ]

        # Filter out allergies
        if allergies:
            meal_database = [
                m for m in meal_database
                if not any(a in m["name"].lower() for a in allergies)
            ]

        # Return top suggestions
        return meal_database[:10]

    async def get_alternative_suggestions(
        self,
        food_name: str,
        current_calories: int
    ) -> List[Dict[str, Any]]:
        """Get healthier alternatives for a food item"""
        alternatives = []

        # Simple alternative database
        alternatives_db = {
            "pizza": [
                {"name": "Cauliflower crust pizza", "calories": 150, "reduction": 50},
                {"name": "Portobello mushroom pizza", "calories": 120, "reduction": 60},
                {"name": "Zucchini pizza boats", "calories": 100, "reduction": 67}
            ],
            "burger": [
                {"name": "Turkey burger", "calories": 250, "reduction": 30},
                {"name": "Veggie burger", "calories": 200, "reduction": 44},
                {"name": "Portobello burger", "calories": 150, "reduction": 58}
            ],
            "fries": [
                {"name": "Baked sweet potato fries", "calories": 120, "reduction": 60},
                {"name": "Air-fried zucchini fries", "calories": 80, "reduction": 73},
                {"name": "Carrot fries", "calories": 60, "reduction": 80}
            ],
            "pasta": [
                {"name": "Zucchini noodles (zoodles)", "calories": 50, "reduction": 85},
                {"name": "Whole wheat pasta", "calories": 150, "reduction": 50},
                {"name": "Lentil pasta", "calories": 180, "reduction": 40}
            ],
            "rice": [
                {"name": "Cauliflower rice", "calories": 25, "reduction": 90},
                {"name": "Quinoa", "calories": 120, "reduction": 50},
                {"name": "Brown rice", "calories": 110, "reduction": 55}
            ]
        }

        food_lower = food_name.lower()
        for key, alts in alternatives_db.items():
            if key in food_lower:
                for alt in alts:
                    alternatives.append({
                        "name": alt["name"],
                        "calories": alt["calories"],
                        "calories_saved": current_calories - alt["calories"],
                        "reduction_percent": alt["reduction"],
                        "reason": f"{alt['reduction']}% fewer calories"
                    })

        return alternatives

    async def get_recipe_suggestions(
        self,
        ingredients: List[str],
        max_calories: int
    ) -> List[Dict[str, Any]]:
        """Get recipe suggestions based on available ingredients"""
        recipes = []

        # Simple recipe database
        recipe_database = self._get_recipe_database()

        # Filter by ingredients
        for recipe in recipe_database:
            matching_ingredients = [
                ing for ing in recipe["ingredients"]
                if any(ing.lower().find(i.lower()) != -1 for i in ingredients)
            ]

            if matching_ingredients and recipe["calories"] <= max_calories:
                recipes.append({
                    **recipe,
                    "matching_ingredients": matching_ingredients,
                    "match_count": len(matching_ingredients)
                })

        # Sort by match count
        recipes.sort(key=lambda x: x["match_count"], reverse=True)

        return recipes[:5]

    def _get_meal_database(self) -> List[Dict[str, Any]]:
        """Get meal database (in production, store in MongoDB)"""
        return [
            # Breakfast
            {
                "id": "b1",
                "name": "Greek Yogurt Parfait",
                "type": "breakfast",
                "calories": 300,
                "prep_time": "5 min",
                "description": "Greek yogurt with berries and granola",
                "tags": ["high-protein", "quick"],
                "macros": {"protein": 20, "carbs": 35, "fat": 8},
                "image_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777"
            },
            {
                "id": "b2",
                "name": "Avocado Toast",
                "type": "breakfast",
                "calories": 350,
                "prep_time": "10 min",
                "description": "Whole grain toast with mashed avocado",
                "tags": ["vegetarian", "healthy-fats"],
                "macros": {"protein": 10, "carbs": 30, "fat": 22},
                "image_url": "https://images.unsplash.com/photo-1588137372308-15f75323ca8d"
            },
            {
                "id": "b3",
                "name": "Oatmeal with Berries",
                "type": "breakfast",
                "calories": 250,
                "prep_time": "10 min",
                "description": "Steel-cut oats with fresh berries",
                "tags": ["high-fiber", "heart-healthy"],
                "macros": {"protein": 8, "carbs": 45, "fat": 5},
                "image_url": "https://images.unsplash.com/photo-1517673400267-0251440c45dc"
            },
            # Lunch
            {
                "id": "l1",
                "name": "Grilled Chicken Salad",
                "type": "lunch",
                "calories": 400,
                "prep_time": "15 min",
                "description": "Mixed greens with grilled chicken",
                "tags": ["high-protein", "low-carb"],
                "macros": {"protein": 35, "carbs": 15, "fat": 20},
                "image_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"
            },
            {
                "id": "l2",
                "name": "Quinoa Buddha Bowl",
                "type": "lunch",
                "calories": 450,
                "prep_time": "20 min",
                "description": "Quinoa with roasted vegetables",
                "tags": ["vegetarian", "high-fiber"],
                "macros": {"protein": 15, "carbs": 55, "fat": 18},
                "image_url": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd"
            },
            {
                "id": "l3",
                "name": "Turkey Wrap",
                "type": "lunch",
                "calories": 380,
                "prep_time": "10 min",
                "description": "Whole wheat wrap with turkey and veggies",
                "tags": ["quick", "high-protein"],
                "macros": {"protein": 28, "carbs": 30, "fat": 15},
                "image_url": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f"
            },
            # Dinner
            {
                "id": "d1",
                "name": "Baked Salmon",
                "type": "dinner",
                "calories": 450,
                "prep_time": "25 min",
                "description": "Baked salmon with asparagus",
                "tags": ["high-protein", "omega-3"],
                "macros": {"protein": 40, "carbs": 10, "fat": 25},
                "image_url": "https://images.unsplash.com/photo-1467003909585-2f8a72700288"
            },
            {
                "id": "d2",
                "name": "Grilled Chicken Breast",
                "type": "dinner",
                "calories": 350,
                "prep_time": "20 min",
                "description": "Grilled chicken with steamed broccoli",
                "tags": ["high-protein", "low-carb"],
                "macros": {"protein": 45, "carbs": 8, "fat": 12},
                "image_url": "https://images.unsplash.com/photo-1598515214211-89d3c73ae83b"
            },
            {
                "id": "d3",
                "name": "Vegetable Stir Fry",
                "type": "dinner",
                "calories": 300,
                "prep_time": "15 min",
                "description": "Mixed vegetables with tofu",
                "tags": ["vegetarian", "low-calorie"],
                "macros": {"protein": 18, "carbs": 25, "fat": 15},
                "image_url": "https://images.unsplash.com/photo-1512058564366-18510be2db19"
            },
            # Snacks
            {
                "id": "s1",
                "name": "Apple with Peanut Butter",
                "type": "snack",
                "calories": 200,
                "prep_time": "2 min",
                "description": "Sliced apple with natural peanut butter",
                "tags": ["quick", "healthy-fats"],
                "macros": {"protein": 6, "carbs": 25, "fat": 10},
                "image_url": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6"
            },
            {
                "id": "s2",
                "name": "Greek Yogurt",
                "type": "snack",
                "calories": 150,
                "prep_time": "1 min",
                "description": "Plain Greek yogurt",
                "tags": ["high-protein", "quick"],
                "macros": {"protein": 15, "carbs": 8, "fat": 5},
                "image_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777"
            },
            {
                "id": "s3",
                "name": "Mixed Nuts",
                "type": "snack",
                "calories": 180,
                "prep_time": "1 min",
                "description": "Handful of mixed nuts",
                "tags": ["healthy-fats", "quick"],
                "macros": {"protein": 6, "carbs": 8, "fat": 15},
                "image_url": "https://images.unsplash.com/photo-1536816579748-4ecb3f03d72a"
            }
        ]

    def _get_recipe_database(self) -> List[Dict[str, Any]]:
        """Get recipe database"""
        return [
            {
                "id": "r1",
                "name": "Simple Stir Fry",
                "calories": 300,
                "description": "Quick vegetable stir fry",
                "ingredients": ["vegetables", "soy sauce", "garlic", "ginger"],
                "prep_time": "15 min",
                "instructions": [
                    "Chop vegetables",
                    "Heat oil in pan",
                    "Add garlic and ginger",
                    "Stir fry vegetables",
                    "Add soy sauce"
                ]
            },
            {
                "id": "r2",
                "name": "Chicken Salad",
                "calories": 350,
                "description": "Fresh chicken salad",
                "ingredients": ["chicken", "lettuce", "tomato", "cucumber", "dressing"],
                "prep_time": "15 min",
                "instructions": [
                    "Grill chicken",
                    "Chop vegetables",
                    "Mix together",
                    "Add dressing"
                ]
            },
            {
                "id": "r3",
                "name": "Smoothie Bowl",
                "calories": 280,
                "description": "Healthy smoothie bowl",
                "ingredients": ["banana", "berries", "yogurt", "granola"],
                "prep_time": "10 min",
                "instructions": [
                    "Blend fruits and yogurt",
                    "Pour into bowl",
                    "Top with granola"
                ]
            }
        ]
