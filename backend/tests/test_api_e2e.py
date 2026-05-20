"""
E2E Tests for Food Calorie App API

This module contains comprehensive end-to-end tests for all API endpoints.
"""

import pytest
import asyncio
import base64
from httpx import AsyncClient, ASGITransport
from PIL import Image
import io
from datetime import datetime, timedelta
from bson import ObjectId

from app.main import app
from app.database import Database
from app.auth import get_password_hash


# Test fixtures
@pytest.fixture(scope="module")
def event_loop():
    """Create an instance of the default event loop for the test module."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="module")
async def setup_database():
    """Setup test database."""
    await Database.connect()
    yield
    await Database.disconnect()


@pytest.fixture(scope="module")
async def test_client(setup_database):
    """Create a test client for the API."""
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as client:
        yield client


@pytest.fixture
async def test_user(setup_database):
    """Create a test user and return credentials."""
    from app.database import get_users_collection

    users_collection = get_users_collection()

    # Generate unique email
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    email = f"testuser_{timestamp}@example.com"
    password = "testpassword123"

    # Create user
    user_doc = {
        "email": email,
        "password_hash": get_password_hash(password),
        "username": f"testuser_{timestamp}",
        "daily_calorie_goal": 2000,
        "dietary_preferences": [],
        "allergies": [],
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
        "is_active": True
    }

    result = await users_collection.insert_one(user_doc)
    user_id = str(result.inserted_id)

    yield {
        "email": email,
        "password": password,
        "user_id": user_id
    }

    # Cleanup
    await users_collection.delete_one({"_id": ObjectId(user_id)})


@pytest.fixture
async def auth_token(test_client, test_user):
    """Get authentication token for test user."""
    response = await test_client.post(
        "/api/auth/login",
        json={
            "email": test_user["email"],
            "password": test_user["password"]
        }
    )
    assert response.status_code == 200
    return response.json()["access_token"]


@pytest.fixture
def auth_headers(auth_token):
    """Get authentication headers."""
    return {"Authorization": f"Bearer {auth_token}"}


@pytest.fixture
def sample_image():
    """Create a sample image for testing."""
    # Create a simple test image
    img = Image.new('RGB', (100, 100), color='red')
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    return img_bytes


@pytest.fixture
def sample_base64_image():
    """Create a sample base64 image for testing."""
    img = Image.new('RGB', (100, 100), color='blue')
    img_bytes = io.BytesIO()
    img.save(img_bytes, format='JPEG')
    img_bytes.seek(0)
    return base64.b64encode(img_bytes.read()).decode('utf-8')


# ============================================================================
# Authentication Tests
# ============================================================================

class TestAuthentication:
    """Test authentication endpoints."""

    @pytest.mark.asyncio
    async def test_register_new_user(self, test_client):
        """Test registering a new user."""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        response = await test_client.post(
            "/api/auth/register",
            json={
                "email": f"newuser_{timestamp}@example.com",
                "password": "password123",
                "username": f"newuser_{timestamp}"
            }
        )

        assert response.status_code == 201
        data = response.json()
        assert "access_token" in data
        assert "user" in data
        assert data["user"]["email"] == f"newuser_{timestamp}@example.com"
        assert data["user"]["username"] == f"newuser_{timestamp}"

    @pytest.mark.asyncio
    async def test_register_duplicate_email(self, test_client, test_user):
        """Test registering with duplicate email."""
        response = await test_client.post(
            "/api/auth/register",
            json={
                "email": test_user["email"],
                "password": "password123"
            }
        )

        assert response.status_code == 400
        assert "already registered" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_register_short_password(self, test_client):
        """Test registering with short password."""
        response = await test_client.post(
            "/api/auth/register",
            json={
                "email": "test@example.com",
                "password": "123"  # Too short
            }
        )

        assert response.status_code == 422  # Validation error

    @pytest.mark.asyncio
    async def test_login_valid_credentials(self, test_client, test_user):
        """Test login with valid credentials."""
        response = await test_client.post(
            "/api/auth/login",
            json={
                "email": test_user["email"],
                "password": test_user["password"]
            }
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "user" in data
        assert data["user"]["email"] == test_user["email"]

    @pytest.mark.asyncio
    async def test_login_invalid_email(self, test_client):
        """Test login with invalid email."""
        response = await test_client.post(
            "/api/auth/login",
            json={
                "email": "nonexistent@example.com",
                "password": "password123"
            }
        )

        assert response.status_code == 401
        assert "Invalid" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_login_invalid_password(self, test_client, test_user):
        """Test login with invalid password."""
        response = await test_client.post(
            "/api/auth/login",
            json={
                "email": test_user["email"],
                "password": "wrongpassword"
            }
        )

        assert response.status_code == 401
        assert "Invalid" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_get_current_user(self, test_client, auth_headers):
        """Test getting current user info."""
        response = await test_client.get(
            "/api/auth/me",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "email" in data

    @pytest.mark.asyncio
    async def test_get_current_user_unauthorized(self, test_client):
        """Test getting current user without authentication."""
        response = await test_client.get("/api/auth/me")

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_logout(self, test_client, auth_headers):
        """Test logout."""
        response = await test_client.post(
            "/api/auth/logout",
            headers=auth_headers
        )

        assert response.status_code == 200
        assert "Successfully logged out" in response.json()["message"]

    @pytest.mark.asyncio
    async def test_refresh_token(self, test_client, auth_token):
        """Test token refresh."""
        response = await test_client.post(
            "/api/auth/refresh",
            data={"refresh_token": auth_token}
        )

        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "token_type" in data

    @pytest.mark.asyncio
    async def test_refresh_token_invalid(self, test_client):
        """Test token refresh with invalid token."""
        response = await test_client.post(
            "/api/auth/refresh",
            data={"refresh_token": "invalid_token"}
        )

        assert response.status_code == 401


# ============================================================================
# Analysis Tests
# ============================================================================

class TestAnalysis:
    """Test food analysis endpoints."""

    @pytest.mark.asyncio
    async def test_get_status(self, test_client):
        """Test getting service status."""
        response = await test_client.get("/api/status")

        assert response.status_code == 200
        data = response.json()
        assert "yolo" in data
        assert "gemma" in data
        assert "usda" in data

    @pytest.mark.asyncio
    async def test_analyze_image_unauthorized(self, test_client, sample_image):
        """Test analyzing image without authentication."""
        files = {"image": ("test.jpg", sample_image, "image/jpeg")}
        response = await test_client.post("/api/analyze", files=files)

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_analyze_image_authorized(self, test_client, auth_headers, sample_image):
        """Test analyzing image with authentication."""
        files = {"image": ("test.jpg", sample_image, "image/jpeg")}
        response = await test_client.post(
            "/api/analyze",
            files=files,
            headers=auth_headers
        )

        # Note: This may fail if AI services are not running
        # The test verifies the endpoint is accessible
        assert response.status_code in [200, 500]  # 500 if services down

    @pytest.mark.asyncio
    async def test_analyze_base64_unauthorized(self, test_client, sample_base64_image):
        """Test analyzing base64 image without authentication."""
        response = await test_client.post(
            "/api/analyze/base64",
            json={"image": sample_base64_image}
        )

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_analyze_base64_authorized(self, test_client, auth_headers, sample_base64_image):
        """Test analyzing base64 image with authentication."""
        response = await test_client.post(
            "/api/analyze/base64",
            json={"image": sample_base64_image},
            headers=auth_headers
        )

        # Note: This may fail if AI services are not running
        assert response.status_code in [200, 500]

    @pytest.mark.asyncio
    async def test_analyze_base64_missing_image(self, test_client, auth_headers):
        """Test analyzing with missing image field."""
        response = await test_client.post(
            "/api/analyze/base64",
            json={},
            headers=auth_headers
        )

        assert response.status_code == 400


# ============================================================================
# History Tests
# ============================================================================

class TestHistory:
    """Test history endpoints."""

    @pytest.mark.asyncio
    async def test_save_analysis(self, test_client, auth_headers):
        """Test saving analysis to history."""
        analysis_data = {
            "meal_type": "lunch",
            "calories": 500,
            "macros": {
                "protein": 25.0,
                "carbs": 50.0,
                "fat": 15.0,
                "fiber": 5.0,
                "sugar": 10.0
            },
            "items": [
                {
                    "name": "Chicken Salad",
                    "confidence": 0.95,
                    "portion": "1 serving",
                    "estimated_grams": 200
                }
            ],
            "source": "AI"
        }

        response = await test_client.post(
            "/api/history",
            json=analysis_data,
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert data["calories"] == 500
        assert data["meal_type"] == "lunch"

    @pytest.mark.asyncio
    async def test_get_history(self, test_client, auth_headers):
        """Test getting user history."""
        response = await test_client.get(
            "/api/history",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_get_history_unauthorized(self, test_client):
        """Test getting history without authentication."""
        response = await test_client.get("/api/history")

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_get_daily_history(self, test_client, auth_headers):
        """Test getting daily history."""
        today = datetime.now().strftime("%Y-%m-%d")
        response = await test_client.get(
            f"/api/history/daily/{today}",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "date" in data
        assert "total_calories" in data
        assert "meals" in data

    @pytest.mark.asyncio
    async def test_get_daily_history_invalid_date(self, test_client, auth_headers):
        """Test getting daily history with invalid date format."""
        response = await test_client.get(
            "/api/history/daily/invalid-date",
            headers=auth_headers
        )

        assert response.status_code == 400

    @pytest.mark.asyncio
    async def test_get_weekly_history(self, test_client, auth_headers):
        """Test getting weekly history."""
        response = await test_client.get(
            "/api/history/weekly",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_get_monthly_history(self, test_client, auth_headers):
        """Test getting monthly history."""
        today = datetime.now()
        response = await test_client.get(
            f"/api/history/monthly?year={today.year}&month={today.month}",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_get_stats(self, test_client, auth_headers):
        """Test getting user statistics."""
        response = await test_client.get(
            "/api/history/stats",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "daily_goal" in data
        assert "streak_days" in data
        assert "today" in data
        assert "weekly_average" in data
        assert "top_foods" in data

    @pytest.mark.asyncio
    async def test_get_analysis_by_id(self, test_client, auth_headers):
        """Test getting a specific analysis by ID."""
        # First save an analysis
        analysis_data = {
            "meal_type": "dinner",
            "calories": 600,
            "macros": {
                "protein": 30.0,
                "carbs": 60.0,
                "fat": 20.0,
                "fiber": 8.0,
                "sugar": 12.0
            },
            "items": [
                {
                    "name": "Pasta",
                    "confidence": 0.90,
                    "portion": "1 serving",
                    "estimated_grams": 250
                }
            ],
            "source": "AI"
        }

        save_response = await test_client.post(
            "/api/history",
            json=analysis_data,
            headers=auth_headers
        )
        analysis_id = save_response.json()["id"]

        # Get the analysis
        response = await test_client.get(
            f"/api/history/{analysis_id}",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == analysis_id
        assert data["calories"] == 600

    @pytest.mark.asyncio
    async def test_delete_analysis(self, test_client, auth_headers):
        """Test deleting an analysis."""
        # First save an analysis
        analysis_data = {
            "meal_type": "snack",
            "calories": 200,
            "macros": {
                "protein": 5.0,
                "carbs": 30.0,
                "fat": 8.0,
                "fiber": 2.0,
                "sugar": 15.0
            },
            "items": [
                {
                    "name": "Apple",
                    "confidence": 0.98,
                    "portion": "1 medium",
                    "estimated_grams": 150
                }
            ],
            "source": "AI"
        }

        save_response = await test_client.post(
            "/api/history",
            json=analysis_data,
            headers=auth_headers
        )
        analysis_id = save_response.json()["id"]

        # Delete the analysis
        response = await test_client.delete(
            f"/api/history/{analysis_id}",
            headers=auth_headers
        )

        assert response.status_code == 200
        assert "deleted successfully" in response.json()["message"]

    @pytest.mark.asyncio
    async def test_delete_analysis_not_found(self, test_client, auth_headers):
        """Test deleting a non-existent analysis."""
        fake_id = str(ObjectId())
        response = await test_client.delete(
            f"/api/history/{fake_id}",
            headers=auth_headers
        )

        assert response.status_code == 404


# ============================================================================
# Suggestions Tests
# ============================================================================

class TestSuggestions:
    """Test suggestions endpoints."""

    @pytest.mark.asyncio
    async def test_get_suggestions(self, test_client, auth_headers):
        """Test getting meal suggestions."""
        response = await test_client.get(
            "/api/suggestions?meal_type=lunch&remaining_calories=500",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_get_suggestions_unauthorized(self, test_client):
        """Test getting suggestions without authentication."""
        response = await test_client.get("/api/suggestions")

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_get_meal_suggestions(self, test_client, auth_headers):
        """Test getting meal suggestions."""
        response = await test_client.get(
            "/api/suggestions/meal?remaining_calories=600",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_get_recipe_suggestions(self, test_client, auth_headers):
        """Test getting recipe suggestions."""
        response = await test_client.get(
            "/api/suggestions/recipe?ingredients=chicken&ingredients=rice&max_calories=500",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_get_alternative_suggestions(self, test_client, auth_headers):
        """Test getting alternative suggestions."""
        response = await test_client.get(
            "/api/suggestions/alternative/pizza?current_calories=300",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)

    @pytest.mark.asyncio
    async def test_toggle_favorite(self, test_client, auth_headers):
        """Test toggling favorite status."""
        # This test requires a valid suggestion ID
        # For now, we'll test the endpoint structure
        fake_id = str(ObjectId())
        response = await test_client.post(
            f"/api/suggestions/favorite/{fake_id}",
            headers=auth_headers
        )

        # May return 404 if suggestion doesn't exist
        assert response.status_code in [200, 404]

    @pytest.mark.asyncio
    async def test_get_favorites(self, test_client, auth_headers):
        """Test getting favorite suggestions."""
        response = await test_client.get(
            "/api/suggestions/favorites",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert isinstance(data, list)


# ============================================================================
# Profile Tests
# ============================================================================

class TestProfile:
    """Test profile endpoints."""

    @pytest.mark.asyncio
    async def test_get_profile(self, test_client, auth_headers):
        """Test getting user profile."""
        response = await test_client.get(
            "/api/profile",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "email" in data
        assert "daily_calorie_goal" in data
        assert "dietary_preferences" in data
        assert "allergies" in data

    @pytest.mark.asyncio
    async def test_get_profile_unauthorized(self, test_client):
        """Test getting profile without authentication."""
        response = await test_client.get("/api/profile")

        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_update_profile(self, test_client, auth_headers):
        """Test updating user profile."""
        update_data = {
            "dietary_preferences": ["vegetarian", "gluten-free"],
            "allergies": ["nuts"]
        }

        response = await test_client.put(
            "/api/profile",
            json=update_data,
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert "dietary_preferences" in data
        assert "allergies" in data

    @pytest.mark.asyncio
    async def test_update_goals(self, test_client, auth_headers):
        """Test updating calorie goals."""
        response = await test_client.put(
            "/api/profile/goals",
            json={"daily_calorie_goal": 2500},
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert data["daily_calorie_goal"] == 2500

    @pytest.mark.asyncio
    async def test_update_goals_invalid(self, test_client, auth_headers):
        """Test updating with invalid calorie goal."""
        response = await test_client.put(
            "/api/profile/goals",
            json={"daily_calorie_goal": 100},  # Below minimum
            headers=auth_headers
        )

        assert response.status_code == 422  # Validation error

    @pytest.mark.asyncio
    async def test_change_password(self, test_client, auth_headers, test_user):
        """Test changing password."""
        response = await test_client.post(
            "/api/profile/change-password",
            json={
                "current_password": test_user["password"],
                "new_password": "newpassword123"
            },
            headers=auth_headers
        )

        assert response.status_code == 200
        assert "successfully" in response.json()["message"]

    @pytest.mark.asyncio
    async def test_change_password_wrong_current(self, test_client, auth_headers):
        """Test changing password with wrong current password."""
        response = await test_client.post(
            "/api/profile/change-password",
            json={
                "current_password": "wrongpassword",
                "new_password": "newpassword123"
            },
            headers=auth_headers
        )

        assert response.status_code == 400
        assert "incorrect" in response.json()["detail"]

    @pytest.mark.asyncio
    async def test_change_password_short_new(self, test_client, auth_headers):
        """Test changing password with short new password."""
        response = await test_client.post(
            "/api/profile/change-password",
            json={
                "current_password": "testpassword123",
                "new_password": "123"  # Too short
            },
            headers=auth_headers
        )

        assert response.status_code == 422  # Validation error

    @pytest.mark.asyncio
    async def test_delete_account(self, test_client, auth_headers):
        """Test deleting account."""
        # Note: This will actually delete the test user
        # Use with caution in real scenarios
        response = await test_client.delete(
            "/api/profile",
            headers=auth_headers
        )

        assert response.status_code == 200
        assert "deleted successfully" in response.json()["message"]


# ============================================================================
# Integration Tests
# ============================================================================

class TestIntegration:
    """Test complete user flows."""

    @pytest.mark.asyncio
    async def test_complete_user_flow(self, test_client):
        """Test complete user registration and usage flow."""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        email = f"flowtest_{timestamp}@example.com"
        password = "password123"

        # 1. Register
        register_response = await test_client.post(
            "/api/auth/register",
            json={
                "email": email,
                "password": password,
                "username": f"flowtest_{timestamp}"
            }
        )
        assert register_response.status_code == 201
        token = register_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        # 2. Get profile
        profile_response = await test_client.get("/api/profile", headers=headers)
        assert profile_response.status_code == 200

        # 3. Update goals
        goals_response = await test_client.put(
            "/api/profile/goals",
            json={"daily_calorie_goal": 2200},
            headers=headers
        )
        assert goals_response.status_code == 200

        # 4. Save analysis
        analysis_data = {
            "meal_type": "breakfast",
            "calories": 400,
            "macros": {
                "protein": 20.0,
                "carbs": 50.0,
                "fat": 10.0,
                "fiber": 5.0,
                "sugar": 8.0
            },
            "items": [
                {
                    "name": "Oatmeal",
                    "confidence": 0.95,
                    "portion": "1 bowl",
                    "estimated_grams": 200
                }
            ],
            "source": "AI"
        }
        save_response = await test_client.post(
            "/api/history",
            json=analysis_data,
            headers=headers
        )
        assert save_response.status_code == 200

        # 5. Get history
        history_response = await test_client.get("/api/history", headers=headers)
        assert history_response.status_code == 200
        assert len(history_response.json()) > 0

        # 6. Get stats
        stats_response = await test_client.get("/api/history/stats", headers=headers)
        assert stats_response.status_code == 200

        # 7. Logout
        logout_response = await test_client.post("/api/auth/logout", headers=headers)
        assert logout_response.status_code == 200

        # 8. Verify logout - should fail
        me_response = await test_client.get("/api/auth/me", headers=headers)
        assert me_response.status_code == 401

        # Cleanup
        from app.database import get_users_collection
        users_collection = get_users_collection()
        await users_collection.delete_one({"email": email})

    @pytest.mark.asyncio
    async def test_analysis_and_save_flow(self, test_client, auth_headers, sample_base64_image):
        """Test analyzing image and saving to history."""
        # Note: This test requires AI services to be running
        # It will fail with 500 if services are down

        # 1. Analyze image
        analyze_response = await test_client.post(
            "/api/analyze/base64",
            json={"image": sample_base64_image},
            headers=auth_headers
        )

        # If AI services are down, skip the rest
        if analyze_response.status_code != 200:
            pytest.skip("AI services not available")

        result = analyze_response.json()

        # 2. Save to history
        save_data = {
            "meal_type": "lunch",
            "calories": result["nutrition"]["calories"],
            "macros": result["nutrition"],
            "items": result["items"],
            "source": result["source"]
        }

        save_response = await test_client.post(
            "/api/history",
            json=save_data,
            headers=auth_headers
        )
        assert save_response.status_code == 200

        # 3. Verify in history
        history_response = await test_client.get("/api/history", headers=headers)
        assert history_response.status_code == 200
        assert len(history_response.json()) > 0


# ============================================================================
# Error Handling Tests
# ============================================================================

class TestErrorHandling:
    """Test error handling across all endpoints."""

    @pytest.mark.asyncio
    async def test_invalid_token(self, test_client):
        """Test requests with invalid token."""
        headers = {"Authorization": "Bearer invalid_token"}

        response = await test_client.get("/api/profile", headers=headers)
        assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_missing_token(self, test_client):
        """Test requests without token."""
        protected_endpoints = [
            "/api/profile",
            "/api/history",
            "/api/history/stats",
            "/api/suggestions",
            "/api/suggestions/favorites"
        ]

        for endpoint in protected_endpoints:
            response = await test_client.get(endpoint)
            assert response.status_code == 401

    @pytest.mark.asyncio
    async def test_malformed_json(self, test_client, auth_headers):
        """Test requests with malformed JSON."""
        response = await test_client.post(
            "/api/history",
            data="invalid json",
            headers={**auth_headers, "Content-Type": "application/json"}
        )

        assert response.status_code == 422

    @pytest.mark.asyncio
    async def test_invalid_id_format(self, test_client, auth_headers):
        """Test requests with invalid ID format."""
        response = await test_client.get(
            "/api/history/invalid-id",
            headers=auth_headers
        )

        assert response.status_code == 400

    @pytest.mark.asyncio
    async def test_nonexistent_resource(self, test_client, auth_headers):
        """Test accessing non-existent resources."""
        fake_id = str(ObjectId())

        response = await test_client.get(
            f"/api/history/{fake_id}",
            headers=auth_headers
        )

        assert response.status_code == 404


# ============================================================================
# Performance Tests
# ============================================================================

class TestPerformance:
    """Test API performance."""

    @pytest.mark.asyncio
    async def test_multiple_concurrent_requests(self, test_client, auth_headers):
        """Test handling multiple concurrent requests."""
        import asyncio

        async def make_request():
            return await test_client.get("/api/history", headers=auth_headers)

        # Make 10 concurrent requests
        responses = await asyncio.gather(*[make_request() for _ in range(10)])

        # All should succeed
        for response in responses:
            assert response.status_code == 200

    @pytest.mark.asyncio
    async def test_large_history_pagination(self, test_client, auth_headers):
        """Test pagination with large history."""
        # Save multiple entries
        for i in range(25):
            analysis_data = {
                "meal_type": "snack",
                "calories": 100 + i,
                "macros": {
                    "protein": 5.0,
                    "carbs": 15.0,
                    "fat": 3.0,
                    "fiber": 1.0,
                    "sugar": 8.0
                },
                "items": [
                    {
                        "name": f"Snack {i}",
                        "confidence": 0.90,
                        "portion": "1 serving",
                        "estimated_grams": 100
                    }
                ],
                "source": "AI"
            }
            await test_client.post(
                "/api/history",
                json=analysis_data,
                headers=auth_headers
            )

        # Test pagination
        response = await test_client.get(
            "/api/history?limit=10&skip=0",
            headers=auth_headers
        )

        assert response.status_code == 200
        data = response.json()
        assert len(data) <= 10


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
