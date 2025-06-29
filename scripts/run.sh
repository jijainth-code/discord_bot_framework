#!/bin/bash

# Discord Bot Framework - Run Script
# This script handles setup and execution of the Discord bot

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
    echo "🤖 Discord Bot Framework"
    echo "========================"
    echo -e "${NC}"
}

# Check if Python is installed
check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3.8 or higher."
        exit 1
    fi
    
    # Check Python version
    python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if python3 -c 'import sys; exit(0 if sys.version_info >= (3, 8) else 1)'; then
        print_success "Python $python_version detected"
    else
        print_error "Python 3.8 or higher is required. Current version: $python_version"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    print_info "Installing dependencies..."
    
    if [ -f "requirements.txt" ]; then
        if python3 -m pip install -r requirements.txt > /dev/null 2>&1; then
            print_success "Dependencies installed successfully"
        else
            print_error "Failed to install dependencies"
            exit 1
        fi
    else
        print_warning "requirements.txt not found, skipping dependency installation"
    fi
}

# Create .env file if it doesn't exist
setup_env_file() {
    if [ ! -f ".env" ]; then
        print_warning ".env file not found"
        echo
        print_info "Creating .env file..."
        
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
        print_success ".env file already exists"
        
        # Check if token is set
        if grep -q "DISCORD_TOKEN=your_discord_bot_token_here" .env 2>/dev/null || grep -q "DISCORD_TOKEN=$" .env 2>/dev/null; then
            print_warning "Discord token appears to be empty or using placeholder"
            echo -n "Do you want to update your Discord token? (y/N): "
            read -r update_token
            
            if [ "$update_token" = "y" ] || [ "$update_token" = "Y" ]; then
                echo -n "Enter your Discord bot token: "
                read -r discord_token
                
                if [ -n "$discord_token" ]; then
                    # Update token in .env file
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        # macOS
                        sed -i '' "s/DISCORD_TOKEN=.*/DISCORD_TOKEN=$discord_token/" .env
                    else
                        # Linux
                        sed -i "s/DISCORD_TOKEN=.*/DISCORD_TOKEN=$discord_token/" .env
                    fi
                    print_success "Discord token updated!"
                fi
            fi
        fi
    fi
}

# Check if worker_functions directory exists
check_worker_functions() {
    if [ ! -d "worker_functions" ]; then
        print_warning "worker_functions directory not found, creating it..."
        mkdir -p worker_functions
        print_info "You can add your worker functions in the worker_functions/ directory"
    else
        # Count worker functions
        function_count=$(find worker_functions -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
        if [ "$function_count" -gt 0 ]; then
            print_success "$function_count worker function(s) found"
        else
            print_info "No worker functions found in worker_functions/ directory"
        fi
    fi
}

# Start the Discord bot
start_bot() {
    print_info "Starting Discord Bot..."
    echo
    
    if [ -f "src/main.py" ]; then
        python3 src/main.py
    else
        print_error "src/main.py not found!"
        exit 1
    fi
}

# Handle script interruption
cleanup() {
    echo
    print_info "Bot stopped."
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main execution
main() {
    print_header
    
    # Run setup checks
    check_python
    install_dependencies
    setup_env_file
    check_worker_functions
    
    echo
    print_success "Setup complete! Starting bot..."
    echo
    
    # Start the bot
    start_bot
}

# Show help
show_help() {
    echo "Discord Bot Framework - Run Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  --setup-only   Run setup checks only, don't start the bot"
    echo
    echo "This script will:"
    echo "  1. Check Python installation"
    echo "  2. Install dependencies"
    echo "  3. Create/verify .env file"
    echo "  4. Check worker functions"
    echo "  5. Start the Discord bot"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    --setup-only)
        print_header
        check_python
        install_dependencies
        setup_env_file
        check_worker_functions
        print_success "Setup complete!"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac 