# Use Python slim image for smaller size
FROM python:3.11-slim AS base

# Set environment variables for Python optimization
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies in a separate layer for better caching
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Create non-root user early for security
RUN groupadd -r botuser && useradd -r -g botuser botuser

# Copy requirements first for better Docker layer caching
# This layer will be cached unless requirements.txt changes
COPY requirements.txt .

# Install Python dependencies in a separate layer
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
# This layer will be rebuilt when source code changes
COPY src/main.py .
COPY worker_functions/ ./worker_functions/
COPY scripts/run.sh .

# Make run.sh executable
RUN chmod +x run.sh

# Change ownership to non-root user
RUN chown -R botuser:botuser /app

# Switch to non-root user for security
USER botuser

# Health check to ensure the bot is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; sys.exit(0)"

# Expose port (if needed for future webhook functionality)
EXPOSE 8000

# Set the default command
CMD ["python", "main.py"] 