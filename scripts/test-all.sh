#!/bin/bash
echo "🧪 Running Full Test Suite..."

# Unit tests
echo "1/6 🔬 Unit Tests..."
python -m pytest tests/unit/ -v --cov=src/

# Integration tests  
echo "2/6 🔗 Integration Tests..."
./scripts/test-integration.sh

# API tests
echo "3/6 🔌 API Tests..."
./scripts/test-apis.sh

# Security tests
echo "4/6 🔒 Security Tests..."
./scripts/test-security.sh

# Performance tests
echo "5/6 ⚡ Performance Tests..."
./scripts/benchmark.sh

# End-to-end tests
echo "6/6 🎯 E2E Tests..."
./scripts/test-e2e.sh

echo "✅ All tests completed!"
echo "📊 Coverage report: ./coverage/index.html"
echo "📈 Performance report: ./benchmarks/latest.html"
