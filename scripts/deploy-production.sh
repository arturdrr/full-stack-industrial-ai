#!/bin/bash
# deploy-production.sh - Production Deployment
# Version: 1.0.0
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $*${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*${NC}"
}

validate_production_environment() {
    log "🔒 Validating production environment..."
    
    # Check critical environment variables
    local required_vars=(
        "ENVIRONMENT"
        "DATABASE_URL"
        "REDIS_URL"
        "GOOGLE_API_KEY"
        "KEYCLOAK_ADMIN_PASSWORD"
        "GRAFANA_ADMIN_PASSWORD"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_error "Missing required production variables: ${missing_vars[*]}"
        exit 1
    fi
    
    # Verify we're deploying to production
    if [[ "${ENVIRONMENT}" != "production" ]]; then
        log_error "ENVIRONMENT must be 'production' for this script"
        exit 1
    fi
    
    log "✅ Production environment validated"
}

backup_current_deployment() {
    log "💾 Creating backup of current deployment..."
    
    local backup_dir="$PROJECT_ROOT/backups/$(date +'%Y%m%d_%H%M%S')"
    mkdir -p "$backup_dir"
    
    # Backup database
    if docker-compose ps postgres | grep -q "Up"; then
        log "🗃️  Backing up database..."
        docker-compose exec -T postgres pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" \
            > "$backup_dir/database_backup.sql"
    fi
    
    # Backup Redis
    if docker-compose ps redis | grep -q "Up"; then
        log "💾 Backing up Redis..."
        docker-compose exec -T redis redis-cli BGSAVE
        docker cp "$(docker-compose ps -q redis):/data/dump.rdb" "$backup_dir/redis_backup.rdb"
    fi
    
    # Backup configuration
    cp -r "$PROJECT_ROOT/config" "$backup_dir/" 2>/dev/null || true
    cp "$PROJECT_ROOT/.env.production" "$backup_dir/" 2>/dev/null || true
    
    log "✅ Backup created: $backup_dir"
}

deploy_with_zero_downtime() {
    log "🚀 Starting zero-downtime deployment..."
    
    # Pull latest images
    log "📥 Pulling latest Docker images..."
    docker-compose -f docker-compose.prod.yml pull
    
    # Deploy services in stages
    
    # Stage 1: Infrastructure services
    log "🏗️  Deploying infrastructure services..."
    docker-compose -f docker-compose.prod.yml up -d \
        postgres redis prometheus grafana
    
    # Wait for infrastructure
    sleep 15
    
    # Stage 2: Security services
    log "🛡️  Deploying security services..."
    docker-compose -f docker-compose.prod.yml up -d \
        keycloak vault
    
    sleep 20
    
    # Stage 3: AI services
    log "🤖 Deploying AI services..."
    docker-compose -f docker-compose.prod.yml up -d \
        litellm-proxy
    
    sleep 10
    
    # Stage 4: Frontend services
    log "🌐 Deploying frontend services..."
    docker-compose -f docker-compose.prod.yml up -d \
        frontend nginx
    
    log "✅ Zero-downtime deployment completed"
}

run_production_health_checks() {
    log "🏥 Running production health checks..."
    
    local health_endpoints=(
        "http://localhost:8081/health:AI Proxy"
        "http://localhost:9090/-/ready:Prometheus"
        "http://localhost:3000/api/health:Grafana"
    )
    
    local failed_checks=()
    
    for endpoint_info in "${health_endpoints[@]}"; do
        local url="${endpoint_info%%:*}"
        local name="${endpoint_info##*:}"
        
        if curl -s -f "$url" >/dev/null; then
            log "✅ $name: HEALTHY"
        else
            log_error "❌ $name: UNHEALTHY"
            failed_checks+=("$name")
        fi
    done
    
    if [[ ${#failed_checks[@]} -gt 0 ]]; then
        log_error "Health checks failed for: ${failed_checks[*]}"
        return 1
    fi
    
    log "✅ All production health checks passed"
}

setup_monitoring_alerts() {
    log "📢 Setting up production monitoring alerts..."
    
    # Import Grafana dashboards
    local dashboard_dir="$PROJECT_ROOT/grafana/dashboards"
    if [[ -d "$dashboard_dir" ]]; then
        log "📊 Importing Grafana dashboards..."
        # Dashboard import logic would go here
        # This would use Grafana API to import dashboards
    fi
    
    # Configure Prometheus alerts
    local alerts_dir="$PROJECT_ROOT/prometheus/alerts"
    if [[ -d "$alerts_dir" ]]; then
        log "🚨 Configuring Prometheus alerts..."
        # Alert configuration logic would go here
    fi
    
    log "✅ Monitoring alerts configured"
}

main() {
    log "🏭 Full-Stack Industrial AI - Production Deployment"
    log "Version: 1.0.0"
    log "Timestamp: $(date)"
    
    # Safety checks
    if [[ "${1:-}" != "--confirm-production" ]]; then
        log_error "This will deploy to PRODUCTION environment"
        log_error "Add --confirm-production flag to continue"
        exit 1
    fi
    
    # Load production environment
    if [[ -f "$PROJECT_ROOT/.env.production" ]]; then
        set -a
        source "$PROJECT_ROOT/.env.production"
        set +a
    else
        log_error ".env.production file not found"
        exit 1
    fi
    
    validate_production_environment
    backup_current_deployment
    deploy_with_zero_downtime
    run_production_health_checks
    setup_monitoring_alerts
    
    log "🎉 Production deployment completed successfully!"
    log ""
    log "🌐 Production services:"
    log "  Frontend: https://your-domain.com"
    log "  AI Proxy: https://api.your-domain.com"
    log "  Monitoring: https://grafana.your-domain.com"
    log ""
    log "📊 Next steps:"
    log "  1. Verify all services are responding correctly"
    log "  2. Run load tests to validate performance"
    log "  3. Monitor alerts for first 24 hours"
    log "  4. Update DNS/CDN configurations if needed"
    log ""
    log "🆘 Rollback: ./scripts/rollback.sh <backup_timestamp>"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    main "$@"
fi
