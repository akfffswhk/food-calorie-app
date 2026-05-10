@echo off
REM Run the Food Calorie Analyzer Backend

echo ========================================
echo Food Calorie Analyzer - Backend
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

echo [1/3] Checking Python version...
python --version
echo.

echo [2/3] Checking dependencies...
pip show fastapi >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing dependencies...
    pip install -r requirements.txt
) else (
    echo Dependencies already installed
)
echo.

echo [3/3] Starting the server...
echo.
echo The API will be available at: http://localhost:8000
echo API Documentation: http://localhost:8000/docs
echo.
echo Press Ctrl+C to stop the server
echo.

python run.py

pause
