# YOLO Food Detection Service
# Based on ultralytics/ultralytics with custom food detection model

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    libgomp1 \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir \
    ultralytics==8.0.196 \
    fastapi==0.104.1 \
    uvicorn==0.24.0 \
    python-multipart==0.0.6 \
    pillow==10.1.0 \
    numpy==1.24.3 \
    opencv-python==4.8.1.78 \
    pydantic==2.5.0

# Download the Food-Detection model
# Using a pre-trained YOLOv8 model trained on food dataset
RUN mkdir -p /app/models

# Download the model weights (will be pulled from repository or URL)
# For now, we'll use a placeholder - you can replace with actual model URL
RUN echo "Model weights will be downloaded on first run" > /app/models/README.txt

# Copy the API server code
COPY yolo_service.py /app/

# Expose port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# Run the service
CMD ["uvicorn", "yolo_service:app", "--host", "0.0.0.0", "--port", "8001"]
