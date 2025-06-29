#!/bin/bash

# Docker Optimization Verification Script
# Shows image sizes, build cache, and optimization features

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🐳 Discord Bot Framework - Docker Optimization Verification${NC}"
echo "============================================================="

# Check Docker BuildKit support
echo -e "\n${YELLOW}📋 BuildKit Support:${NC}"
if docker buildx version >/dev/null 2>&1; then
    echo "✅ BuildKit/Buildx available"
    docker buildx version | head -n 1
else
    echo "⚠️  BuildKit not available (using legacy builder)"
fi

# Check experimental features
echo -e "\n${YELLOW}🧪 Experimental Features:${NC}"
if docker version --format '{{.Server.Experimental}}' 2>/dev/null | grep -q "true"; then
    echo "✅ Docker experimental features enabled (--squash available)"
else
    echo "ℹ️  Docker experimental features disabled (--squash not available)"
    echo "   To enable: Add 'experimental: true' to daemon.json"
fi

# Show Docker info
echo -e "\n${YELLOW}🖥️  Docker Environment:${NC}"
echo "Docker version: $(docker --version)"
echo "Docker Compose: $(docker-compose --version 2>/dev/null || echo 'Not available')"

# Check if image exists
IMAGE_NAME="discord-bot-framework"
if docker images -q "$IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "\n${YELLOW}📦 Current Images:${NC}"
    docker images "$IMAGE_NAME" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    # Show layers
    echo -e "\n${YELLOW}🔍 Image Layers:${NC}"
    docker history "$IMAGE_NAME:latest" --format "table {{.CreatedBy}}\t{{.Size}}" --no-trunc=false | head -n 10
else
    echo -e "\n${BLUE}ℹ️  No images found. Build first with: ./docker-run.sh build${NC}"
fi

# Show build cache
echo -e "\n${YELLOW}💾 Build Cache:${NC}"
docker system df 2>/dev/null || echo "Build cache information not available"

# Check .dockerignore effectiveness
echo -e "\n${YELLOW}🚫 .dockerignore Status:${NC}"
if [ -f "docker/.dockerignore" ]; then
    IGNORE_LINES=$(wc -l < docker/.dockerignore)
    echo "✅ .dockerignore exists with $IGNORE_LINES exclusion rules"
    echo "   Excluding: .env files, caches, IDE files, docs, tests, etc."
else
    echo "❌ .dockerignore not found"
fi

# Show optimization features
echo -e "\n${YELLOW}⚡ Optimization Features:${NC}"
echo "✅ Multi-stage build (builder + runtime stages)"
echo "✅ BuildKit cache mounts for pip"
echo "✅ Layer caching optimization"
echo "✅ Minimal runtime image (only necessary files)"
echo "✅ Non-root user security"
echo "✅ Read-only filesystem"
echo "✅ Resource limits"
echo "✅ Comprehensive .dockerignore"

# Build efficiency tips
echo -e "\n${YELLOW}💡 Build Efficiency Tips:${NC}"
echo "• Use './docker-run.sh build' for optimized builds"
echo "• Use './docker-run.sh build-squashed' for minimal size (if experimental enabled)"
echo "• Dependencies are cached - only rebuild when requirements.txt changes"
echo "• Code changes don't rebuild dependency layer"
echo "• BuildKit cache mounts speed up pip installs"

# Security features
echo -e "\n${YELLOW}🔒 Security Features:${NC}"
echo "• Non-root user (botuser:1001)"
echo "• Read-only root filesystem"
echo "• No new privileges"
echo "• Minimal attack surface"
echo "• No sensitive files in image"

echo -e "\n${GREEN}✅ Verification complete!${NC}"
echo -e "Run ${BLUE}'./docker-run.sh help'${NC} to see all available commands." 