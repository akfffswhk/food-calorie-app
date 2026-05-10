# Food Calorie Analyzer - Docker Setup Guide

## Architecture Overview

This application uses a **Local/Offline First** architecture with Docker:

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Compose Stack                  │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  MongoDB   │  │   Ollama    │  │  FastAPI    │    │
│  │  (Database)│  │  (AI Model) │  │  (Backend)  │    │
│  │  Port:27017│  │  Port:11434 │  │  Port:8000  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                           │
│  External Services (Optional):                            │
│  - USDA API (Nutrition Data)                             │
│  - Hugging Face (Cloud Fallback)                         │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

1. **Docker Desktop** - Download from https://www.docker.com/products/docker-desktop
2. **USDA API Key** - Get from https://api.nal.usda.gov/ (already configured)
3. **8GB+ RAM** - For running Ollama models
4. **10GB+ Disk Space** - For model storage

## Quick Start

### 1. Start All Services

Double-click `start-docker.bat` or run:

```bash
docker compose up -d --build
```

### 2. Wait for Models to Download

The first run will download AI models (LLaVA ~4GB, Moondream ~2GB). Monitor progress:

```bash
docker compose logs -f ollama
```

### 3. Check Service Status

Double-click `check-status.bat` or run:

```bash
docker compose ps
```

### 4. Test the API

Visit:
- **API Docs**: http://localhost:8000/docs
- **Status**: http://localhost:8000/api/status
- **Health**: http://localhost:8000/health

## Services

### MongoDB (Database)
- **Port**: 27017
- **Volume**: `mongodb_data`
- **Purpose**: Store user data, analyses, history

### Ollama (AI Model)
- **Port**: 11434
- **Volume**: `ollama_data`
- **Models**: LLaVA, Moondream
- **Purpose**: Local food image analysis

### FastAPI (Backend)
- **Port**: 8000
- **Purpose**: API server and business logic

## Configuration

Edit `.env` file to customize:

```env
# AI Model Selection
OLLAMA_MODEL=llama          # Options: llava, moondream, bakllava

# Processing Mode
USE_LOCAL_FIRST=true        # Use Docker services first
OFFLINE_MODE=false          # Disable external APIs

# Performance
REQUEST_TIMEOUT=30          # AI processing timeout
NUTRITION_CACHE_DURATION=3600  # Cache nutrition data (seconds)
```

## Common Commands

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f ollama
docker compose logs -f mongodb
```

### Stop Services
```bash
docker compose down
```

### Restart Services
```bash
docker compose restart
```

### Rebuild Services
```bash
docker compose up -d --build
```

### Clean Everything (including volumes)
```bash
docker compose down -v
```

### Pull New Models
```bash
# Pull LLaVA
docker exec -it food-calorie-ollama ollama pull llava

# Pull Moondream (lighter)
docker exec -it food-calorie-ollama ollama pull moondream

# List available models
docker exec -it food-calorie-ollama ollama list
```

## Troubleshooting

### Services Not Starting

1. Check Docker Desktop is running
2. Check port conflicts:
   ```bash
   netstat -ano | findstr "8000"
   netstat -ano | findstr "27017"
   netstat -ano | findstr "11434"
   ```

### Ollama Model Not Available

1. Check if model is downloaded:
   ```bash
   curl http://localhost:11434/api/tags
   ```

2. Pull the model manually:
   ```bash
   docker exec -it food-calorie-ollama ollama pull llava
   ```

### Backend Can't Connect to Ollama

1. Check Ollama is running:
   ```bash
   docker compose ps ollama
   ```

2. Check backend logs:
   ```bash
   docker compose logs backend
   ```

### USDA API Errors

1. Verify API key in `.env`:
   ```env
   USDA_API_KEY=your_key_here
   ```

2. Test API key:
   ```bash
   curl "https://api.nal.usda.gov/fdc/v1/foods/search?api_key=YOUR_KEY&query=apple"
   ```

### Out of Memory

1. Reduce model size:
   ```env
   OLLAMA_MODEL=moondream  # Lighter than llava
   ```

2. Limit Ollama threads:
   ```env
   OLLAMA_NUM_THREAD=2
   ```

### Slow Performance

1. Use lighter model:
   ```env
   OLLAMA_MODEL=moondream
   ```

2. Increase timeout:
   ```env
   REQUEST_TIMEOUT=60
   ```

## GPU Support (Optional)

For faster AI processing with NVIDIA GPU:

1. Install NVIDIA Container Toolkit
2. Uncomment GPU section in `docker-compose.yml`:
   ```yaml
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: 1
             capabilities: [gpu]
   ```

3. Restart services:
   ```bash
   docker compose up -d --build
   ```

## Offline Mode

To run completely offline (no external APIs):

1. Set in `.env`:
   ```env
   OFFLINE_MODE=true
   ```

2. Restart backend:
   ```bash
   docker compose restart backend
   ```

The app will use:
- Local Ollama models for food detection
- Built-in nutrition database for calorie estimation
- No external API calls

## Production Deployment

### Environment Variables

Set production values in `.env`:

```env
# Security
DEBUG=false
CORS_ORIGINS=https://yourdomain.com

# Performance
RELOAD=false
LOG_LEVEL=WARNING

# Resources
OLLAMA_NUM_THREAD=4
REQUEST_TIMEOUT=60
```

### Resource Limits

Add to `docker-compose.yml`:

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
    restart: always

  ollama:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
    restart: always
```

## Monitoring

### Health Checks

```bash
# Backend health
curl http://localhost:8000/health

# Service status
curl http://localhost:8000/api/status

# Ollama status
curl http://localhost:11434/api/tags
```

### Resource Usage

```bash
# Container stats
docker stats

# Disk usage
docker system df

# Volume usage
docker volume ls
```

## Backup & Restore

### Backup MongoDB

```bash
docker exec food-calorie-mongodb mongodump --archive=/backup/mongo-backup.gz
docker cp food-calorie-mongodb:/backup/mongo-backup.gz ./mongo-backup.gz
```

### Restore MongoDB

```bash
docker cp ./mongo-backup.gz food-calorie-mongodb:/backup/mongo-backup.gz
docker exec food-calorie-mongodb mongorestore --archive=/backup/mongo-backup.gz
```

## Support

- **Docker Docs**: https://docs.docker.com
- **Ollama Docs**: https://ollama.ai/docs
- **USDA API**: https://api.nal.usda.gov/
