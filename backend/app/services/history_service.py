"""
History and tracking service
"""

from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from bson import ObjectId


class HistoryService:
    """Service for managing food analysis history"""

    def __init__(self, db):
        self.db = db

    async def save_analysis(
        self,
        user_id: str,
        analysis_data: Dict[str, Any]
    ) -> str:
        """
        Save a food analysis to history

        Args:
            user_id: User ID
            analysis_data: Analysis result from AI service

        Returns:
            ID of saved analysis
        """
        document = {
            "user_id": ObjectId(user_id),
            "image_url": analysis_data.get("image_url"),
            "meal_type": analysis_data.get("meal_type", "snack"),
            "calories": analysis_data.get("nutrition", {}).get("calories", 0),
            "macros": analysis_data.get("nutrition", {}),
            "items": analysis_data.get("items", []),
            "source": analysis_data.get("source", "unknown"),
            "confidence": analysis_data.get("confidence", 0),
            "created_at": datetime.utcnow()
        }

        result = await self.db.analyses.insert_one(document)
        return str(result.inserted_id)

    async def get_user_history(
        self,
        user_id: str,
        limit: int = 50,
        skip: int = 0
    ) -> List[Dict[str, Any]]:
        """Get user's analysis history"""
        cursor = self.db.analyses.find(
            {"user_id": ObjectId(user_id)}
        ).sort("created_at", -1).skip(skip).limit(limit)

        history = []
        async for doc in cursor:
            doc["id"] = str(doc["_id"])
            del doc["_id"]
            history.append(doc)

        return history

    async def get_daily_history(
        self,
        user_id: str,
        date: datetime
    ) -> Dict[str, Any]:
        """Get history for a specific day"""
        start_of_day = datetime(date.year, date.month, date.day)
        end_of_day = start_of_day + timedelta(days=1)

        cursor = self.db.analyses.find({
            "user_id": ObjectId(user_id),
            "created_at": {"$gte": start_of_day, "$lt": end_of_day}
        })

        analyses = []
        total_calories = 0
        meals = {"breakfast": 0, "lunch": 0, "dinner": 0, "snacks": 0}
        total_macros = {"protein": 0, "carbs": 0, "fat": 0, "fiber": 0, "sugar": 0}

        async for doc in cursor:
            doc["id"] = str(doc["_id"])
            del doc["_id"]
            analyses.append(doc)

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

        return {
            "date": date.isoformat(),
            "total_calories": total_calories,
            "meals": meals,
            "macros": total_macros,
            "analyses": analyses
        }

    async def get_weekly_history(
        self,
        user_id: str,
        end_date: Optional[datetime] = None
    ) -> List[Dict[str, Any]]:
        """Get history for the past week"""
        if end_date is None:
            end_date = datetime.utcnow()

        start_date = end_date - timedelta(days=7)

        cursor = self.db.analyses.find({
            "user_id": ObjectId(user_id),
            "created_at": {"$gte": start_date, "$lt": end_date}
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

    async def get_monthly_history(
        self,
        user_id: str,
        year: int,
        month: int
    ) -> List[Dict[str, Any]]:
        """Get history for a specific month"""
        start_date = datetime(year, month, 1)
        if month == 12:
            end_date = datetime(year + 1, 1, 1)
        else:
            end_date = datetime(year, month + 1, 1)

        cursor = self.db.analyses.find({
            "user_id": ObjectId(user_id),
            "created_at": {"$gte": start_date, "$lt": end_date}
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

    async def get_analysis(self, analysis_id: str) -> Optional[Dict[str, Any]]:
        """Get a specific analysis by ID"""
        doc = await self.db.analyses.find_one({"_id": ObjectId(analysis_id)})
        if doc:
            doc["id"] = str(doc["_id"])
            del doc["_id"]
            return doc
        return None

    async def delete_analysis(self, analysis_id: str) -> bool:
        """Delete an analysis"""
        result = await self.db.analyses.delete_one({"_id": ObjectId(analysis_id)})
        return result.deleted_count > 0

    async def get_stats(self, user_id: str) -> Dict[str, Any]:
        """Get user statistics"""
        # Get user's daily goal
        user = await self.db.users.find_one({"_id": ObjectId(user_id)})
        daily_goal = user.get("daily_calorie_goal", 2000) if user else 2000

        # Calculate streak
        streak = await self._calculate_streak(user_id)

        # Get today's summary
        today = await self.get_daily_history(user_id, datetime.utcnow())

        # Get weekly average
        weekly = await self.get_weekly_history(user_id)
        weekly_avg = sum(d["calories"] for d in weekly) / len(weekly) if weekly else 0

        # Get most analyzed foods
        cursor = self.db.analyses.aggregate([
            {"$match": {"user_id": ObjectId(user_id)}},
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

        return {
            "daily_goal": daily_goal,
            "streak_days": streak,
            "today": {
                "calories": today["total_calories"],
                "goal_met": today["total_calories"] <= daily_goal,
                "remaining": max(0, daily_goal - today["total_calories"])
            },
            "weekly_average": round(weekly_avg),
            "top_foods": top_foods
        }

    async def _calculate_streak(self, user_id: str) -> int:
        """Calculate user's calorie goal streak"""
        streak = 0
        current_date = datetime.utcnow()

        # Get user's daily goal
        user = await self.db.users.find_one({"_id": ObjectId(user_id)})
        daily_goal = user.get("daily_calorie_goal", 2000) if user else 2000

        while True:
            start_of_day = datetime(current_date.year, current_date.month, current_date.day)
            end_of_day = start_of_day + timedelta(days=1)

            # Get total calories for this day
            cursor = self.db.analyses.find({
                "user_id": ObjectId(user_id),
                "created_at": {"$gte": start_of_day, "$lt": end_of_day}
            })

            total = 0
            async for doc in cursor:
                total += doc.get("calories", 0)

            # Check if goal was met
            if total > 0 and total <= daily_goal:
                streak += 1
                current_date -= timedelta(days=1)
            else:
                break

        return streak

    async def update_daily_summary(self, user_id: str, date: datetime) -> Dict[str, Any]:
        """Update or create daily summary"""
        daily_data = await self.get_daily_history(user_id, date)

        # Get user's goal
        user = await self.db.users.find_one({"_id": ObjectId(user_id)})
        daily_goal = user.get("daily_calorie_goal", 2000) if user else 2000

        # Calculate streak
        streak = await self._calculate_streak(user_id)

        summary = {
            "user_id": ObjectId(user_id),
            "date": date,
            "total_calories": daily_data["total_calories"],
            "meals": daily_data["meals"],
            "macros": daily_data["macros"],
            "goal_met": daily_data["total_calories"] <= daily_goal,
            "streak_days": streak
        }

        # Upsert daily summary
        await self.db.daily_summaries.update_one(
            {"user_id": ObjectId(user_id), "date": date},
            {"$set": summary},
            upsert=True
        )

        return summary
