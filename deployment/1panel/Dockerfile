# Base image
FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    libffi-dev \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Set Hugging Face mirror
ENV HF_ENDPOINT=https://hf-mirror.com

# Install Python packages
COPY project/MemOS/docker/requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY project/MemOS/src/ ./src/
COPY project/MemOS/docker/ ./docker/

# Set Python import path
ENV PYTHONPATH=/app/src

# Create data and logs directories
RUN mkdir -p /app/data /app/logs

# Expose port
EXPOSE 8000

# Start the application
CMD ["uvicorn", "memos.api.product_api:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]

