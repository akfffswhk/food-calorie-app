"""
History API endpoints
"""

from fastapi import APIRouter, HTTPException, Depends, status, Query
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, timedelta
from bson import ObjectId

from app.auth import get_current_user
from app.database import get_analyses_collection, get_daily_summaries_collection

router = APIRouter(prefix="/api/history", tags=["History"])


# Response Models
class FoodItemModel(BaseModel):
    name: str
    confidence: float
    portion: str
    estimated_grams: int


class MacrosModel(BaseModel):
    protein: float
    carbs: float
    fat: float
    fiber: float
    sugar: float


class HistoryEntryResponse(BaseModel):
    id: str
    created_at: datetime
    meal_type: str
    calories: int
    macros: MacrosModel
    items: List[FoodItemModel]
    source: str


class DailySummaryResponse(BaseModel):
    date: str
    total_calories: int
    meals: dict
    macros: MacrosModel
    analyses: List[HistoryEntryResponse]


class StatsResponse(BaseModel):
    daily_goal: int
    streak_days: int
    today: dict
    weekly_average: int
    top_foods: List[dict]


class SaveAnalysisRequest(BaseModel):
    meal_type: str
    calories: int
    macros: MacrosModel
    items: List[FoodItemModel]
    source: str


@router.post("", response_model=HistoryEntryResponse)
async def save_analysis(
    analysis: SaveAnalysisRequest,
    current_user: dict = Depends(get_current_user)
):
    """
    Save a new analysis to history

    - **meal_type**: Type of meal (breakfast, lunch, dinner, snack)
    - **calories**: Total calories
    - **macros**: Nutrition breakdown
    - **items**: List of detected food items
    - **source**: Analysis source (AI service used)
    """
    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    # Create new analysis document
    new_analysis = {
        "user_id": user_id,
        "created_at": datetime.utcnow(),
        "meal_type": analysis.meal_type,
        "calories": analysis.calories,
        "macros": analysis.macros.dict(),
        "items": [item.dict() for item in analysis.items],
        "source": analysis.source
    }

    # Insert into database
    result = await analyses_collection.insert_one(new_analysis)

    # Return the created analysis
    new_analysis["id"] = str(result.inserted_id)
    del new_analysis["_id"]
    del new_analysis["user_id"]

    return HistoryEntryResponse(**new_analysis)


@router.get("", response_model=List[HistoryEntryResponse])
async def get_history(
    limit: int = Query(50, ge=1, le=100),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(get_current_user)
):
    """
    Get user's analysis history

    - **limit**: Maximum number of entries to return (default: 50)
    - **skip**: Number of entries to skip (for pagination)
    """
    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    cursor = analyses_collection.find(
        {"user_id": user_id}
    ).sort("created_at", -1).skip(skip).limit(limit)

    history = []
    async for doc in cursor:
        doc["id"] = str(doc["_id"])
        del doc["_id"]
        del doc["user_id"]
        history.append(HistoryEntryResponse(**doc))

    return history


@router.get("/daily/{date}", response_model=DailySummaryResponse)
async def get_daily_history(
    date: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get history for a specific day

    - **date**: Date in YYYY-MM-DD format
    """
    try:
        target_date = datetime.strptime(date, "%Y-%m-%d")
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="Invalid date format. Use YYYY-MM-DD"
        )

    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    start_of_day = datetime(target_date.year, target_date.month, target_date.day)
    end_of_day = start_of_day + timedelta(days=1)

    cursor = analyses_collection.find({
        "user_id": user_id,
        "created_at": {"$gte": start_of_day, "$lt": end_of_day}
    })

    analyses = []
    total_calories = 0
    meals = {"breakfast": 0, "lunch": 0, "dinner": 0, "snacks": 0}
    total_macros = {"protein": 0, "carbs": 0, "fat": 0, "fiber": 0, "sugar": 0}

    async for doc in cursor:
        doc["id"] = str(doc["_id"])
        del doc["_id"]
        del doc["user_id"]
        analyses.append(HistoryEntryResponse(**doc))

        # Aggregate totals
        calories = doc.get("calories", 0)
        total_calories += calories

        meal_type = doc.get("meal_type", "snack")
        if meal_type in meals:
            meals[meal_type] += calories
        else:
            meals["snacks"] += calories

        # Aggregate macros
        macros = doc.get("macros", {})
        for key in total_macros:
            total_macros[key] += macros.get(key, 0)

    return DailySummaryResponse(
        date=date,
        total_calories=total_calories,
        meals=meals,
        macros=MacrosModel(**total_macros),
        analyses=analyses
    )


@router.get("/weekly")
async def get_weekly_history(
    end_date: Optional[str] = None,
    current_user: dict = Depends(get_current_user)
):
    """
    Get history for the past week

    - **end_date**: End date in YYYY-MM-DD format (default: today)
    """
    if end_date:
        try:
            end_date_dt = datetime.strptime(end_date, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(
                status_code=400,
                detail="Invalid date format. Use YYYY-MM-DD"
            )
    else:
        end_date_dt = datetime.utcnow()

    start_date = end_date_dt - timedelta(days=7)

    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    cursor = analyses_collection.find({
        "user_id": user_id,
        "created_at": {"$gte": start_date, "$lt": end_date_dt}
    }).sort("created_at", 1)

    # Group by day
    daily_data = {}
    async for doc in cursor:
        day_key = doc["created_at"].strftime("%Y-%m-%d")
        if day_key not in daily_data:
            daily_data[day_key] = {
                "date": day_key,
                "calories": 0,
                "count": 0
            }

        daily_data[day_key]["calories"] += doc.get("calories", 0)
        daily_data[day_key]["count"] += 1

    return list(daily_data.values())


@router.get("/monthly")
async def get_monthly_history(
    year: int = Query(..., ge=2020, le=2030),
    month: int = Query(..., ge=1, le=12),
    current_user: dict = Depends(get_current_user)
):
    """
    Get history for a specific month

    - **year**: Year (e.g., 2024)
    - **month**: Month (1-12)
    """
    start_date = datetime(year, month, 1)
    if month == 12:
        end_date = datetime(year + 1, 1, 1)
    else:
        end_date = datetime(year, month + 1, 1)

    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    cursor = analyses_collection.find({
        "user_id": user_id,
        "created_at": {"$gte": start_date, "<lt": end_date}
    }).sort("created_at", 1)

    # Group by day
    daily_data = {}
    async for doc in cursor:
        day_key = doc["created_at"].strftime("%Y-%m-%d")
        if day_key not in daily_data:
            daily_data[day_key] = {
                "date": day_key,
                "calories": 0,
                "count": 0
            }

        daily_data[day_key]["calories"] += doc.get("calories", 0)
        daily_data[day_key]["count"] += 1

    return list(daily_data.values())


@router.get("/stats", response_model=StatsResponse)
async def get_stats(current_user: dict = Depends(get_current_user)):
    """
    Get user statistics

    Returns daily goal, streak, today's progress, weekly average, and top foods
    """
    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    # Get today's summary
    today = datetime.utcnow()
    start_of_day = datetime(today.year, today.month, today.day)
    end_of_day = start_of_day + timedelta(days=1)

    cursor = analyses_collection.find({
        "user_id": user_id,
        "created_at": {"$gte": start_of_day, "$lt": end_of_day}
    })

    today_calories = 0
    async for doc in cursor:
        today_calories += doc.get("calories", 0)

    # Get weekly average
    start_of_week = today - timedelta(days=7)
    cursor = analyses_collection.find({
        "user_id": user_id,
        "created_at": {"$gte": start_of_week, "$lt": today}
    })

    weekly_total = 0
    weekly_count = 0
    async for doc in cursor:
        weekly_total += doc.get("calories", 0)
        weekly_count += 1

    weekly_avg = weekly_total / weekly_count if weekly_count > 0 else 0

    # Get most analyzed foods
    cursor = analyses_collection.aggregate([
        {"$match": {"user_id": user_id}},
        {"$unwind": "$items"},
        {"$group": {
            "_id": "$items.name",
            "count": {"$sum": 1},
            "total_calories": {"$sum": "$calories"}
        }},
        {"$sort": {"count": -1}},
        {"$limit": 5}
    ])

    top_foods = []
    async for doc in cursor:
        top_foods.append({
            "name": doc["_id"],
            "count": doc["count"],
            "total_calories": doc["total_calories"]
        })

    # Calculate streak
    streak = 0
    current_date = today
    daily_goal = 2000  # Default, should come from user profile

    while True:
        start = datetime(current_date.year, current_date.month, current_date.day)
        end = start + timedelta(days=1)

        cursor = analyses_collection.find({
            "user_id": user_id,
            "created_at": {"$gte": start, "$lt": end}
        })

        total = 0
        async for doc in cursor:
            total += doc.get("calories", 0)

        if total > 0 and total <= daily_goal:
            streak += 1
            current_date -= timedelta(days=1)
        else:
            break

    return StatsResponse(
        daily_goal=daily_goal,
        streak_days=streak,
        today={
            "calories": today_calories,
            "goal_met": today_calories <= daily_goal,
            "remaining": max(0, daily_goal - today_calories)
        },
        weekly_average=int(weekly_avg),
        top_foods=top_foods
    )


@router.get("/{analysis_id}", response_model=HistoryEntryResponse)
async def get_analysis(
    analysis_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Get a specific analysis by ID
    """
    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    try:
        doc = await analyses_collection.find_one({
            "_id": ObjectId(analysis_id),
            "user_id": user_id
        })
    except:
        raise HTTPException(
            status_code=400,
            detail="Invalid analysis ID"
        )

    if not doc:
        raise HTTPException(
            status_code=404,
            detail="Analysis not found"
        )

    doc["id"] = str(doc["_id"])
    del doc["_id"]
    del doc["user_id"]

    return HistoryEntryResponse(**doc)


@router.delete("/{analysis_id}")
async def delete_analysis(
    analysis_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Delete an analysis entry
    """
    analyses_collection = get_analyses_collection()
    user_id = ObjectId(current_user["user_id"])

    try:
        result = await analyses_collection.delete_one({
            "_id": ObjectId(analysis_id),
            "user_id": user_id
        })
    except:
        raise HTTPException(
            status_code=400,
            detail="Invalid analysis ID"
        )

    if result.deleted_count == 0:
        raise HTTPException(
            status_code=404,
            detail="Analysis not found"
        )

    return {"message": "Analysis deleted successfully"}
