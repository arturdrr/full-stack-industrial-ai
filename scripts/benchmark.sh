#!/bin/bash
# Performance Benchmarking Suite

echo "🏃‍♂️ Running AI Routing Performance Benchmarks..."

# Test simple queries (should use Grok free)
echo "📊 Testing simple queries routing..."
ab -n 1000 -c 10 -p benchmark/simple-query.json \
  -T 'application/json' \
  http://localhost:8081/v1/chat/completions

# Test complex queries (should use Gemini Pro)  
echo "📊 Testing complex queries routing..."
ab -n 500 -c 5 -p benchmark/complex-query.json \
  -T 'application/json' \
  http://localhost:8081/v1/chat/completions

# Latency measurement
echo "⏱️ Measuring latency distribution..."
./scripts/latency-test.sh

# Generate report
echo "📄 Generating performance report..."
python scripts/generate-benchmark-report.py
