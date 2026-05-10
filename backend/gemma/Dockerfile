# Gemma 4:26B Nutrition Service
# FastAPI service for nutrition suggestions using Gemma 4:26B

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    fastapi==0.104.1 \
    uvicorn==0.24.0 \
    pydantic==2.5.0 \
    torch==2.1.0 \
    transformers==4.35.0 \
    accelerate==0.25.0 \
    bitsandbytes==0.41.0

# Copy the API server code
COPY gemma_service.py /app/

# Expose port
EXPOSE 8002

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8002/health || exit 1

# Run the service
CMD ["uvicorn", "gemma_service:app", "--host", "0.0.0.0", "--port", "8002"]
