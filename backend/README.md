# Food Calorie Analyzer - Backend

FastAPI backend with hybrid AI service for food image analysis.

## Features

- **Hybrid AI Processing**: LM Studio (local) + Hugging Face (cloud) + Fallback
- **Nutrition Data**: USDA FoodData Central API integration
- **RESTful API**: Clean endpoints for food analysis
- **Async Processing**: Fast, non-blocking operations
- **Image Validation**: Robust image handling

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your API keys

# Start the server
python -m app.main
```

API will be available at `http://localhost:8000`

## API Documentation

Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API information |
| GET | `/health` | Health check |
| GET | `/api/status` | Service status |
| POST | `/api/analyze` | Analyze food image (file) |
| POST | `/api/analyze/base64` | Analyze food image (base64) |

## Testing

```bash
# Run automated tests
python test_api.py

# Run interactive tests
python test_api.py interactive
```

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │────▶│  FastAPI    │────▶│  AI Service │
│             │     │  Backend    │     │  (Hybrid)   │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                    ┌──────────────────────────┼──────────────────────────┐
                    ▼                          ▼                          ▼
            ┌─────────────┐           ┌─────────────┐           ┌─────────────┐
            │ LM Studio   │           │ Hugging Face│           │   USDA      │
            │  (Local)    │           │  (Cloud)    │           │  (Nutrition)│
            └─────────────┘           └─────────────┘           └─────────────┘
```

## Configuration

See `.env.example` for all configuration options.

## License

MIT
