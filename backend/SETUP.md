# Food Calorie Analyzer - Setup Guide

## Hybrid AI Service Setup

This guide walks you through setting up the hybrid AI service that combines:
- **LM Studio** (local processing, free)
- **Hugging Face** (cloud fallback, free tier)
- **USDA FoodData Central** (nutrition data, free)

---

## Prerequisites

- Python 3.9 or higher
- LM Studio (for local processing)
- Hugging Face account (for cloud fallback)
- USDA API key (for nutrition data)

---

## Step 1: Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

---

## Step 2: Set Up LM Studio (Local Processing)

### Download and Install LM Studio

1. Download from: https://lmstudio.ai/
2. Install and launch LM Studio
3. Download a vision model:
   - Search for "llava" or "bakllava"
   - Recommended: `llava-1.5-7b` or `bakllava-1-7b`
   - Click "Download"

### Configure LM Studio

1. In LM Studio, go to **Settings** → **Server**
2. Enable **"Start server on app start"**
3. Set **Port** to `1234` (or update in `.env`)
4. Enable **"CORS"** to allow API calls
5. Click **"Start Server"**

### Verify LM Studio is Running

```bash
curl http://localhost:1234/v1/models
```

You should see a JSON response with available models.

---

## Step 3: Get Hugging Face Token (Fallback)

1. Go to: https://huggingface.co/settings/tokens
2. Click **"New token"**
3. Name it "Food Calorie App"
4. Select **"Read"** permissions
5. Copy the token

---

## Step 4: Get USDA API Key (Nutrition Data)

1. Go to: https://api.nal.usda.gov/
2. Click **"Request an API Key"**
3. Fill out the form (free)
4. You'll receive an API key via email

---

## Step 5: Configure Environment Variables

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` with your credentials:
```env
# LM Studio (Local Processing)
LM_STUDIO_HOST=localhost
LM_STUDIO_PORT=1234
LM_STUDIO_MODEL=llava-1.5-7b

# Hugging Face (Fallback)
HF_API_TOKEN=hf_your_token_here
HF_FOOD_MODEL=microsoft/Food-101

# USDA FoodData Central
USDA_API_KEY=your_usda_api_key_here

# Fallback Settings
USE_LOCAL_FIRST=true
LOCAL_TIMEOUT=30
HF_TIMEOUT=15

# Nutrition Estimation
DEFAULT_PORTION_SIZE=100
CONFIDENCE_THRESHOLD=0.3
```

---

## Step 6: Start the Backend Server

```bash
# From backend directory
python -m app.main
```

Or with uvicorn:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`

---

## Step 7: Test the API

### Check Service Status
```bash
curl http://localhost:8000/api/status
```

Expected response:
```json
{
  "lm_studio": true,
  "hugging_face": true,
  "usda": true,
  "use_local_first": true
}
```

### Analyze a Food Image
```bash
curl -X POST http://localhost:8000/api/analyze \
  -F "image=@path/to/food_image.jpg"
```

Or with base64:
```bash
curl -X POST http://localhost:8000/api/analyze/base64 \
  -H "Content-Type: application/json" \
  -d '{"image": "base64_encoded_image_string"}'
```

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API info |
| GET | `/health` | Health check |
| GET | `/api/status` | Service status |
| POST | `/api/analyze` | Analyze food image (file upload) |
| POST | `/api/analyze/base64` | Analyze food image (base64) |

---

## How the Hybrid Approach Works

```
┌─────────────────────────────────────────────────────────┐
│                    Food Image Upload                     │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│              Try LM Studio (Local) First                 │
│  - Fast, no API limits                                   │
│  - Requires LM Studio running                            │
│  - Uses vision model (llava, bakllava)                   │
└─────────────────────────────────────────────────────────┘
                            │
                    ┌───────┴───────┐
                    │   Success?    │
                    └───────┬───────┘
                       No   │   Yes
                       ┌────┴────┐
                       ▼         ▼
┌────────────────────────┐  ┌────────────────────────┐
│  Try Hugging Face     │  │  Return Results        │
│  (Cloud Fallback)     │  │  - Food items          │
│  - Free tier          │  │  - Calories             │
│  - Rate limited       │  │  - Macros               │
│  - Food-101 model     │  │  - Source: lm_studio    │
└────────────────────────┘  └────────────────────────┘
                            │
                    ┌───────┴───────┐
                    │   Success?    │
                    └───────┬───────┘
                       No   │   Yes
                       ┌────┴────┐
                       ▼         ▼
┌────────────────────────┐  ┌────────────────────────┐
│  Use Fallback          │  │  Return Results        │
│  - Conservative est.   │  │  - Food items          │
│  - Generic values      │  │  - Calories             │
│  - Low confidence      │  │  - Source: hugging_face│
└────────────────────────┘  └────────────────────────┘
                            │
                            ▼
                    ┌────────────────────────┐
                    │  Return Results        │
                    │  - "Unknown food"      │
                    │  - Est. 200 calories   │
                    │  - Source: fallback    │
                    └────────────────────────┘
```

---

## Troubleshooting

### LM Studio Not Available

**Symptom:** `"lm_studio": false` in status

**Solutions:**
1. Make sure LM Studio is running
2. Check the server is started in LM Studio
3. Verify port matches in `.env` (default: 1234)
4. Check firewall settings

### Hugging Face Errors

**Symptom:** Analysis fails with Hugging Face error

**Solutions:**
1. Verify your token is valid
2. Check you haven't exceeded rate limits
3. Try a different model in `.env`

### USDA API Errors

**Symptom:** Nutrition data missing or incorrect

**Solutions:**
1. Verify your API key is valid
2. Check USDA service is operational
3. The service will fall back to estimation

### Image Processing Errors

**Symptom:** "Invalid image" error

**Solutions:**
1. Ensure image is JPEG or PNG
2. Check file size (max 10MB recommended)
3. Verify image is not corrupted

---

## Performance Tips

1. **Use LM Studio** for fastest results (no network latency)
2. **Download smaller models** if you have limited RAM (e.g., bakllava)
3. **Enable caching** in production for repeated queries
4. **Use CDN** for image storage to reduce upload time

---

## Next Steps

1. Set up MongoDB for history tracking
2. Implement user authentication
3. Build the Flutter frontend
4. Add suggestion algorithms
5. Deploy to production

---

## Support

- LM Studio: https://lmstudio.ai/docs
- Hugging Face: https://huggingface.co/docs
- USDA API: https://api.nal.usda.gov/
