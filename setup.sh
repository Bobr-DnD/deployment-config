#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Microservice Deployment Manager${NC}"
echo "=================================="

# Function to display menu
show_menu() {
    echo ""
    echo -e "${YELLOW}Deployment Options:${NC}"
    echo "1)  Setup: Clone deployment repo with submodules"
    echo "2)  Update all submodules to latest"
    echo ""
    echo -e "${YELLOW}Backend Deployment:${NC}"
    echo "3)  Build and start backend services (gateway, api, ws)"
    echo "4)  Stop backend services"
    echo "5)  View backend logs"
    echo ""
    echo -e "${YELLOW}Frontend Deployment:${NC}"
    echo "6)  Build and start frontend"
    echo "7)  Stop frontend"
    echo "8)  View frontend logs"
    echo ""
    echo -e "${YELLOW}Full Stack:${NC}"
    echo "9)  Build and start ALL services"
    echo "10) Stop ALL services"
    echo "11) View all logs"
    echo ""
    echo -e "${YELLOW}Maintenance:${NC}"
    echo "12) Check status of all services"
    echo "13) Clean everything (containers, images, volumes)"
    echo "14) Rebuild specific service"
    echo "15) Exit"
    echo ""
    read -p "Choose an option: " choice
    
    case $choice in
        1) clone_with_submodules ;;
        2) update_submodules ;;
        3) deploy_backend ;;
        4) stop_backend ;;
        5) logs_backend ;;
        6) deploy_frontend ;;
        7) stop_frontend ;;
        8) logs_frontend ;;
        9) deploy_all ;;
        10) stop_all ;;
        11) logs_all ;;
        12) check_status ;;
        13) clean_all ;;
        14) rebuild_service ;;
        15) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" && show_menu ;;
    esac
}

# Clone with submodules
clone_with_submodules() {
    read -p "Enter your GitHub organization name: " org_name
    
    echo -e "${BLUE}Cloning deployment-config repository...${NC}"
    git clone --recursive https://github.com/${org_name}/deployment-config.git
    
    if [ $? -eq 0 ]; then
        cd deployment-config
        echo -e "${GREEN}✓ Cloned successfully${NC}"
        echo -e "${BLUE}Creating .env file from example...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo -e "${YELLOW}⚠ Don't forget to update .env with your settings${NC}"
        fi
    else
        echo -e "${RED}✗ Clone failed${NC}"
    fi
    show_menu
}

# Update all submodules
update_submodules() {
    echo -e "${BLUE}Updating all submodules...${NC}"
    git pull
    git submodule update --remote --merge
    echo -e "${GREEN}✓ All submodules updated${NC}"
    show_menu
}

# Deploy backend only
deploy_backend() {
    echo -e "${BLUE}Building and starting backend services...${NC}"
    docker-compose -f docker-compose.backend.yml up --build -d
    echo -e "${GREEN}✓ Backend services started${NC}"
    echo ""
    docker-compose -f docker-compose.backend.yml ps
    show_menu
}

# Stop backend
stop_backend() {
    echo -e "${BLUE}Stopping backend services...${NC}"
    docker-compose -f docker-compose.backend.yml down
    echo -e "${GREEN}✓ Backend services stopped${NC}"
    show_menu
}

# Logs backend
logs_backend() {
    echo -e "${BLUE}Backend Services:${NC}"
    echo "1) gateway"
    echo "2) api"
    echo "3) ws"
    echo "4) all backend"
    read -p "Choose service: " service_choice
    
    case $service_choice in
        1) docker-compose -f docker-compose.backend.yml logs -f gateway ;;
        2) docker-compose -f docker-compose.backend.yml logs -f api ;;
        3) docker-compose -f docker-compose.backend.yml logs -f ws ;;
        4) docker-compose -f docker-compose.backend.yml logs -f ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    show_menu
}

# Deploy frontend only
deploy_frontend() {
    echo -e "${BLUE}Building and starting frontend...${NC}"
    docker-compose -f docker-compose.frontend.yml up --build -d
    echo -e "${GREEN}✓ Frontend started${NC}"
    echo ""
    docker-compose -f docker-compose.frontend.yml ps
    show_menu
}

# Stop frontend
stop_frontend() {
    echo -e "${BLUE}Stopping frontend...${NC}"
    docker-compose -f docker-compose.frontend.yml down
    echo -e "${GREEN}✓ Frontend stopped${NC}"
    show_menu
}

# Logs frontend
logs_frontend() {
    docker-compose -f docker-compose.frontend.yml logs -f
    show_menu
}

# Deploy all services
deploy_all() {
    echo -e "${BLUE}Building and starting all services...${NC}"
    docker-compose up --build -d
    echo -e "${GREEN}✓ All services started${NC}"
    echo ""
    docker-compose ps
    show_menu
}

# Stop all services
stop_all() {
    echo -e "${BLUE}Stopping all services...${NC}"
    docker-compose down
    echo -e "${GREEN}✓ All services stopped${NC}"
    show_menu
}

# Logs all
logs_all() {
    docker-compose logs -f
    show_menu
}

# Check status
check_status() {
    echo -e "${BLUE}Submodule Status:${NC}"
    git submodule status
    echo ""
    echo -e "${BLUE}Running Containers:${NC}"
    docker ps --filter "name=gateway\|api\|ws\|frontend"
    echo ""
    echo -e "${BLUE}Docker Networks:${NC}"
    docker network ls | grep -E "backend-network|app-network|frontend-network"
    show_menu
}

# Clean all
clean_all() {
    echo -e "${RED}This will remove:${NC}"
    echo "  - All containers"
    echo "  - All images"
    echo "  - All volumes"
    read -p "Continue? (y/n): " confirm
    
    if [ "$confirm" = "y" ]; then
        echo -e "${BLUE}Cleaning up...${NC}"
        docker-compose down -v --rmi all
        docker-compose -f docker-compose.backend.yml down -v --rmi all 2>/dev/null
        docker-compose -f docker-compose.frontend.yml down -v --rmi all 2>/dev/null
        echo -e "${GREEN}✓ Cleanup complete${NC}"
    fi
    show_menu
}

# Rebuild specific service
rebuild_service() {
    echo -e "${BLUE}Available services:${NC}"
    echo "1) gateway"
    echo "2) api"
    echo "3) ws"
    echo "4) frontend"
    read -p "Choose service to rebuild: " service_choice
    
    case $service_choice in
        1) 
            docker-compose -f docker-compose.backend.yml up --build -d gateway
            echo -e "${GREEN}✓ Gateway rebuilt${NC}"
            ;;
        2) 
            docker-compose -f docker-compose.backend.yml up --build -d api
            echo -e "${GREEN}✓ API rebuilt${NC}"
            ;;
        3) 
            docker-compose -f docker-compose.backend.yml up --build -d ws
            echo -e "${GREEN}✓ WS rebuilt${NC}"
            ;;
        4) 
            docker-compose -f docker-compose.frontend.yml up --build -d frontend
            echo -e "${GREEN}✓ Frontend rebuilt${NC}"
            ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    show_menu
}

# Check if docker-compose files exist
if [ ! -f "docker-compose.yml" ] && [ ! -f "docker-compose.backend.yml" ]; then
    echo -e "${YELLOW}No docker-compose files found!${NC}"
    echo "It looks like you need to set up the deployment repository first."
    echo ""
    clone_with_submodules
else
    show_menu
fi