#!/bin/bash
# monitor-usage.sh - Monitorar uso das APIs

echo "📊 API Usage Monitoring - $(date)"
echo "================================="

# Verificar limites Grok Free
GROK_REQUESTS=$(redis-cli get "grok:daily_requests:$(date +%Y%m%d)")
echo "🚀 Grok Free Tier:"
echo "   Requests hoje: ${GROK_REQUESTS:-0}/2000"
echo "   Status: $([ ${GROK_REQUESTS:-0} -lt 1800 ] && echo "✅ OK" || echo "⚠️ Próximo do limite")"

# Verificar custos Gemini
GEMINI_COST=$(redis-cli get "gemini:daily_cost:$(date +%Y%m%d)")
echo ""
echo "🧠 Gemini Pro:"
echo "   Custo hoje: $${GEMINI_COST:-0.00}/$12.00"
echo "   Status: $([ $(echo "${GEMINI_COST:-0} < 10" | bc -l) -eq 1 ] && echo "✅ OK" || echo "⚠️ Alto custo")"

# Recomendações automáticas
echo ""
echo "💡 Recomendações:"
if [ ${GROK_REQUESTS:-0} -gt 1500 ]; then
    echo "   - Usar mais Gemini Flash para queries médias"
fi

if [ $(echo "${GEMINI_COST:-0} > 8" | bc -l) -eq 1 ]; then
    echo "   - Priorizar Grok para queries simples"
    echo "   - Implementar cache mais agressivo"
fi

echo ""
echo "📈 Próxima otimização em: $((2000 - ${GROK_REQUESTS:-0})) requests Grok disponíveis"
