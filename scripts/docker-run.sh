#!/bin/bash

# Discord Bot Framework - Docker Management Script
# Optimized for caching, layer squashing, and minimal image size

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="discord-bot-framework"
CONTAINER_NAME="discord-bot-framework"
DOCKERFILE_PATH="docker/Dockerfile"
COMPOSE_FILE="docker/docker-compose.yml"

# Enable Docker BuildKit for advanced caching and multi-stage builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if .env file exists
check_env_file() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found!"
        echo "Please create a .env file with your Discord token:"
        echo "DISCORD_TOKEN=your_discord_bot_token_here"
        exit 1
    fi
}

# Function to build Docker image with optimizations
build_image() {
    print_status "Building Discord bot Docker image with BuildKit optimizations..."
    
    # Build with BuildKit cache mounts and multi-stage optimization
    docker build \
        --file "$DOCKERFILE_PATH" \
        --tag "$IMAGE_NAME:latest" \
        --build-arg BUILDKIT_INLINE_CACHE=1 \
        --cache-from "$IMAGE_NAME:latest" \
        --progress=plain \
        .
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully!"
        
        # Show image size
        IMAGE_SIZE=$(docker images "$IMAGE_NAME:latest" --format "table {{.Size}}" | tail -n 1)
        print_status "Final image size: $IMAGE_SIZE"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Function to build with layer squashing (requires experimental features)
build_squashed() {
    print_status "Building with layer squashing for minimal image size..."
    
    # Check if experimental features are enabled
    if docker version --format '{{.Server.Experimental}}' | grep -q "true"; then
        docker build \
            --file "$DOCKERFILE_PATH" \
            --tag "$IMAGE_NAME:squashed" \
            --squash \
            --build-arg BUILDKIT_INLINE_CACHE=1 \
            --progress=plain \
            .
        
        if [ $? -eq 0 ]; then
            print_success "Squashed image built successfully!"
            
            # Compare sizes
            NORMAL_SIZE=$(docker images "$IMAGE_NAME:latest" --format "{{.Size}}" | head -n 1)
            SQUASHED_SIZE=$(docker images "$IMAGE_NAME:squashed" --format "{{.Size}}" | head -n 1)
            
            print_status "Normal image size: $NORMAL_SIZE"
            print_status "Squashed image size: $SQUASHED_SIZE"
        else
            print_error "Failed to build squashed image"
        fi
    else
        print_warning "Docker experimental features not enabled. Cannot use --squash"
        print_status "To enable: Add 'experimental: true' to daemon.json"
    fi
}

# Function to run container with optimized settings
run_container() {
    check_env_file
    
    print_status "Starting Discord bot container..."
    
    # Stop existing container if running
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        print_warning "Stopping existing container..."
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
    fi
    
    # Run with security and resource optimizations
    docker run -d \
        --name "$CONTAINER_NAME" \
        --env-file .env \
        --security-opt no-new-privileges:true \
        --read-only \
        --tmpfs /tmp:noexec,nosuid,size=10m \
        --memory=256m \
        --cpus=0.5 \
        --restart=unless-stopped \
        --log-driver=json-file \
        --log-opt max-size=10m \
        --log-opt max-file=3 \
        --log-opt compress=true \
        "$IMAGE_NAME:latest"
    
    if [ $? -eq 0 ]; then
        print_success "Discord bot started successfully!"
        print_status "Container name: $CONTAINER_NAME"
        print_status "Use './docker-run.sh logs' to view logs"
    else
        print_error "Failed to start container"
        exit 1
    fi
}

# Function to use docker-compose with BuildKit
compose_up() {
    check_env_file
    
    print_status "Starting with docker-compose (BuildKit enabled)..."
    
    docker-compose -f "$COMPOSE_FILE" up -d --build
    
    if [ $? -eq 0 ]; then
        print_success "Discord bot started with docker-compose!"
    else
        print_error "Failed to start with docker-compose"
        exit 1
    fi
}

# Function to show container logs
show_logs() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        print_status "Showing logs for $CONTAINER_NAME..."
        docker logs -f "$CONTAINER_NAME"
    else
        print_error "Container $CONTAINER_NAME is not running"
        exit 1
    fi
}

# Function to show container status
show_status() {
    print_status "Container Status:"
    docker ps -a --filter name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"
    
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        echo ""
        print_status "Resource Usage:"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" "$CONTAINER_NAME"
        
        echo ""
        print_status "Health Status:"
        docker inspect "$CONTAINER_NAME" --format='{{.State.Health.Status}}'
    fi
}

# Function to stop container
stop_container() {
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        print_status "Stopping $CONTAINER_NAME..."
        docker stop "$CONTAINER_NAME" >/dev/null
        print_success "Container stopped"
    else
        print_warning "Container $CONTAINER_NAME is not running"
    fi
}

# Function to restart container
restart_container() {
    print_status "Restarting $CONTAINER_NAME..."
    stop_container
    sleep 2
    run_container
}

# Function to clean up containers and images
cleanup() {
    print_status "Cleaning up Docker resources..."
    
    # Stop and remove container
    if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1
        print_status "Container removed"
    fi
    
    # Remove images
    if docker images -q "$IMAGE_NAME" | grep -q .; then
        docker rmi $(docker images -q "$IMAGE_NAME") >/dev/null 2>&1
        print_status "Images removed"
    fi
    
    # Prune build cache
    docker builder prune -f >/dev/null 2>&1
    print_status "Build cache cleaned"
    
    print_success "Cleanup completed"
}

# Function to show help
show_help() {
    echo "Discord Bot Framework - Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build          Build Docker image with BuildKit optimizations"
    echo "  build-squashed Build image with layer squashing (requires experimental)"
    echo "  run            Start bot container with optimized settings"
    echo "  compose        Start with docker-compose (recommended)"
    echo "  stop           Stop the bot container"
    echo "  restart        Restart the bot container"
    echo "  logs           Show container logs (follow mode)"
    echo "  status         Show container status and resource usage"
    echo "  cleanup        Remove containers, images, and build cache"
    echo "  help           Show this help message"
    echo ""
    echo "BuildKit Features:"
    echo "  - Multi-stage builds for smaller images"
    echo "  - Build cache mounts for faster rebuilds"
    echo "  - Layer squashing for minimal size (experimental)"
    echo "  - Optimized Dockerfile for production"
    echo ""
    echo "Examples:"
    echo "  $0 build                 # Build optimized image"
    echo "  $0 compose               # Start with docker-compose"
    echo "  $0 logs                  # View live logs"
    echo "  $0 build-squashed        # Build minimal size image"
}

# Main script logic
case "$1" in
    "build")
        build_image
        ;;
    "build-squashed")
        build_image
        build_squashed
        ;;
    "run")
        run_container
        ;;
    "compose")
        compose_up
        ;;
    "stop")
        stop_container
        ;;
    "restart")
        restart_container
        ;;
    "logs")
        show_logs
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    "")
        # Default action: build and run with compose
        print_status "No command specified. Building and starting with docker-compose..."
        compose_up
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' to see available commands"
                exit 1
        ;;
esac 