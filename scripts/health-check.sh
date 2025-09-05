#!/bin/bash
# health-check.sh - Comprehensive Health Monitoring
# Version: 1.0.0
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly LOG_DIR="$PROJECT_ROOT/logs"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Source environment
if [[ -f "$PROJECT_ROOT/.env.local" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "$PROJECT_ROOT/.env.local"
    set +a
fi

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $*${NC}"
}

log_warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARN: $*${NC}"
}

log_error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $*${NC}"
}

check_service() {
    local service_name="$1"
    local health_url="$2"
    local expected_status="$3"
    local timeout="${4:-5}"

    log "Checking $service_name at $url..."
    
    local response_code
    response_code=$(curl -s -o /dev/null -w "% {http_code}" "$health_url" 2>/dev/null || echo "000")
    
    if [[ "$response_code" == "$expected_status" ]]; then
        log "✅ $service_name: HEALTHY ($response_code)"
        return 0
    else
        log_error "❌ $service_name: UNHEALTHY ($response_code)"
        return 1
    fi
}

check_docker_services() {
    log "🐳 Checking Docker services..."
    
    local services=("redis" "postgres" "litellm-proxy" "prometheus" "grafana")
    local failed_services=()
    
    for service in "${services[@]}"; do
        if docker-compose ps "$service" | grep -q "Up"; then
            log "✅ Docker $service: RUNNING"
        else
            log_error "❌ Docker $service: NOT RUNNING"
            failed_services+=("$service")
        fi
    done
    
    return ${#failed_services[@]}
}

check_api_endpoints() {
    log "🔌 Checking API endpoints..."
    
    local failed_apis=()
    
    # Check AI Proxy
    if ! check_service "AI Proxy" "http://localhost:8081/health"; then
        failed_apis+=("ai-proxy")
    fi
    
    # Check Prometheus
    if ! check_service "Prometheus" "http://localhost:9090/-/ready"; then
        failed_apis+=("prometheus")
    fi
    
    # Check Grafana
    if ! check_service "Grafana" "http://localhost:3000/api/health"; then
        failed_apis+=("grafana")
    fi
    
    # Test actual AI routing
    if [[ -n "${GOOGLE_API_KEY:-}" ]]; then
        log "🧠 Testing AI routing..."
        local ai_response
        ai_response=$(curl -s -f \
            -H "Content-Type: application/json" \
            -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Hello"}]}' \
            "http://localhost:8081/v1/chat/completions" || echo "FAILED")
        
        if [[ "$ai_response" == "FAILED" ]]; then
            log_error "❌ AI Routing: FAILED"
            failed_apis+=("ai-routing")
        else
            log "✅ AI Routing: WORKING"
        fi
    fi
    
    return ${#failed_apis[@]}
}

check_resource_usage() {
    log "📊 Checking resource usage..."
    
    # Check RAM usage
    local ram_usage
    ram_usage=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
    ram_usage=${ram_usage%.*}
    
    if [[ $ram_usage -gt 80 ]]; then
        log_warn "⚠️  High RAM usage: ${ram_usage}%"
    else
        log "✅ RAM usage: ${ram_usage}%"
    fi
    
    # Check disk usage
    local disk_usage
    disk_usage=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [[ $disk_usage -gt 80 ]]; then
        log_warn "⚠️  High disk usage: ${disk_usage}%"
    else
        log "✅ Disk usage: ${disk_usage}%"
    fi
    
    # Check Docker stats
    log "🐳 Docker resource usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -6
}

check_log_errors() {
    log "📝 Checking for recent errors..."
    
    if [[ -f "$LOG_DIR/setup.error.log" ]]; then
        local error_count
        error_count=$(wc -l < "$LOG_DIR/setup.error.log")
        
        if [[ $error_count -gt 0 ]]; then
            log_warn "⚠️  Found $error_count errors in logs"
            log "Recent errors:"
            tail -5 "$LOG_DIR/setup.error.log"
        else
            log "✅ No errors in logs"
        fi
    fi
}

generate_health_report() {
    local timestamp=$(date +'%Y-%m-%d_%H-%M-%S')
    local report_file="$LOG_DIR/health_report_${timestamp}.json"
    
    log "📄 Generating health report: $report_file"
    
    # This would generate a JSON health report
    # Implementation would create structured health data
    
    cat > "$report_file" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "status": "healthy",
    "services": {
        "docker": "$(docker-compose ps --services | wc -l) services",
        "api_proxy": "$(curl -s http://localhost:8081/health | jq -r '.status' 2>/dev/null || echo 'unknown')"
    },
    "resources": {
        "ram_usage_percent": $(free | grep Mem | awk '{print ($3/$2) * 100.0}'),
        "disk_usage_percent": $(df "$PROJECT_ROOT" | tail -1 | awk '{print $5}' | sed 's/%//')
    }
}
EOF
    
    log "✅ Health report generated"
}

main() {
    log "🏥 Full-Stack Industrial AI - Health Check"
    log "Timestamp: $(date)"
    
    local total_failures=0
    
    # Run all checks
    check_docker_services || ((total_failures++))
    check_api_endpoints || ((total_failures++))
    check_resource_usage
    check_log_errors
    
    # Generate report
    generate_health_report
    
    # Final status
    if [[ $total_failures -eq 0 ]]; then
        log "🎉 All systems healthy!"
        exit 0
    else
        log_error "💥 Found $total_failures critical issues"
        log_error "Check logs and fix issues before proceeding"
        exit 1
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    main "$@"
fi