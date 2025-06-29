# syntax=docker/dockerfile:1.4
# Multi-stage build for optimized caching and minimal final image

#==============================================================================
# BUILD STAGE: Install dependencies and prepare application
#==============================================================================
FROM python:3.11-slim AS builder

# Set environment variables for build optimization
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies and build tools in single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create app directory
WORKDIR /app

# Copy and install Python dependencies with cache mount for faster rebuilds
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --user --no-warn-script-location -r requirements.txt

#==============================================================================
# RUNTIME STAGE: Minimal production image
#==============================================================================
FROM python:3.11-slim AS runtime

# Set production environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/home/botuser/.local/bin:$PATH" \
    USER=botuser \
    UID=1001 \
    GID=1001

# Create non-root user and setup directories in single layer
RUN groupadd -g $GID $USER \
    && useradd -u $UID -g $GID -m -d /home/$USER -s /bin/bash $USER \
    && mkdir -p /app \
    && chown -R $USER:$USER /app

# Set working directory
WORKDIR /app

# Copy Python packages from builder stage
COPY --from=builder --chown=$USER:$USER /root/.local /home/$USER/.local

# Copy application code with proper ownership
COPY --chown=$USER:$USER src/main.py .
COPY --chown=$USER:$USER worker_functions/ ./worker_functions/

# Switch to non-root user for security
USER $USER

# Add metadata labels for better image management
LABEL maintainer="Discord Bot Framework" \
      version="1.0" \
      description="Extensible Discord bot with worker functions" \
      org.opencontainers.image.source="https://github.com/jijainth-code/discord_bot_framework"

# Health check to ensure the bot is running properly
HEALTHCHECK --interval=30s \
            --timeout=10s \
            --start-period=5s \
            --retries=3 \
    CMD python -c "import sys; import os; sys.exit(0 if os.path.exists('worker_functions') else 1)"

# Expose port for future webhook functionality (optional)
EXPOSE 8000

# Use exec form for better signal handling
CMD ["python", "main.py"] 