"""
Gemma 4:26B Nutrition Service
FastAPI service for nutrition suggestions using Gemma 4:26B
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import uvicorn
import os
import logging
import aiohttp
import json

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Gemma 4 Nutrition Service", version="1.0.0")

# Gemma 4 configuration
GEMMA_HOST = os.getenv("GEMMA_HOST", "localhost")
GEMMA_PORT = int(os.getenv("GEMMA_PORT", "12434"))
GEMMA_MODEL = os.getenv("GEMMA_MODEL", "docker.io/ai/gemma4:26B")
GEMMA_API_URL = f"http://{GEMMA_HOST}:{GEMMA_PORT}/api/generate"


class NutritionRequest(BaseModel):
    """Request for nutrition information"""
    food_items: List[str]
    portion_sizes: Optional[List[str]] = None


class NutritionSuggestion(BaseModel):
    """Nutrition suggestion for a food item"""
    food_name: str
    calories: int
    protein: float
    carbs: float
    fat: float
    fiber: float
    sugar: float
    portion: str


class NutritionResponse(BaseModel):
    """Complete nutrition response"""
    suggestions: List[NutritionSuggestion]
    total_calories: int
    total_protein: float
    total_carbs: float
    total_fat: float
    health_tips: List[str]
    processing_time: float


async def query_gemma(prompt: str) -> str:
    """Query Gemma 4:26B model"""
    try:
        async with aiohttp.ClientSession() as session:
            payload = {
                "model": GEMMA_MODEL,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": 0.3,
                    "num_predict": 800
                }
            }

            async with session.post(GEMMA_API_URL, json=payload) as response:
                if response.status != 200:
                    error_text = await response.text()
                    raise Exception(f"Gemma API error: {response.status} - {error_text}")

                data = await response.json()
                return data.get("response", "")

    except Exception as e:
        logger.error(f"Gemma query failed: {e}")
        raise


def parse_nutrition_from_response(response: str, food_name: str) -> Dict[str, Any]:
    """Parse nutrition information from Gemma response"""
    nutrition = {
        "calories": 0,
        "protein": 0,
        "carbs": 0,
        "fat": 0,
        "fiber": 0,
        "sugar": 0
    }

    # Try to extract numbers from response
    import re

    # Look for calorie information
    calorie_match = re.search(r'calorie[s]?\s*[:=]?\s*(\d+)', response, re.IGNORECASE)
    if calorie_match:
        nutrition["calories"] = int(calorie_match.group(1))

    # Look for protein
    protein_match = re.search(r'protein\s*[:=]?\s*([\d.]+)\s*g', response, re.IGNORECASE)
    if protein_match:
        nutrition["protein"] = float(protein_match.group(1))

    # Look for carbs
    carbs_match = re.search(r'carb[s]?\s*[:=]?\s*([\d.]+)\s*g', response, re.IGNORECASE)
    if carbs_match:
        nutrition["carbs"] = float(carbs_match.group(1))

    # Look for fat
    fat_match = re.search(r'fat\s*[:=]?\s*([\d.]+)\s*g', response, re.IGNORECASE)
    if fat_match:
        nutrition["fat"] = float(fat_match.group(1))

    # Look for fiber
    fiber_match = re.search(r'fiber\s*[:=]?\s*([\d.]+)\s*g', response, re.IGNORECASE)
    if fiber_match:
        nutrition["fiber"] = float(fiber_match.group(1))

    # Look for sugar
    sugar_match = re.search(r'sugar\s*[:=]?\s*([\d.]+)\s*g', response, re.IGNORECASE)
    if sugar_match:
        nutrition["sugar"] = float(sugar_match.group(1))

    # If no calories found, estimate based on food type
    if nutrition["calories"] == 0:
        food_lower = food_name.lower()
        if any(x in food_lower for x in ["salad", "vegetable"]):
            nutrition["calories"] = 50
        elif any(x in food_lower for x in ["fruit"]):
            nutrition["calories"] = 80
        elif any(x in food_lower for x in ["chicken", "fish", "meat"]):
            nutrition["calories"] = 200
        elif any(x in food_lower for x in ["rice", "pasta", "bread"]):
            nutrition["calories"] = 150
        elif any(x in food_lower for x in ["pizza", "burger"]):
            nutrition["calories"] = 300
        else:
            nutrition["calories"] = 150

    return nutrition


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"http://{GEMMA_HOST}:{GEMMA_PORT}/api/tags") as response:
                if response.status == 200:
                    return {"status": "healthy", "gemma_available": True}
    except:
        pass

    return {"status": "unhealthy", "gemma_available": False}


@app.get("/status")
async def get_status():
    """Get service status"""
    return {
        "service": "Gemma 4 Nutrition Service",
        "gemma_host": GEMMA_HOST,
        "gemma_port": GEMMA_PORT,
        "gemma_model": GEMMA_MODEL,
        "gemma_api_url": GEMMA_API_URL
    }


@app.post("/nutrition", response_model=NutritionResponse)
async def get_nutrition(request: NutritionRequest):
    """
    Get nutrition information for food items

    Args:
        request: NutritionRequest with food items

    Returns:
        NutritionResponse with nutrition data and health tips
    """
    import time
    start_time = time.time()

    suggestions = []
    total_calories = 0
    total_protein = 0.0
    total_carbs = 0.0
    total_fat = 0.0

    # Get nutrition for each food item
    for i, food_item in enumerate(request.food_items):
        portion = request.portion_sizes[i] if request.portion_sizes and i < len(request.portion_sizes) else "1 serving"

        # Create prompt for Gemma
        prompt = f"""Provide detailed nutritional information for {food_item} ({portion}).

Return ONLY a valid JSON response with this exact format:
{{
  "calories": <number>,
  "protein": <number in grams>,
  "carbs": <number in grams>,
  "fat": <number in grams>,
  "fiber": <number in grams>,
  "sugar": <number in grams>
}}

Return ONLY the JSON, no other text."""

        try:
            response = await query_gemma(prompt)
            nutrition = parse_nutrition_from_response(response, food_item)

            suggestions.append(NutritionSuggestion(
                food_name=food_item,
                calories=nutrition["calories"],
                protein=nutrition["protein"],
                carbs=nutrition["carbs"],
                fat=nutrition["fat"],
                fiber=nutrition["fiber"],
                sugar=nutrition["sugar"],
                portion=portion
            ))

            total_calories += nutrition["calories"]
            total_protein += nutrition["protein"]
            total_carbs += nutrition["carbs"]
            total_fat += nutrition["fat"]

        except Exception as e:
            logger.error(f"Failed to get nutrition for {food_item}: {e}")
            # Add fallback suggestion
            suggestions.append(NutritionSuggestion(
                food_name=food_item,
                calories=150,
                protein=5,
                carbs=20,
                fat=5,
                fiber=2,
                sugar=5,
                portion=portion
            ))
            total_calories += 150
            total_protein += 5
            total_carbs += 20
            total_fat += 5

    # Get health tips from Gemma
    health_tips = []
    try:
        food_list = ", ".join(request.food_items)
        tips_prompt = f"""Based on these foods: {food_list}, provide 3 brief health tips (max 10 words each).

Return ONLY a valid JSON array:
["tip 1", "tip 2", "tip 3"]

Return ONLY the JSON, no other text."""

        tips_response = await query_gemma(tips_prompt)

        # Try to parse JSON array
        import re
        json_match = re.search(r'\[.*?\]', tips_response, re.DOTALL)
        if json_match:
            try:
                health_tips = json.loads(json_match.group(0))
                # Ensure we have exactly 3 tips
                health_tips = health_tips[:3]
            except:
                pass

        # Fallback tips if parsing failed
        if not health_tips:
            health_tips = [
                "Eat a variety of foods",
                "Stay hydrated",
                "Watch portion sizes"
            ]

    except Exception as e:
        logger.error(f"Failed to get health tips: {e}")
        health_tips = [
            "Eat a variety of foods",
            "Stay hydrated",
            "Watch portion sizes"
        ]

    processing_time = time.time() - start_time

    return NutritionResponse(
        suggestions=suggestions,
        total_calories=total_calories,
        total_protein=total_protein,
        total_carbs=total_carbs,
        total_fat=total_fat,
        health_tips=health_tips,
        processing_time=processing_time
    )


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "Gemma 4 Nutrition Service",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "status": "/status",
            "nutrition": "/nutrition (POST)"
        }
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8002)
