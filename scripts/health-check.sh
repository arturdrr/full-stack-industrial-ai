#!/bin/bash
# health-check.sh - Verifica a saúde dos serviços da stack

set -euo pipefail

# ================================
# CONFIGURATION & GLOBALS
# ================================
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly LOG_DIR="$PROJECT_ROOT/logs"
readonly CONFIG_DIR="$PROJECT_ROOT/config"
readonly ENV_FILE="$PROJECT_ROOT/.env.local"

# Colors for output
readonly RED='[0;31m'
readonly GREEN='[0;32m'
readonly YELLOW='[1;33m'
readonly BLUE='[0;34m'
readonly NC='[0m' # No Color

# ================================
# LOGGING FUNCTIONS
# ================================
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN: $*${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*${NC}"
}

# ================================
# HEALTH CHECK FUNCTIONS
# ================================
check_service() {
    local service_name="$1"
    local url="$2"
    local expected_status="$3"
    local timeout="${4:-5}"

    log "Checking $service_name at $url..."
    
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$timeout" "$url")

    if [[ "$http_code" == "$expected_status" ]]; then
        log "✅ $service_name is UP (HTTP $http_code)"
        return 0
    else
        log_error "❌ $service_name is DOWN or unhealthy (HTTP $http_code)"
        return 1
    fi
}

check_docker_container() {
    local container_name="$1"
    log "Checking Docker container: $container_name..."
    if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
        log "✅ Container $container_name is running."
        return 0
    else
        log_error "❌ Container $container_name is not running."
        return 1
    fi
}

# ================================
# MAIN HEALTH CHECK EXECUTION
# ================================
main() {
    log "🚀 Starting Full-Stack Industrial AI Health Check"
    log "Timestamp: $(date)"

    local overall_status=0

    log "--- Checking Core Docker Services ---"
    check_docker_container "redis" || overall_status=1
    check_docker_container "postgres" || overall_status=1
    check_docker_container "litellm-proxy" || overall_status=1
    check_docker_container "keycloak" || overall_status=1
    check_docker_container "vault" || overall_status=1

    log "--- Checking API Endpoints ---"
    check_service "Frontend" "http://localhost:3000" "200" || overall_status=1
    check_service "AI Proxy Health" "http://localhost:8081/health" "200" || overall_status=1
    check_service "Keycloak Admin" "http://localhost:8080/auth/admin" "302" || overall_status=1 # Redirect to login
    check_service "Vault UI" "http://localhost:8200/ui" "200" || overall_status=1

    log "--- Checking Monitoring Stack ---"
    check_service "Grafana" "http://localhost:3000/api/health" "200" || overall_status=1
    check_service "Prometheus" "http://localhost:9090/-/ready" "200" || overall_status=1

    if [[ $overall_status -eq 0 ]]; then
        log "🎉 All essential services are healthy!"
    else
        log_error "⚠️ Some services are not healthy. Please check logs for details."
    fi

    return $overall_status
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    main "$@"
fi
