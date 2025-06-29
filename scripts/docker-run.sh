#!/bin/bash

# Discord Bot Framework - Docker Run Script
# This script handles Docker operations for the Discord bot

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
    echo -e "${BLUE}"
    echo "🐳 Discord Bot Framework - Docker"
    echo "================================"
    echo -e "${NC}"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_warning "docker-compose not found, using 'docker compose' instead"
        DOCKER_COMPOSE_CMD="docker compose"
    else
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
    
    print_success "Docker is available"
}

# Check if .env file exists
check_env_file() {
    if [ ! -f ".env" ]; then
        print_warning ".env file not found"
        echo
        print_info "Creating .env file for Docker..."
        
        echo "Please enter your Discord bot token:"
        echo "(You can get this from https://discord.com/developers/applications)"
        echo -n "Discord Bot Token: "
        read -r discord_token
        
        if [ -z "$discord_token" ]; then
            print_error "No token provided!"
            exit 1
        fi
        
        # Create .env file
        cat > .env << EOF
# Discord Bot Framework Environment Variables
# Generated on: $(date)

# Your Discord bot token
DISCORD_TOKEN=$discord_token

# Optional: Add other environment variables below
EOF
        
        print_success ".env file created successfully!"
    else
        print_success ".env file found"
    fi
}

# Build Docker image
build_image() {
    print_info "Building Docker image..."
    
    if $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml build; then
        print_success "Docker image built successfully!"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Run with docker-compose
run_with_compose() {
    print_info "Starting Discord bot with docker-compose..."
    
    # Source .env file to make variables available
    set -a
    source .env
    set +a
    
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml up -d
    
    if [ $? -eq 0 ]; then
        print_success "Discord bot is running in the background!"
        echo
        print_info "Useful commands:"
        echo "  View logs: $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml logs -f"
        echo "  Stop bot:  $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml down"
        echo "  Restart:   $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml restart"
    else
        print_error "Failed to start Discord bot"
        exit 1
    fi
}

# Stop containers
stop_containers() {
    print_info "Stopping Discord bot containers..."
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml down
    print_success "Containers stopped"
}

# View logs
view_logs() {
    print_info "Showing Discord bot logs (Ctrl+C to exit)..."
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml logs -f
}

# Build and run
build_and_run() {
    build_image
    echo
    run_with_compose
}

# Show status
show_status() {
    print_info "Container status:"
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml ps
}

# Clean up
cleanup() {
    print_info "Cleaning up Docker resources..."
    $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml down -v --remove-orphans
    
    # Remove image
    echo -n "Remove Docker image as well? (y/N): "
    read -r remove_image
    
    if [ "$remove_image" = "y" ] || [ "$remove_image" = "Y" ]; then
        docker rmi discord_bot_server_discord-bot 2>/dev/null || true
        print_success "Docker image removed"
    fi
    
    print_success "Cleanup completed"
}

# Show help
show_help() {
    echo "Discord Bot Framework - Docker Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  build       Build the Docker image"
    echo "  run         Start the bot with docker-compose"
    echo "  start       Build and run (default)"
    echo "  stop        Stop the bot containers" 
    echo "  restart     Restart the bot"
    echo "  logs        View bot logs"
    echo "  status      Show container status"
    echo "  cleanup     Stop and remove containers/images"
    echo "  -h, --help  Show this help message"
    echo
    echo "Examples:"
    echo "  $0           # Build and run"
    echo "  $0 build     # Just build image"
    echo "  $0 logs      # View logs"
    echo "  $0 stop      # Stop containers"
}

# Main execution
main() {
    print_header
    check_docker
    check_env_file
    echo
}

# Parse command line arguments
case "${1:-start}" in
    build)
        main
        build_image
        ;;
    run)
        main
        run_with_compose
        ;;
    start|"")
        main
        build_and_run
        ;;
    stop)
        print_header
        check_docker
        stop_containers
        ;;
    restart)
        print_header
        check_docker
        print_info "Restarting Discord bot..."
        $DOCKER_COMPOSE_CMD -f docker/docker-compose.yml restart
        print_success "Bot restarted"
        ;;
    logs)
        check_docker
        view_logs
        ;;
    status)
        check_docker
        show_status
        ;;
    cleanup)
        print_header
        check_docker
        cleanup
        ;;
    -h|--help)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac 