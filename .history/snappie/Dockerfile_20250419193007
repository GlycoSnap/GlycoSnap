FROM python:3.12-slim

WORKDIR /app

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to cache pip installs
COPY requirements.txt .
RUN pip install -r requirements.txt --timeout=100

# Copy app files
COPY . .

# Expose FastAPI port
EXPOSE 8000

CMD ["uvicorn", "chatbot:app", "--host", "0.0.0.0", "--port", "8000"]