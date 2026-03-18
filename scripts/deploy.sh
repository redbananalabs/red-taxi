#!/usr/bin/env bash
# =============================================================================
# Red Taxi Platform - Manual Deployment Script
# Usage: ./scripts/deploy.sh [--skip-build] [--skip-migrations] [--env <file>]
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/docker/docker-compose.prod.yml"
ENV_FILE="$PROJECT_ROOT/docker/.env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Parse arguments
SKIP_BUILD=false
SKIP_MIGRATIONS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-build)      SKIP_BUILD=true; shift ;;
        --skip-migrations) SKIP_MIGRATIONS=true; shift ;;
        --env)             ENV_FILE="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--skip-build] [--skip-migrations] [--env <file>]"
            exit 0
            ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done

# Validate environment file
if [[ ! -f "$ENV_FILE" ]]; then
    log_error "Environment file not found: $ENV_FILE"
    log_warn "Copy docker/.env.template to docker/.env and fill in values."
    exit 1
fi

log_info "Starting Red Taxi deployment..."
log_info "Project root: $PROJECT_ROOT"
log_info "Compose file: $COMPOSE_FILE"
log_info "Env file: $ENV_FILE"

# Step 1: Pull latest code
log_info "Pulling latest code from git..."
cd "$PROJECT_ROOT"
git pull --ff-only origin main

# Step 2: Build .NET projects
if [[ "$SKIP_BUILD" == false ]]; then
    log_info "Restoring .NET dependencies..."
    dotnet restore src/RedTaxi.sln

    log_info "Building .NET solution..."
    dotnet build src/RedTaxi.sln -c Release --no-restore

    log_info "Publishing API..."
    dotnet publish src/RedTaxi.API -c Release -o publish/api --no-build

    log_info "Publishing Blazor..."
    dotnet publish src/RedTaxi.Blazor -c Release -o publish/blazor --no-build
else
    log_warn "Skipping .NET build (--skip-build)"
fi

# Step 3: Build Docker images and restart services
log_info "Building Docker images..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" build

log_info "Restarting services..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --remove-orphans

# Step 4: Wait for SQL Server to be ready
log_info "Waiting for SQL Server to be ready..."
RETRIES=30
until docker exec redtaxi-sql /opt/mssql-tools18/bin/sqlcmd \
    -S localhost -U sa -P "${SA_PASSWORD:-}" -Q "SELECT 1" -C -b -o /dev/null 2>/dev/null; do
    RETRIES=$((RETRIES - 1))
    if [[ $RETRIES -le 0 ]]; then
        log_error "SQL Server did not start in time."
        exit 1
    fi
    sleep 2
done
log_info "SQL Server is ready."

# Step 5: Run EF Core migrations
if [[ "$SKIP_MIGRATIONS" == false ]]; then
    log_info "Running EF Core migrations..."
    if command -v dotnet-ef &>/dev/null || dotnet tool list -g | grep -q "dotnet-ef"; then
        dotnet ef database update \
            --project src/RedTaxi.Infrastructure \
            --startup-project src/RedTaxi.API \
            --connection "$(grep SQL_CONNECTION_STRING "$ENV_FILE" | cut -d= -f2-)"
        log_info "Migrations applied successfully."
    else
        log_warn "dotnet-ef tool not found. Install with: dotnet tool install -g dotnet-ef"
        log_warn "Skipping migrations."
    fi
else
    log_warn "Skipping migrations (--skip-migrations)"
fi

# Step 6: Clean up old Docker images
log_info "Pruning unused Docker images..."
docker image prune -f

# Step 7: Health checks
log_info "Running health checks..."
sleep 5

API_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" http://localhost:5001/health 2>/dev/null || echo "000")
BLAZOR_STATUS=$(curl -sf -o /dev/null -w "%{http_code}" http://localhost:5002/health 2>/dev/null || echo "000")

if [[ "$API_STATUS" == "200" ]]; then
    log_info "API health check: PASSED (HTTP $API_STATUS)"
else
    log_error "API health check: FAILED (HTTP $API_STATUS)"
fi

if [[ "$BLAZOR_STATUS" == "200" ]]; then
    log_info "Blazor health check: PASSED (HTTP $BLAZOR_STATUS)"
else
    log_error "Blazor health check: FAILED (HTTP $BLAZOR_STATUS)"
fi

# Summary
echo ""
log_info "========================================="
log_info "  Deployment complete!"
log_info "  API:    http://localhost:5001"
log_info "  Blazor: http://localhost:5002"
log_info "========================================="

# Show running containers
docker compose -f "$COMPOSE_FILE" ps
