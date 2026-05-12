"""
FastAPI endpoint for food analysis with authentication
"""

from fastapi import FastAPI, UploadFile, File, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import io
from PIL import Image

from app.services.ai_service import get_ai_service, AnalysisResult, FoodItem, NutritionData
from app.auth import get_current_user, get_optional_user
from app.api import auth as auth_router
from app.api import history as history_router
from app.api import suggestions as suggestions_router
from app.api import profile as profile_router
from app.database import Database

app = FastAPI(
    title="Food Calorie Analyzer API",
    version="1.0.0",
    description="Food calorie analysis with local AI processing"
)


@app.on_event("startup")
async def startup_event():
    """Connect to databases on startup"""
    await Database.connect()


@app.on_event("shutdown")
async def shutdown_event():
    """Disconnect from databases on shutdown"""
    await Database.disconnect()

# Include routers
app.include_router(auth_router.router)
app.include_router(history_router.router)
app.include_router(suggestions_router.router)
app.include_router(profile_router.router)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Response models
class FoodItemResponse(BaseModel):
    name: str
    confidence: float
    portion: str
    estimated_grams: int


class NutritionResponse(BaseModel):
    calories: int
    protein: float
    carbs: float
    fat: float
    fiber: float
    sugar: float


class AnalysisResponse(BaseModel):
    items: List[FoodItemResponse]
    nutrition: NutritionResponse
    source: str
    processing_time: float
    confidence: float


class ServiceStatusResponse(BaseModel):
    yolo: bool
    yolo_host: str
    gemma: bool
    gemma_host: str
    gemma_model: str
    usda: bool
    offline_mode: bool
    confidence_threshold: float


class HealthResponse(BaseModel):
    status: str
    version: str
    services: dict


@app.get("/", response_model=dict)
async def root():
    """Root endpoint"""
    return {
        "message": "Food Calorie Analyzer API",
        "version": "1.0.0",
        "endpoints": {
            "public": {
                "health": "/health",
                "status": "/api/status",
                "docs": "/docs"
            },
            "auth": {
                "register": "/api/auth/register",
                "login": "/api/auth/login",
                "logout": "/api/auth/logout",
                "me": "/api/auth/me"
            },
            "protected": {
                "analyze": "/api/analyze",
                "analyze_base64": "/api/analyze/base64",
                "history": "/api/history",
                "suggestions": "/api/suggestions",
                "profile": "/api/profile"
            }
        }
    }


@app.get("/health", response_model=HealthResponse)
async def health():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        services={
            "mongodb_users": "connected",
            "mongodb_records": "connected",
            "ollama": "running",
            "backend": "running"
        }
    )


@app.get("/api/status", response_model=ServiceStatusResponse)
async def get_status(ai_service=Depends(get_ai_service)):
    """Get status of all AI services (public endpoint)"""
    status = await ai_service.get_service_status()
    return ServiceStatusResponse(**status)


@app.post("/api/analyze", response_model=AnalysisResponse)
async def analyze_food(
    image: UploadFile = File(..., description="Food image file"),
    current_user: dict = Depends(get_current_user),
    ai_service=Depends(get_ai_service)
):
    """
    Analyze food image and return calorie/nutrition information
    (Protected endpoint - requires authentication)

    - **image**: Food image file (JPEG, PNG, etc.)
    - **returns**: Analysis result with food items, calories, and macros
    """
    try:
        # Validate image
        if not image.content_type or not image.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image")

        # Read and validate image
        image_data = await image.read()

        try:
            img = Image.open(io.BytesIO(image_data))
            img.verify()  # Verify it's a valid image
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid image: {str(e)}")

        # Re-open for processing (verify closes the file)
        img = Image.open(io.BytesIO(image_data))

        # Convert to RGB if necessary
        if img.mode != "RGB":
            img = img.convert("RGB")

        # Get bytes in RGB format
        img_bytes = io.BytesIO()
        img.save(img_bytes, format="JPEG")
        image_data = img_bytes.getvalue()

        # Analyze image
        result: AnalysisResult = await ai_service.analyze_food_image(image_data)

        # Convert to response model
        return AnalysisResponse(
            items=[
                FoodItemResponse(
                    name=item.name,
                    confidence=item.confidence,
                    portion=item.portion,
                    estimated_grams=item.estimated_grams
                )
                for item in result.items
            ],
            nutrition=NutritionResponse(
                calories=result.nutrition.calories,
                protein=round(result.nutrition.protein, 1),
                carbs=round(result.nutrition.carbs, 1),
                fat=round(result.nutrition.fat, 1),
                fiber=round(result.nutrition.fiber, 1),
                sugar=round(result.nutrition.sugar, 1)
            ),
            source=result.source.value,
            processing_time=round(result.processing_time, 2),
            confidence=round(result.confidence, 2)
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")


@app.post("/api/analyze/base64", response_model=AnalysisResponse)
async def analyze_food_base64(
    data: dict,
    current_user: dict = Depends(get_current_user),
    ai_service=Depends(get_ai_service)
):
    """
    Analyze food image from base64 string
    (Protected endpoint - requires authentication)

    - **data**: JSON with 'image' field containing base64 encoded image
    - **returns**: Analysis result with food items, calories, and macros
    """
    try:
        import base64

        if "image" not in data:
            raise HTTPException(status_code=400, detail="Missing 'image' field")

        # Decode base64
        image_data = base64.b64decode(data["image"])

        # Validate image
        try:
            img = Image.open(io.BytesIO(image_data))
            img.verify()
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Invalid image: {str(e)}")

        # Re-open and convert
        img = Image.open(io.BytesIO(image_data))
        if img.mode != "RGB":
            img = img.convert("RGB")

        img_bytes = io.BytesIO()
        img.save(img_bytes, format="JPEG")
        image_data = img_bytes.getvalue()

        # Analyze
        result: AnalysisResult = await ai_service.analyze_food_image(image_data)

        return AnalysisResponse(
            items=[
                FoodItemResponse(
                    name=item.name,
                    confidence=item.confidence,
                    portion=item.portion,
                    estimated_grams=item.estimated_grams
                )
                for item in result.items
            ],
            nutrition=NutritionResponse(
                calories=result.nutrition.calories,
                protein=round(result.nutrition.protein, 1),
                carbs=round(result.nutrition.carbs, 1),
                fat=round(result.nutrition.fat, 1),
                fiber=round(result.nutrition.fiber, 1),
                sugar=round(result.nutrition.sugar, 1)
            ),
            source=result.source.value,
            processing_time=round(result.processing_time, 2),
            confidence=round(result.confidence, 2)
        )

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
