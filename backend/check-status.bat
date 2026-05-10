@echo off
REM ============================================
REM Food Calorie Analyzer - Service Status Check
REM ============================================

echo ========================================
echo Food Calorie Analyzer - Service Status
echo ========================================
echo.

REM Check if Docker is running
docker ps >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running
    pause
    exit /b 1
)

echo [1/4] Checking Docker containers...
docker compose ps
echo.

echo [2/4] Checking Backend API health...
curl -s http://localhost:8000/health
echo.
echo.

echo [3/4] Checking AI Service Status...
curl -s http://localhost:8000/api/status
echo.
echo.

echo [4/4] Checking Ollama Models...
curl -s http://localhost:11434/api/tags
echo.

echo ========================================
echo Service Status Complete
echo ========================================
echo.
echo If all services are running, visit:
echo - API Docs: http://localhost:8000/docs
echo - Status:   http://localhost:8000/api/status
echo.

pause
