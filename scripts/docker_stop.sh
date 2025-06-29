#!/bin/bash

# Discord Bot Framework - Docker Stop Script
# This script stops all running Discord bot containers

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${RED}"
    echo "🛑 Discord Bot Framework - Stop Server"
    echo "======================================"
    echo -e "${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_warning "docker-compose not found, using 'docker compose' instead"
        DOCKER_COMPOSE_CMD="docker compose"
    else
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
}

# Check if containers are running
check_containers() {
    print_info "Checking for running Discord bot containers..."
    
    # Check docker-compose containers
    if $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml ps | grep -q "discord-bot"; then
        COMPOSE_RUNNING=true
        print_info "Found docker-compose containers running"
    else
        COMPOSE_RUNNING=false
    fi
    
    # Check for standalone containers
    if docker ps | grep -q "discord-bot"; then
        STANDALONE_RUNNING=true
        print_info "Found standalone containers running"
    else
        STANDALONE_RUNNING=false
    fi
    
    # Check development containers
    if docker ps | grep -q "discord-bot-dev"; then
        DEV_RUNNING=true
        print_info "Found development containers running"
    else
        DEV_RUNNING=false
    fi
}

# Stop docker-compose containers
stop_compose_containers() {
    if [ "$COMPOSE_RUNNING" = true ]; then
        print_info "Stopping docker-compose containers..."
        
        if $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml down; then
            print_success "Docker-compose containers stopped"
        else
            print_error "Failed to stop docker-compose containers"
        fi
    fi
}

# Stop development containers
stop_dev_containers() {
    if [ "$DEV_RUNNING" = true ]; then
        print_info "Stopping development containers..."
        
        if docker-compose -f docker/docker-compose.dev.yml down 2>/dev/null; then
            print_success "Development containers stopped"
        else
            print_warning "Could not stop development containers (may not exist)"
        fi
    fi
}

# Stop standalone containers
stop_standalone_containers() {
    if [ "$STANDALONE_RUNNING" = true ]; then
        print_info "Stopping standalone Discord bot containers..."
        
        # Stop containers with discord-bot in name
        docker ps --format "table {{.Names}}" | grep discord-bot | while read container; do
            if [ -n "$container" ]; then
                print_info "Stopping container: $container"
                docker stop "$container" && docker rm "$container"
            fi
        done
        
        print_success "Standalone containers stopped"
    fi
}

# Main stop function
stop_all_containers() {
    print_header
    check_docker
    check_containers
    
    if [ "$COMPOSE_RUNNING" = false ] && [ "$STANDALONE_RUNNING" = false ] && [ "$DEV_RUNNING" = false ]; then
        print_warning "No Discord bot containers are currently running"
        exit 0
    fi
    
    echo
    print_info "Stopping all Discord bot containers..."
    echo
    
    # Stop all types of containers
    stop_compose_containers
    stop_dev_containers
    stop_standalone_containers
    
    echo
    print_success "All Discord bot containers have been stopped!"
    
    # Show final status
    echo
    print_info "Final container status:"
    if docker ps | grep -q discord; then
        docker ps | grep discord
    else
        echo "No Discord bot containers running ✅"
    fi
}

# Force stop (kill containers)
force_stop() {
    print_header
    check_docker
    
    print_warning "Force stopping ALL Discord bot containers..."
    
    # Kill all containers with discord-bot in name
    docker ps --format "table {{.Names}}" | grep discord-bot | while read container; do
        if [ -n "$container" ]; then
            print_info "Force killing container: $container"
            docker kill "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done
    
    # Also try docker-compose
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml kill 2>/dev/null || true
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml down 2>/dev/null || true
    
    print_success "All containers force stopped!"
}

# Show help
show_help() {
    echo "Discord Bot Framework - Docker Stop Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  (no args)   Stop all Discord bot containers gracefully"
    echo "  --force     Force kill all containers immediately"
    echo "  --help      Show this help message"
    echo
    echo "This script will stop:"
    echo "  • Docker-compose containers"
    echo "  • Development containers"
    echo "  • Standalone containers"
    echo
    echo "Examples:"
    echo "  $0           # Graceful stop"
    echo "  $0 --force   # Force stop"
}

# Parse command line arguments
case "${1:-}" in
    --force)
        force_stop
        ;;
    --help)
        show_help
        ;;
    "")
        stop_all_containers
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac 