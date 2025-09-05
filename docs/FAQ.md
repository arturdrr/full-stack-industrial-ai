# ❓ Perguntas Frequentes (FAQ)

## Uso Geral

### Como funciona o roteamento inteligente?
A IA analisa cada query considerando:
- Complexidade (tokens, contexto necessário)
- Tipo de tarefa (código, análise, conversa)  
- Custo estimado e budget disponível
- Requisitos de privacidade
- Performance histórica

### Quais APIs posso usar?
**Incluídas:**
- ✅ Gemini Pro/Flash (Google)
- ✅ Grok (X/Twitter) 
- ✅ Abacus (Enterprise)
- ✅ Ollama (Local)

**Planejadas:**
- 🔄 Claude (Anthropic)
- 🔄 GPT-4 (OpenAI)
- 🔄 Llama via Together.ai

### Como otimizar custos?
1. **Use o tier gratuito**: Grok free até 2000 requests/dia
2. **Configure cache**: Ativa por padrão, 85% similarity
3. **Monitore gastos**: Dashboards em tempo real
4. **Ajuste rate limits**: Previne gastos excessivos

## Configuração

### Como configurar API keys?
1. Copiar template
```bash
cp .env.example .env.local
```
2. Editar com suas chaves
```bash
nano .env.local
```
3. Nunca commitar .env.local!
```bash
echo ".env.local" >> .gitignore
```

### Como adicionar uma nova API?
1. Adicionar configuração em `agents_config.yaml`
2. Configurar provider em `proxy-config.yaml`  
3. Atualizar routing rules
4. Testar com `./scripts/test-apis.sh`

### Como configurar em produção?
Veja [Deployment Guide](./DEPLOYMENT.md) para:
- Docker Compose production
- Kubernetes com Helm
- Configurações de segurança
- Monitoramento e alertas

## Troubleshooting

### "API não responde"
1. Testar conectividade
```bash
curl -X POST http://localhost:8081/health
```
2. Verificar logs
```bash
docker-compose logs -f litellm-proxy
```
3. Testar API específica
```bash
./scripts/test-apis.sh
```

### "Rate limit exceeded"
- **Grok**: 2000/dia no free, upgrade para paid tier
- **Gemini**: 60/min padrão, contatar Google para increase
- **Sistema**: Configurar rate limiting no proxy

### "Custo muito alto"
1. **Verificar routing**: Queries simples indo para Gemini Pro?
2. **Ajustar cache**: Aumentar TTL e similarity
3. **Configurar budgets**: Limits diários por provider
4. **Usar Grok free**: Para máxima economia

### "Latência alta"
- **Cache miss**: Verificar hit rate
- **Provider lento**: Configurar timeouts
- **Rede**: Verificar conectividade
- **Resources**: Aumentar CPU/RAM

## Desenvolvimento

### Como adicionar um agente?
1. Criar configuração em `src/agents/`
2. Registrar no MCP proxy
3. Adicionar routing rules
4. Testar integração

### Como personalizar o roteamento?
Editar `routing_rules` em `proxy-config.yaml`:
```yaml
routing_rules:
  condition: "domain == 'code'"
  route_to: "gemini-flash"
  reason: "optimized_for_code"
```

### Como fazer debug?
Logs detalhados
```bash
export LITELLM_LOG=DEBUG
```
Trace de requests
```bash
export ENABLE_TRACING=true
```
Dashboard local
```bash
docker-compose up grafana prometheus
```

## Performance

### Benchmarks de performance
- **Grok Free**: ~2s resposta média
- **Gemini Flash**: ~1.5s resposta média  
- **Gemini Pro**: ~3s resposta média
- **Ollama Local**: ~5s resposta média

### Limites de throughput
- **Sistema**: 100 requests/min (default)
- **Concurrent**: 10 requests paralelas
- **Cache hit**: Sub-100ms

### Como escalar?
1. **Horizontal**: Múltiplas instâncias do proxy
2. **Vertical**: Mais CPU/RAM
3. **Cache**: Redis cluster
4. **Load balancer**: NGINX/HAProxy

## Segurança

### Como manter API keys seguras?
- ✅ Use `.env.local` (nunca commitado)
- ✅ Kubernetes secrets em prod
- ✅ Vault para gestão avançada
- ✅ Rotação regular de keys

### Compliance e GDPR?
- **Dados locais**: Use Ollama para dados sensíveis
- **Logs**: Configurar retenção adequada  
- **Audit trail**: Prometheus metrics
- **Anonimização**: PII detection automática

## Custos

### Estimativa mensal (uso médio)
- **Grok Free**: $0 (até 60k requests)
- **Gemini**: $50-200 (uso típico)
- **Abacus**: $100-500 (enterprise)
- **Total**: $150-700/mês

### Como monitorar gastos?
- Dashboard Grafana: Custos em tempo real
- Alertas: 75% e 90% do budget
- Relatórios: Exportação CSV/PDF
- Projeções: ML predicting spend

Tem mais dúvidas? Abra uma [issue no GitHub](https://github.com/arturdrr/full-stack-industrial-ai/issues)!