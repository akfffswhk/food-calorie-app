@echo off
REM Quick Start Script for Food Calorie Analyzer Backend

echo ========================================
echo Food Calorie Analyzer - Quick Start
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.9 or higher from https://python.org/
    pause
    exit /b 1
)

echo [1/4] Checking Python version...
python --version

echo.
echo [2/4] Installing dependencies...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo [3/4] Checking environment configuration...
if not exist .env (
    echo Creating .env file from example...
    copy .env.example .env
    echo.
    echo IMPORTANT: Please edit .env and add your API keys:
    echo   - HF_API_TOKEN (Hugging Face)
    echo   - USDA_API_KEY (USDA FoodData)
    echo.
    echo You can get them from:
    echo   - Hugging Face: https://huggingface.co/settings/tokens
    echo   - USDA: https://api.nal.usda.gov/
    echo.
    pause
)

echo.
echo [4/4] Starting the server...
echo.
echo The API will be available at: http://localhost:8000
echo API Documentation: http://localhost:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo.

python run.py

pause
