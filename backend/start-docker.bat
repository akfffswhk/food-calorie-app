@echo off
REM ============================================
REM Food Calorie Analyzer - Docker Setup
REM ============================================

echo ========================================
echo Food Calorie Analyzer - Docker Setup
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not installed or not running
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [1/5] Docker is installed
docker --version
echo.

REM Check if Docker Compose is available
docker compose version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Compose is not available
    pause
    exit /b 1
)

echo [2/5] Docker Compose is available
docker compose version
echo.

REM Stop any existing containers
echo [3/5] Stopping existing containers...
docker compose down
echo.

REM Build and start services
echo [4/5] Building and starting services...
echo This may take several minutes on first run (downloading models)...
echo.

docker compose up -d --build

if %errorlevel% neq 0 (
    echo ERROR: Failed to start services
    pause
    exit /b 1
)

echo.
echo [5/5] Services started successfully!
echo.
echo ========================================
echo Services Status:
echo ========================================
echo.

REM Show running containers
docker compose ps

echo.
echo ========================================
echo Service URLs:
echo ========================================
echo - Backend API:     http://localhost:8000
echo - API Docs:        http://localhost:8000/docs
echo - Service Status:  http://localhost:8000/api/status
echo - MongoDB:         mongodb://localhost:27017
echo - Ollama:          http://localhost:11434
echo.
echo ========================================
echo Next Steps:
echo ========================================
echo 1. Wait for models to download (check logs with: docker compose logs -f ollama)
echo 2. Visit http://localhost:8000/api/status to check service status
echo 3. Visit http://localhost:8000/docs to test the API
echo.
echo To view logs: docker compose logs -f
echo To stop services: docker compose down
echo.

pause
