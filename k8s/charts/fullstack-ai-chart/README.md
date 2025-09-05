# Full-Stack Industrial AI Helm Chart

Este Helm chart implanta uma stack completa de IA industrial com roteamento inteligente no Kubernetes.

## Características

- 🧠 **Multi-LLM routing** com Gemini, Grok, Abacus e Ollama
- ⚡ **Auto-scaling** baseado em métricas de IA
- 🛡️ **Security-first** com RBAC e Network Policies
- 📊 **Observability** integrada com Prometheus/Grafana
- 🚀 **Production-ready** com health checks e monitoring

## Instalação Rápida

Adicionar repositório
```bash
helm repo add fullstack-ai https://charts.your-domain.com
helm repo update
```

Instalar com valores padrão
```bash
helm install my-ai-stack fullstack-ai/fullstack-industrial-ai
```

Ou com configurações customizadas
```bash
helm install my-ai-stack fullstack-ai/fullstack-industrial-ai \
  --values values-prod.yaml \
  --namespace ai-production \
  --create-namespace
```

## Configuração

### Secrets Obrigatórios

Crie o secret com suas API keys:

```bash
kubectl create secret generic ai-secrets \
--from-literal=google-api-key="your-gemini-key" \
--from-literal=grok-api-key="your-grok-key" \
--from-literal=abacus-api-key="your-abacus-key" \
--namespace ai-production
```

### Configurações Principais

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| `replicaCount.proxy` | Número de replicas do proxy | `3` |
| `replicaCount.agents` | Número de replicas dos agentes | `2` |
| `ai.providers.gemini.enabled` | Habilitar Gemini | `true` |
| `ai.providers.grok.enabled` | Habilitar Grok | `true` |
| `ai.providers.abacus.enabled` | Habilitar Abacus | `true` |
| `ai.providers.ollama.enabled` | Habilitar Ollama | `true` |
| `autoscaling.enabled` | Habilitar auto-scaling | `true` |
| `persistence.enabled` | Habilitar storage persistente | `true` |
| `monitoring.enabled` | Habilitar monitoramento | `true` |

### Ambientes

#### Desenvolvimento
```bash
helm install dev-ai fullstack-ai/fullstack-industrial-ai\
  --values values-dev.yaml \
  --namespace ai-dev
```

#### Produção
```bash
helm install prod-ai fullstack-ai/fullstack-industrial-ai\
  --values values-prod.yaml \
  --namespace ai-production
```

## Monitoramento

### Métricas Disponíveis

- `ai_routing_requests_total` - Total de requests roteadas
- `ai_routing_latency_seconds` - Latência do roteamento
- `ai_provider_errors_total` - Erros por provider
- `ai_cost_usd_total` - Custos acumulados por provider

### Dashboards Grafana

O chart inclui dashboards pré-configurados:
- AI Routing Overview
- Provider Performance
- Cost Tracking
- System Health

## Troubleshooting

### Proxy não responde
```bash
kubectl logs -l app.kubernetes.io/component=proxy
kubectl describe hpa my-ai-stack-proxy-hpa
```

### Agentes não processam
```bash
kubectl get pods -l app.kubernetes.io/component=agents
kubectl logs -l app.kubernetes.io/component=agents -f
```

### Verificar secrets
```bash
kubectl get secret ai-secrets -o yaml
kubectl describe secret ai-secrets
```

## Upgrades

Upgrade para nova versão
```bash
helm upgrade my-ai-stack fullstack-ai/fullstack-industrial-ai\
  --values values-prod.yaml
```

Rollback se necessário
```bash
helm rollback my-ai-stack 1
```

## Valores Avançados

Veja [values.yaml](values.yaml) para lista completa de opções configuráveis.

## Suporte

- 📧 Email: arturdr@gmail.com
- 🐙 Issues: [GitHub Issues](https://github.com/arturdrr/full-stack-industrial-ai/issues)
- 📖 Docs: [Documentação](https://github.com/arturdrr/full-stack-industrial-ai/issues)
