"""
Hybrid AI Service for Food Analysis
New Architecture:
- Primary: YOLO (Docker) - Food detection from images
- Secondary: Gemma 4:26B (Docker) - Nutrition suggestions
- Tertiary: USDA API - Nutrition database
- Fallback: Conservative estimation
"""

import os
import base64
import json
import asyncio
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum
import aiohttp
from pydantic import BaseModel, Field
import logging
from datetime import datetime, timedelta

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ProcessingSource(Enum):
    """Source of AI processing"""
    YOLO = "yolo"
    GEMMA = "gemma"
    USDA = "usda"
    FALLBACK = "fallback"
    CACHED = "cached"


@dataclass
class FoodItem:
    """Detected food item"""
    name: str
    confidence: float
    portion: str = "1 serving"
    estimated_grams: int = 100


@dataclass
class NutritionData:
    """Nutritional information"""
    calories: int
    protein: float
    carbs: float
    fat: float
    fiber: float = 0
    sugar: float = 0


@dataclass
class AnalysisResult:
    """Complete analysis result"""
    items: List[FoodItem]
    nutrition: NutritionData
    source: ProcessingSource
    processing_time: float
    confidence: float
    health_tips: List[str] = None


class YOLOClient:
    """Client for YOLO food detection service"""

    def __init__(self, host: str = "localhost", port: int = 8001):
        self.base_url = f"http://{host}:{port}"
        self.timeout = int(os.getenv("YOLO_TIMEOUT", "30"))
        self._available = None

    async def is_available(self) -> bool:
        """Check if YOLO service is running"""
        if self._available is not None:
            return self._available

        try:
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=5)) as session:
                async with session.get(f"{self.base_url}/health") as response:
                    self._available = response.status == 200
                    return self._available
        except Exception as e:
            logger.warning(f"YOLO service not available: {e}")
            self._available = False
            return False

    async def detect_food(self, image_data: bytes) -> List[FoodItem]:
        """Detect food items in image using YOLO"""
        try:
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=self.timeout)) as session:
                # Prepare multipart form data
                data = aiohttp.FormData()
                data.add_field("file", image_data, filename="image.jpg", content_type="image/jpeg")

                async with session.post(f"{self.base_url}/detect", data=data) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        raise Exception(f"YOLO error: {response.status} - {error_text}")

                    result = await response.json()

                    # Parse detections
                    items = []
                    for detection in result.get("detections", []):
                        items.append(FoodItem(
                            name=detection["class_name"],
                            confidence=detection["confidence"],
                            portion="1 serving",
                            estimated_grams=100  # Default portion size
                        ))

                    logger.info(f"YOLO detected {len(items)} food items")
                    return items

        except Exception as e:
            logger.error(f"YOLO detection failed: {e}")
            raise


class GemmaClient:
    """Client for Gemma 4:26B nutrition service"""

    def __init__(self, host: str = "localhost", port: int = 12434):
        self.base_url = f"http://{host}:{port}"
        self.model = os.getenv("GEMMA_MODEL", "docker.io/ai/gemma4:26B")
        self.timeout = int(os.getenv("GEMMA_TIMEOUT", "60"))
        self._available = None

    async def is_available(self) -> bool:
        """Check if Gemma service is running"""
        if self._available is not None:
            return self._available

        try:
            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=5)) as session:
                async with session.get(f"{self.base_url}/api/tags") as response:
                    self._available = response.status == 200
                    return self._available
        except Exception as e:
            logger.warning(f"Gemma service not available: {e}")
            self._available = False
            return False

    async def get_nutrition(self, food_items: List[FoodItem]) -> Dict[str, Any]:
        """Get nutrition information from Gemma"""
        try:
            # Prepare request
            food_names = [item.name for item in food_items]
            portions = [item.portion for item in food_items]

            payload = {
                "food_items": food_names,
                "portion_sizes": portions
            }

            async with aiohttp.ClientSession(timeout=aiohttp.ClientTimeout(total=self.timeout)) as session:
                async with session.post(
                    f"{self.base_url}/nutrition",
                    json=payload
                ) as response:
                    if response.status != 200:
                        error_text = await response.text()
                        raise Exception(f"Gemma error: {response.status} - {error_text}")

                    result = await response.json()
                    return result

        except Exception as e:
            logger.error(f"Gemma nutrition query failed: {e}")
            raise


class USDANutritionClient:
    """Client for USDA FoodData Central API with local caching"""

    def __init__(self, api_key: str, offline_mode: bool = False):
        self.api_key = api_key
        self.base_url = "https://api.nal.usda.gov/fdc/v1"
        self.cache = {}
        self.offline_mode = offline_mode
        self.cache_duration = int(os.getenv("NUTRITION_CACHE_DURATION", "3600"))

        # Load offline nutrition database
        self.offline_db = self._load_offline_database()

    def _load_offline_database(self) -> Dict[str, Dict[str, float]]:
        """Load offline nutrition database for common foods"""
        return {
            "chicken": {"calories": 165, "protein": 31, "carbs": 0, "fat": 3.6, "fiber": 0, "sugar": 0},
            "beef": {"calories": 250, "protein": 26, "carbs": 0, "fat": 15, "fiber": 0, "sugar": 0},
            "fish": {"calories": 140, "protein": 20, "carbs": 0, "fat": 6, "fiber": 0, "sugar": 0},
            "salmon": {"calories": 208, "protein": 20, "carbs": 0, "fat": 13, "fiber": 0, "sugar": 0},
            "rice": {"calories": 130, "protein": 2.7, "carbs": 28, "fat": 0.3, "fiber": 0.4, "sugar": 0.1},
            "pasta": {"calories": 131, "protein": 5, "carbs": 25, "fat": 1.1, "fiber": 1.3, "sugar": 0.6},
            "bread": {"calories": 265, "protein": 9, "carbs": 49, "fat": 3.2, "fiber": 2.7, "sugar": 5},
            "salad": {"calories": 33, "protein": 2, "carbs": 7, "fat": 0.2, "fiber": 2, "sugar": 3.5},
            "vegetable": {"calories": 25, "protein": 1, "carbs": 5, "fat": 0.1, "fiber": 2, "sugar": 2},
            "fruit": {"calories": 52, "protein": 0.5, "carbs": 14, "fat": 0.2, "fiber": 2, "sugar": 10},
            "apple": {"calories": 52, "protein": 0.3, "carbs": 14, "fat": 0.2, "fiber": 2.4, "sugar": 10},
            "banana": {"calories": 89, "protein": 1.1, "carbs": 23, "fat": 0.3, "fiber": 2.6, "sugar": 12},
            "egg": {"calories": 155, "protein": 13, "carbs": 1.1, "fat": 11, "fiber": 0, "sugar": 1.1},
            "milk": {"calories": 42, "protein": 3.4, "carbs": 5, "fat": 1, "fiber": 0, "sugar": 5},
            "cheese": {"calories": 402, "protein": 25, "carbs": 1.3, "fat": 33, "fiber": 0, "sugar": 0.5},
            "yogurt": {"calories": 59, "protein": 10, "carbs": 3.6, "fat": 0.4, "fiber": 0, "sugar": 3.2},
            "pizza": {"calories": 266, "protein": 11, "carbs": 33, "fat": 10, "fiber": 1.8, "sugar": 4},
            "burger": {"calories": 295, "protein": 17, "carbs": 30, "fat": 12, "fiber": 1.5, "sugar": 6},
            "fries": {"calories": 312, "protein": 3.4, "carbs": 41, "fat": 15, "fiber": 3.8, "sugar": 0.4},
            "soup": {"calories": 60, "protein": 2, "carbs": 10, "fat": 2, "fiber": 1, "sugar": 2},
            "sandwich": {"calories": 250, "protein": 9, "carbs": 30, "fat": 10, "fiber": 2, "sugar": 3},
            "steak": {"calories": 271, "protein": 26, "carbs": 0, "fat": 19, "fiber": 0, "sugar": 0},
            "pork": {"calories": 242, "protein": 27, "carbs": 0, "fat": 14, "fiber": 0, "sugar": 0},
            "shrimp": {"calories": 99, "protein": 24, "carbs": 0.2, "fat": 0.3, "fiber": 0, "sugar": 0},
            "tofu": {"calories": 76, "protein": 8, "carbs": 1.9, "fat": 4.8, "fiber": 1, "sugar": 0.6},
            "beans": {"calories": 127, "protein": 8.7, "carbs": 22, "fat": 0.5, "fiber": 6, "sugar": 0.3},
            "lentils": {"calories": 116, "protein": 9, "carbs": 20, "fat": 0.4, "fiber": 7.9, "sugar": 1.8},
            "nuts": {"calories": 607, "protein": 21, "carbs": 22, "fat": 54, "fiber": 7, "sugar": 4},
            "avocado": {"calories": 160, "protein": 2, "carbs": 9, "fat": 15, "fiber": 7, "sugar": 0.7},
            "potato": {"calories": 77, "protein": 2, "carbs": 17, "fat": 0.1, "fiber": 2.2, "sugar": 0.8},
            "sweet potato": {"calories": 86, "protein": 1.6, "carbs": 20, "fat": 0.1, "fiber": 3, "sugar": 4.2},
            "corn": {"calories": 86, "protein": 1.5, "carbs": 19, "fat": 1.4, "fiber": 2.4, "sugar": 6.3},
            "broccoli": {"calories": 34, "protein": 2.8, "carbs": 7, "fat": 0.4, "fiber": 2.6, "sugar": 1.5},
            "carrot": {"calories": 41, "protein": 0.9, "carbs": 10, "fat": 0.2, "fiber": 2.8, "sugar": 4.7},
            "tomato": {"calories": 18, "protein": 0.9, "carbs": 3.9, "fat": 0.2, "fiber": 1.2, "sugar": 2.6},
            "onion": {"calories": 40, "protein": 1.1, "carbs": 9.3, "fat": 0.1, "fiber": 1.7, "sugar": 4.2},
            "garlic": {"calories": 149, "protein": 6.4, "carbs": 33, "fat": 0.5, "fiber": 2.1, "sugar": 1},
            "pepper": {"calories": 31, "protein": 1, "carbs": 6, "fat": 0.3, "fiber": 2.1, "sugar": 4.2},
            "cucumber": {"calories": 16, "protein": 0.7, "carbs": 4, "fat": 0.1, "fiber": 0.5, "sugar": 1.7},
            "lettuce": {"calories": 15, "protein": 1.4, "carbs": 2.9, "fat": 0.2, "fiber": 1.3, "sugar": 0.8},
            "spinach": {"calories": 23, "protein": 2.9, "carbs": 3.6, "fat": 0.4, "fiber": 2.2, "sugar": 0.4},
            "kale": {"calories": 33, "protein": 2.9, "carbs": 6, "fat": 0.6, "fiber": 1.3, "sugar": 1.3},
            "cauliflower": {"calories": 25, "protein": 2, "carbs": 5, "fat": 0.1, "fiber": 2, "sugar": 2},
            "cabbage": {"calories": 25, "protein": 1.3, "carbs": 6, "fat": 0.1, "fiber": 2.5, "sugar": 3.2},
            "mushroom": {"calories": 22, "protein": 3.1, "carbs": 3.3, "fat": 0.3, "fiber": 1, "sugar": 1.7},
            "asparagus": {"calories": 20, "protein": 2.2, "carbs": 4, "fat": 0.1, "fiber": 2.1, "sugar": 1.9},
            "zucchini": {"calories": 17, "protein": 1.2, "carbs": 3.1, "fat": 0.3, "fiber": 1, "sugar": 2.5},
            "eggplant": {"calories": 25, "protein": 1, "carbs": 6, "fat": 0.2, "fiber": 2.5, "sugar": 3.5},
            "peas": {"calories": 81, "protein": 5.4, "carbs": 14, "fat": 0.4, "fiber": 5.7, "sugar": 5.7},
            "green beans": {"calories": 31, "protein": 1.8, "carbs": 7, "fat": 0.1, "fiber": 2.7, "sugar": 3.3},
            "brussels sprouts": {"calories": 43, "protein": 3.4, "carbs": 9, "fat": 0.5, "fiber": 3.8, "sugar": 2.2},
            "celery": {"calories": 16, "protein": 0.8, "carbs": 3, "fat": 0.1, "fiber": 1.6, "sugar": 1.6},
            "orange": {"calories": 47, "protein": 0.9, "carbs": 12, "fat": 0.1, "fiber": 2.4, "sugar": 9},
            "grape": {"calories": 69, "protein": 0.7, "carbs": 18, "fat": 0.2, "fiber": 0.9, "sugar": 16},
            "strawberry": {"calories": 32, "protein": 0.7, "carbs": 7.7, "fat": 0.3, "fiber": 2, "sugar": 4.9},
            "blueberry": {"calories": 57, "protein": 0.7, "carbs": 14, "fat": 0.3, "fiber": 2.4, "sugar": 10},
            "watermelon": {"calories": 30, "protein": 0.6, "carbs": 8, "fat": 0.2, "fiber": 0.4, "sugar": 6},
            "pineapple": {"calories": 50, "protein": 0.5, "carbs": 13, "fat": 0.1, "fiber": 1.4, "sugar": 10},
            "mango": {"calories": 60, "protein": 0.8, "carbs": 15, "fat": 0.4, "fiber": 1.6, "sugar": 14},
            "peach": {"calories": 39, "protein": 0.9, "carbs": 10, "fat": 0.3, "fiber": 1.5, "sugar": 8},
            "pear": {"calories": 57, "protein": 0.4, "carbs": 15, "fat": 0.1, "fiber": 3.1, "sugar": 10},
            "grapefruit": {"calories": 42, "protein": 0.9, "carbs": 11, "fat": 0.1, "fiber": 1.6, "sugar": 7},
            "lemon": {"calories": 29, "protein": 1.1, "carbs": 9, "fat": 0.3, "fiber": 2.8, "sugar": 2.5},
            "lime": {"calories": 30, "protein": 0.7, "carbs": 10, "fat": 0.1, "fiber": 2.8, "sugar": 1.7},
        }

    async def search_food(self, query: str) -> Optional[Dict[str, float]]:
        """Search for food in USDA database or offline cache"""
        # Check cache first
        if query in self.cache:
            cached_data, cached_time = self.cache[query]
            if datetime.now() - cached_time < timedelta(seconds=self.cache_duration):
                logger.info(f"Using cached nutrition data for: {query}")
                return cached_data

        # If offline mode, use offline database
        if self.offline_mode:
            return self._search_offline(query)

        # Try USDA API
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    f"{self.base_url}/foods/search",
                    params={
                        "api_key": self.api_key,
                        "query": query,
                        "pageSize": 1,
                        "dataType": "Foundation,SR Legacy"
                    }
                ) as response:
                    if response.status == 200:
                        data = await response.json()
                        if data.get("foods"):
                            food = data["foods"][0]
                            result = self._extract_nutrition(food)
                            # Cache the result
                            self.cache[query] = (result, datetime.now())
                            return result
        except Exception as e:
            logger.warning(f"USDA search failed for {query}: {e}, using offline database")

        # Fallback to offline database
        return self._search_offline(query)

    def _search_offline(self, query: str) -> Optional[Dict[str, float]]:
        """Search in offline nutrition database"""
        query_lower = query.lower()

        # Direct match
        if query_lower in self.offline_db:
            return self.offline_db[query_lower]

        # Partial match
        for key, value in self.offline_db.items():
            if key in query_lower or query_lower in key:
                return value

        # Category match
        for category in ["vegetable", "fruit", "meat", "fish", "dairy", "grain"]:
            if category in query_lower:
                # Return average for category
                category_foods = [v for k, v in self.offline_db.items() if category in k]
                if category_foods:
                    avg = {
                        "calories": sum(f["calories"] for f in category_foods) / len(category_foods),
                        "protein": sum(f["protein"] for f in category_foods) / len(category_foods),
                        "carbs": sum(f["carbs"] for f in category_foods) / len(category_foods),
                        "fat": sum(f["fat"] for f in category_foods) / len(category_foods),
                        "fiber": sum(f["fiber"] for f in category_foods) / len(category_foods),
                        "sugar": sum(f["sugar"] for f in category_foods) / len(category_foods),
                    }
                    return avg

        # Default fallback
        return {"calories": 150, "protein": 5, "carbs": 20, "fat": 5, "fiber": 1, "sugar": 5}

    def _extract_nutrition(self, food: Dict[str, Any]) -> Dict[str, float]:
        """Extract nutrition data from USDA food entry"""
        nutrients = food.get("foodNutrients", [])
        nutrition = {
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fat": 0,
            "fiber": 0,
            "sugar": 0
        }

        nutrient_map = {
            "Energy": "calories",
            "Protein": "protein",
            "Carbohydrate, by difference": "carbs",
            "Total lipid (fat)": "fat",
            "Fiber, total dietary": "fiber",
            "Sugars, total": "sugar"
        }

        for n in nutrients:
            name = n.get("name", "")
            amount = n.get("amount", 0)
            unit = n.get("unitName", "")

            if name in nutrient_map:
                key = nutrient_map[name]
                # Convert to standard units
                if unit == "kJ" and key == "calories":
                    nutrition[key] = amount / 4.184  # kJ to kcal
                else:
                    nutrition[key] = amount

        return nutrition

    async def get_nutrition_for_items(self, items: List[FoodItem]) -> NutritionData:
        """Get combined nutrition for multiple food items"""
        total = NutritionData(0, 0, 0, 0)

        for item in items:
            nutrition = await self.search_food(item.name)
            if nutrition:
                # Scale by portion size
                scale = item.estimated_grams / 100
                total.calories += int(nutrition["calories"] * scale)
                total.protein += nutrition["protein"] * scale
                total.carbs += nutrition["carbs"] * scale
                total.fat += nutrition["fat"] * scale
                total.fiber += nutrition["fiber"] * scale
                total.sugar += nutrition["sugar"] * scale
            else:
                # Fallback estimation
                total.calories += self._estimate_calories(item.name, item.estimated_grams)

        return total

    def _estimate_calories(self, food_name: str, grams: int) -> int:
        """Fallback calorie estimation"""
        food_lower = food_name.lower()

        if any(x in food_lower for x in ["salad", "vegetable", "fruit"]):
            return int(grams * 0.3)
        elif any(x in food_lower for x in ["chicken", "fish", "meat"]):
            return int(grams * 2.0)
        elif any(x in food_lower for x in ["rice", "pasta", "bread"]):
            return int(grams * 1.5)
        elif any(x in food_lower for x in ["pizza", "burger", "fries"]):
            return int(grams * 2.5)
        else:
            return int(grams * 1.0)


class HybridAIService:
    """Hybrid AI service - YOLO + Gemma + USDA"""

    def __init__(self):
        # Load configuration
        self.offline_mode = os.getenv("OFFLINE_MODE", "false").lower() == "true"
        self.confidence_threshold = float(os.getenv("CONFIDENCE_THRESHOLD", "0.3"))

        # Initialize YOLO client
        self.yolo = YOLOClient(
            host=os.getenv("YOLO_HOST", "localhost"),
            port=int(os.getenv("YOLO_PORT", "8001"))
        )

        # Initialize Gemma client
        self.gemma = GemmaClient(
            host=os.getenv("GEMMA_HOST", "localhost"),
            port=int(os.getenv("GEMMA_PORT", "12434"))
        )

        # Initialize USDA client
        usda_key = os.getenv("USDA_API_KEY")
        self.usda = USDANutritionClient(
            api_key=usda_key if usda_key else "dummy",
            offline_mode=self.offline_mode
        )

        logger.info(f"AI Service initialized - Offline: {self.offline_mode}")

    async def analyze_food_image(self, image_data: bytes) -> AnalysisResult:
        """
        Analyze food image using hybrid approach
        Priority: YOLO (detection) → Gemma (nutrition) → USDA (database) → Fallback
        """
        import time
        start_time = time.time()

        # Step 1: Detect food items using YOLO
        items = []
        detection_source = ProcessingSource.FALLBACK

        if await self.yolo.is_available():
            try:
                items = await self.yolo.detect_food(image_data)
                detection_source = ProcessingSource.YOLO
                logger.info(f"YOLO detected {len(items)} food items")
            except Exception as e:
                logger.warning(f"YOLO detection failed: {e}")
        else:
            logger.warning("YOLO service not available")

        # Fallback if no items detected
        if not items:
            items = [FoodItem(
                name="Unknown food",
                confidence=0.1,
                portion="1 serving",
                estimated_grams=100
            )]
            detection_source = ProcessingSource.FALLBACK

        # Step 2: Get nutrition information
        nutrition = NutritionData(0, 0, 0, 0)
        nutrition_source = ProcessingSource.FALLBACK
        health_tips = []

        # Try Gemma first for nutrition
        if await self.gemma.is_available():
            try:
                gemma_result = await self.gemma.get_nutrition(items)
                nutrition = NutritionData(
                    calories=gemma_result.get("total_calories", 0),
                    protein=gemma_result.get("total_protein", 0),
                    carbs=gemma_result.get("total_carbs", 0),
                    fat=gemma_result.get("total_fat", 0),
                    fiber=0,
                    sugar=0
                )
                nutrition_source = ProcessingSource.GEMMA
                health_tips = gemma_result.get("health_tips", [])
                logger.info(f"Gemma provided nutrition data")
            except Exception as e:
                logger.warning(f"Gemma nutrition failed: {e}")

        # Fallback to USDA if Gemma failed
        if nutrition.calories == 0:
            try:
                nutrition = await self.usda.get_nutrition_for_items(items)
                nutrition_source = ProcessingSource.USDA
                logger.info(f"USDA provided nutrition data")
            except Exception as e:
                logger.warning(f"USDA nutrition failed: {e}")

        # Ultimate fallback
        if nutrition.calories == 0:
            nutrition = NutritionData(
                calories=200,
                protein=10,
                carbs=25,
                fat=8
            )
            nutrition_source = ProcessingSource.FALLBACK

        # Calculate average confidence
        avg_confidence = sum(item.confidence for item in items) / len(items) if items else 0.1

        processing_time = time.time() - start_time

        return AnalysisResult(
            items=items,
            nutrition=nutrition,
            source=detection_source if detection_source != ProcessingSource.FALLBACK else nutrition_source,
            processing_time=processing_time,
            confidence=avg_confidence,
            health_tips=health_tips
        )

    async def get_service_status(self) -> Dict[str, Any]:
        """Get status of all services"""
        yolo_available = await self.yolo.is_available()
        gemma_available = await self.gemma.is_available()

        return {
            "yolo": yolo_available,
            "yolo_host": self.yolo.base_url,
            "gemma": gemma_available,
            "gemma_host": self.gemma.base_url,
            "gemma_model": self.gemma.model,
            "usda": self.usda.api_key != "dummy",
            "offline_mode": self.offline_mode,
            "confidence_threshold": self.confidence_threshold
        }


# Singleton instance
_ai_service: Optional[HybridAIService] = None


def get_ai_service() -> HybridAIService:
    """Get the singleton AI service instance"""
    global _ai_service
    if _ai_service is None:
        _ai_service = HybridAIService()
    return _ai_service
