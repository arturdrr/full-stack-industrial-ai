#!/bin/bash
# test-apis.sh - Comprehensive API Testing
# Version: 1.0.0
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
readonly RED='\[\033[0;31m\]'
readonly GREEN='\[\033[0;32m\]'
readonly YELLOW='\[\033[1;33m\]'
readonly NC='\[\033[0m\]'

# Source environment
if [[ -f "$PROJECT_ROOT/.env.local" ]]; then
    set -a
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

test_gemini_api() {
    log "🧪 Testing Gemini API..."
    
    if [[ -z "${GOOGLE_API_KEY:-}" ]]; then
        log_error "GOOGLE_API_KEY not set"
        return 1
    fi
    
    local response
    response=$(curl -s \
        -H "Content-Type: application/json" \
        -d '{"contents":[{"parts":[{"text":"Hello, this is a test"}]}]}' \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GOOGLE_API_KEY}")
    
    if echo "$response" | jq -e '.candidates.content.parts.text' >/dev/null 2>&1; then
        log "✅ Gemini API: WORKING"
        local text_response
        text_response=$(echo "$response" | jq -r '.candidates.content.parts.text')
        log "📝 Response: ${text_response:0:50}..."
        return 0
    else
        log_error "❌ Gemini API: FAILED"
        echo "$response" | jq '.' || echo "$response"
        return 1
    fi
}

test_grok_api() {
    log "🧪 Testing Grok API..."
    
    if [[ -z "${GROK_API_KEY:-}" ]]; then
        log_warn "GROK_API_KEY not set (optional)"
        return 0
    fi
    
    local response
    response=$(curl -s \
        -H "Authorization: Bearer ${GROK_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"messages":[{"role":"user","content":"Hello, this is a test"}],"model":"grok-beta"}' \
        "https://api.x.ai/v1/chat/completions")
    
    if echo "$response" | jq -e '.choices.message.content' >/dev/null 2>&1; then
        log "✅ Grok API: WORKING"
        local content
        content=$(echo "$response" | jq -r '.choices.message.content')
        log "📝 Response: ${content:0:50}..."
        return 0
    else
        log_warn "⚠️  Grok API: FAILED"
        echo "$response" | jq '.' || echo "$response"
        return 1
    fi
}

test_proxy_routing() {
    log "🔄 Testing proxy routing..."
    
    # Test simple routing
    local response
    response=$(curl -s \
        -H "Content-Type: application/json" \
        -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Test routing"}]}' \
        "http://localhost:8081/v1/chat/completions")
    
    if echo "$response" | jq -e '.choices.message.content' >/dev/null 2>&1; then
        log "✅ Proxy Routing: WORKING"
        local provider_used
        provider_used=$(echo "$response" | jq -r '.provider_used // "unknown"')
        log "📡 Provider used: $provider_used"
        return 0
    else
        log_error "❌ Proxy Routing: FAILED"
        echo "$response" | jq '.' || echo "$response"
        return 1
    fi
}

test_routing_intelligence() {
    log "🧠 Testing intelligent routing..."
    
    # Test complex query (should route to Gemini Pro)
    local complex_response
    complex_response=$(curl -s \
        -H "Content-Type: application/json" \
        -d '{"model":"gpt-4","messages":[{"role":"user","content":"Please analyze this complex data and provide detailed insights about market trends, consumer behavior, and strategic recommendations for the next quarter."}]}' \
        "http://localhost:8081/v1/chat/completions")
    
    local complex_provider
    complex_provider=$(echo "$complex_response" | jq -r '.provider_used // "unknown"')
    log "📊 Complex query routed to: $complex_provider"
    
    # Test simple query (should route to Grok or Gemini Flash)
    local simple_response
    simple_response=$(curl -s \
        -H "Content-Type: application/json" \
        -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"What is 2+2?"}]}' \
        "http://localhost:8081/v1/chat/completions")
    
    local simple_provider
    simple_provider=$(echo "$simple_response" | jq -r '.provider_used // "unknown"')
    log "🔢 Simple query routed to: $simple_provider"
    
    # Verify intelligent routing
    if [[ "$complex_provider" != "$simple_provider" ]]; then
        log "✅ Intelligent routing: WORKING"
        log "🎯 Different providers for different complexity levels"
    else
        log_warn "⚠️  Routing may not be optimally intelligent"
    fi
}

benchmark_performance() {
    log "⚡ Running performance benchmarks..."
    
    local start_time end_time duration
    
    # Benchmark simple query
    start_time=$(date +%s%3N)
    curl -s \
        -H "Content-Type: application/json" \
        -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Hello"}]}' \
        "http://localhost:8081/v1/chat/completions" >/dev/null
    end_time=$(date +%s%3N)
    duration=$((end_time - start_time))
    
    log "⏱️  Simple query latency: ${duration}ms"
    
    if [[ $duration -lt 2000 ]]; then
        log "✅ Latency: GOOD"
    elif [[ $duration -lt 5000 ]]; then
        log_warn "⚠️  Latency: ACCEPTABLE"
    else
        log_error "❌ Latency: TOO HIGH"
    fi
}

main() {
    log "🧪 Full-Stack Industrial AI - API Testing Suite"
    log "Timestamp: $(date)"
    
    local total_failures=0
    
    # Test individual APIs
    test_gemini_api || ((total_failures++))
    test_grok_api
    
    # Test proxy functionality
    test_proxy_routing || ((total_failures++))
    test_routing_intelligence
    
    # Performance testing
    benchmark_performance
    
    # Final report
    if [[ $total_failures -eq 0 ]]; then
        log "🎉 All API tests passed!"
        log "🚀 System ready for production use"
    else
        log_error "💥 $total_failures critical API tests failed"
        log_error "Fix issues before using the system"
        exit 1
    fi
}

if [[ "${BASH_SOURCE}" == "${0}" ]]; then
    main "$@"
fi
