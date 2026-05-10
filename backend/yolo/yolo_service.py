"""
YOLO Food Detection Service
FastAPI service for food detection using YOLO models
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
import os
import logging
from PIL import Image
import io
import numpy as np

# Try to import ultralytics
try:
    from ultralytics import YOLO
    ULTRALYTICS_AVAILABLE = True
except ImportError:
    ULTRALYTICS_AVAILABLE = False
    logging.warning("Ultralytics not available, using mock mode")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="YOLO Food Detection Service", version="1.0.0")

# Global model instance
model = None
model_loaded = False

# Food classes mapping (will be loaded from model)
FOOD_CLASSES = {
    0: "apple", 1: "banana", 2: "orange", 3: "pizza", 4: "burger",
    5: "fries", 6: "salad", 7: "sandwich", 8: "steak", 9: "chicken",
    10: "fish", 11: "rice", 12: "pasta", 13: "bread", 14: "egg",
    15: "milk", 16: "cheese", 17: "yogurt", 18: "soup", 19: "vegetable",
    20: "fruit", 21: "cake", 22: "cookie", 23: "ice_cream", 24: "coffee",
    25: "tea", 26: "juice", 27: "soda", 28: "water", 29: "beer",
    30: "wine", 31: "chocolate", 32: "candy", 33: "chips", 34: "nuts",
    35: "avocado", 36: "tomato", 37: "onion", 38: "garlic", 39: "pepper",
    40: "carrot", 41: "broccoli", 42: "spinach", 43: "lettuce", 44: "cucumber",
    45: "potato", 46: "sweet_potato", 47: "corn", 48: "peas", 49: "beans",
    50: "tofu", 51: "shrimp", 52: "pork", 53: "beef", 54: "lamb",
    55: "duck", 56: "turkey", 57: "bacon", 58: "sausage", 59: "hot_dog",
    60: "taco", 61: "burrito", 62: "sushi", 63: "ramen", 64: "noodles",
    65: "dumpling", 66: "pancake", 67: "waffle", 68: "toast", 69: "bagel",
    70: "croissant", 71: "donut", 72: "muffin", 73: "pie", 74: "cheesecake",
    75: "pudding", 76: "jelly", 77: "jam", 78: "honey", 79: "syrup",
    80: "butter", 79: "oil", 80: "salt", 81: "pepper", 82: "sugar"
}


class DetectionResult(BaseModel):
    """Food detection result"""
    class_name: str
    confidence: float
    bbox: List[int]  # [x1, y1, x2, y2]


class FoodDetectionResponse(BaseModel):
    """Complete food detection response"""
    detections: List[DetectionResult]
    total_items: int
    processing_time: float
    model_name: str


def load_model():
    """Load the YOLO model"""
    global model, model_loaded

    if model_loaded:
        return True

    if not ULTRALYTICS_AVAILABLE:
        logger.warning("Ultralytics not available, running in mock mode")
        model_loaded = True
        return False

    try:
        # Try to load custom food detection model
        model_path = os.getenv("YOLO_MODEL_PATH", "/app/models/food_detection.pt")

        if os.path.exists(model_path):
            logger.info(f"Loading custom model from {model_path}")
            model = YOLO(model_path)
        else:
            logger.warning(f"Custom model not found at {model_path}, using YOLOv8n")
            # Use a pre-trained YOLOv8 model as fallback
            model = YOLO("yolov8n.pt")

        model_loaded = True
        logger.info("YOLO model loaded successfully")
        return True

    except Exception as e:
        logger.error(f"Failed to load YOLO model: {e}")
        model_loaded = True
        return False


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "model_loaded": model_loaded,
        "ultralytics_available": ULTRALYTICS_AVAILABLE
    }


@app.get("/status")
async def get_status():
    """Get service status"""
    return {
        "service": "YOLO Food Detection",
        "model_loaded": model_loaded,
        "ultralytics_available": ULTRALYTICS_AVAILABLE,
        "model_path": os.getenv("YOLO_MODEL_PATH", "/app/models/food_detection.pt"),
        "food_classes_count": len(FOOD_CLASSES)
    }


@app.post("/detect", response_model=FoodDetectionResponse)
async def detect_food(file: UploadFile = File(...)):
    """
    Detect food items in an image

    Args:
        file: Image file to analyze

    Returns:
        FoodDetectionResponse with detected food items
    """
    import time
    start_time = time.time()

    # Ensure model is loaded
    if not model_loaded:
        load_model()

    try:
        # Read image
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))

        # Convert to numpy array
        image_array = np.array(image)

        detections = []

        if ULTRALYTICS_AVAILABLE and model:
            # Run YOLO inference
            results = model(image_array, conf=float(os.getenv("YOLO_CONFIDENCE", "0.25")))

            # Process results
            for result in results:
                boxes = result.boxes
                for box in boxes:
                    # Get class and confidence
                    class_id = int(box.cls[0])
                    confidence = float(box.conf[0])

                    # Get bounding box
                    bbox = box.xyxy[0].tolist()  # [x1, y1, x2, y2]

                    # Map class ID to food name
                    class_name = FOOD_CLASSES.get(class_id, f"food_{class_id}")

                    detections.append(DetectionResult(
                        class_name=class_name,
                        confidence=confidence,
                        bbox=[int(x) for x in bbox]
                    ))
        else:
            # Mock detection for testing
            logger.warning("Running in mock mode - returning random detections")
            import random
            mock_foods = ["pizza", "salad", "burger", "chicken", "rice"]
            for i in range(random.randint(1, 3)):
                detections.append(DetectionResult(
                    class_name=random.choice(mock_foods),
                    confidence=random.uniform(0.7, 0.95),
                    bbox=[0, 0, 100, 100]
                ))

        processing_time = time.time() - start_time

        return FoodDetectionResponse(
            detections=detections,
            total_items=len(detections),
            processing_time=processing_time,
            model_name="YOLOv8 Food Detection"
        )

    except Exception as e:
        logger.error(f"Detection failed: {e}")
        raise HTTPException(status_code=500, detail=f"Detection failed: {str(e)}")


@app.post("/detect/base64")
async def detect_food_base64(data: dict):
    """
    Detect food items from base64 encoded image

    Args:
        data: Dictionary with 'image' key containing base64 string

    Returns:
        FoodDetectionResponse with detected food items
    """
    import base64
    import time
    start_time = time.time()

    try:
        # Decode base64 image
        image_data = base64.b64decode(data.get("image", ""))
        image = Image.open(io.BytesIO(image_data))
        image_array = np.array(image)

        # Ensure model is loaded
        if not model_loaded:
            load_model()

        detections = []

        if ULTRALYTICS_AVAILABLE and model:
            # Run YOLO inference
            results = model(image_array, conf=float(os.getenv("YOLO_CONFIDENCE", "0.25")))

            # Process results
            for result in results:
                boxes = result.boxes
                for box in boxes:
                    class_id = int(box.cls[0])
                    confidence = float(box.conf[0])
                    bbox = box.xyxy[0].tolist()
                    class_name = FOOD_CLASSES.get(class_id, f"food_{class_id}")

                    detections.append(DetectionResult(
                        class_name=class_name,
                        confidence=confidence,
                        bbox=[int(x) for x in bbox]
                    ))
        else:
            # Mock detection
            import random
            mock_foods = ["pizza", "salad", "burger", "chicken", "rice"]
            for i in range(random.randint(1, 3)):
                detections.append(DetectionResult(
                    class_name=random.choice(mock_foods),
                    confidence=random.uniform(0.7, 0.95),
                    bbox=[0, 0, 100, 100]
                ))

        processing_time = time.time() - start_time

        return FoodDetectionResponse(
            detections=detections,
            total_items=len(detections),
            processing_time=processing_time,
            model_name="YOLOv8 Food Detection"
        )

    except Exception as e:
        logger.error(f"Detection failed: {e}")
        raise HTTPException(status_code=500, detail=f"Detection failed: {str(e)}")


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "YOLO Food Detection Service",
        "version": "1.0.0",
        "endpoints": {
            "health": "/health",
            "status": "/status",
            "detect": "/detect (POST - file upload)",
            "detect_base64": "/detect/base64 (POST - base64)"
        }
    }


if __name__ == "__main__":
    # Load model on startup
    load_model()

    # Run the server
    uvicorn.run(app, host="0.0.0.0", port=8001)
