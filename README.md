# 🚀 Full-Stack Industrial AI Development Environment

<p align="center">**Uma stack full-stack avançada, econômica e robusta para desenvolvimento, automação e deploy de aplicações baseadas em IA**</p>

<p align="center">
  <a href="#-visão-geral">Visão Geral</a> •
  <a href="#-arquitetura">Arquitetura</a> •
  <a href="#-começando">Começando</a> •
  <a href="#-operação">Operação</a> •
  <a href="#-configurações-avançadas">Avançado</a> •
  <a href="#-contribuição">Contribuição</a>
</p>

<p align="center">
  <img alt="CI/CD" src="https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white">
  <img alt="Kubernetes" src="https://img.shields.io/badge/Deploy-Kubernetes-326CE5?logo=kubernetes&logoColor=white">
  <img alt="Docker" src="https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white">
  <img alt="Prometheus" src="https://img.shields.io/badge/Monitoring-Prometheus-E6522C?logo=prometheus&logoColor=white">
  <img alt="Grafana" src="https://img.shields.io/badge/Dashboards-Grafana-F46800?logo=grafana&logoColor=white">
  <img alt="Keycloak" src="https://img.shields.io/badge/Auth-Keycloak-4D4D4D?logoColor=white">
  <img alt="Vault" src="https://img.shields.io/badge/Secrets-Vault-000000?logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-green.svg">
</p>

## 🌟 Visão Geral

Esta stack full-stack industrial para desenvolvimento de aplicações baseadas em IA combina orquestração de modelos locais e em nuvem, automação de workflows, segurança corporativa e capacidades avançadas como Retrieval Augmented Generation (RAG) para fornecer respostas contextuais precisas. A arquitetura prioriza ferramentas open source e self-hosted, oferecendo controle total sobre a infraestrutura.

### Principais Funcionalidades

- 💻 **Terminal Moderno**: Warp CLI e Starship para alto throughput operacional
- 🤖 **Orquestração Multiagente**: Trae Agent, LangChain (com **LangChain CLI**), Dyad, OpenHands (com **AutoGen CLI**)
- 🧠 **Multi-LLM Inteligente**: Gemini Pro (principal), Grok (gratuito), Abacus (enterprise), Ollama (local) com roteamento por IA
- 🔄 **Automação**: n8n workflows, Apache NiFi e pipelines CI/CD com GitLab CI ou GitHub Actions
- 🛡️ **Segurança**: Keycloak (IAM), Vault (secrets), Bitwarden (passwords), e análise de código com **SonarQube Community Edition**
- 📊 **Observabilidade**: Prometheus e Grafana com alertas em tempo real
- 🎨 **Frontend Moderno**: Next.js 14+, Tailwind CSS e integração com **Penpot** (open source)
- 🐳 **Containerização**: Docker e Kubernetes com Helm charts
- 💾 **Persistência e Sincronização**: **Syncthing** para backup e sincronização de dados
- 🔍 **Processamento de Linguagem**: **OpenNLP** ou spaCy para NLP avançado e **Lark** para parsing
- 🧠 **RAG Avançado**: LightRAG + ChromaDB/Qdrant para respostas contextuais precisas

## 🏗️ Arquitetura

### Diagrama de Arquitetura

```mermaid
graph TD
    subgraph "Frontend_Layer"
        A[Next.js + Tailwind] --> B[NextAuth + Keycloak]
        C[Penpot Integration] --> A
    end
    
    subgraph "AI_Orchestration"
        D[Trae Agent] --> E[MCP Proxy]
        F[LangChain] --> E
        G[OpenHands] --> E
        H[Dyad Agent] --> E
    end
    
    subgraph "LLM_Providers"
        E --> I[Gemini API]
        E --> J[Grok API] 
        E --> K[Abacus API]
        E --> L[Ollama Local]
    end
    
    subgraph "Security_Monitoring"
        M[Keycloak IAM] --> N[Vault Secrets]
        O[Prometheus] --> P[Grafana]
    end
    
    B --> M
    D --> O
```
## 🚀 Começando
### Pré-requisitos

- Sistema Operacional: Linux (preferencial), macOS ou Windows via WSL
- Ferramentas Base: Docker, Git, Python 3.10+
- Conhecimentos: Conceitos de Kubernetes, linha de comando
- Acesso: Internet para downloads e APIs

### Instalação Rápida
```bash
# Instalar componentes essenciais
bash -c "$(curl -fsSL https://raw.githubusercontent.com/arturdrr/full-stack-industrial-ai/main/scripts/setup.sh)"
```
Para uma instalação manual detalhada, consulte nossa documentação de deployment.

### Configuração Inicial

```bash
# 1. Configurar ambiente seguramente
cp .env.example .env.local
# ⚠️ IMPORTANTE: Edite .env.local com suas chaves reais

# 2. Verificar configuração
./scripts/health-check.sh

# 3. Iniciar stack completa  
docker-compose up -d
```
Serviços disponíveis:

- Frontend: http://localhost:3000
- Proxy AI: http://localhost:8081
- Keycloak: http://localhost:8080
- Grafana: http://localhost:3000 (admin/admin)
## 🛠️ Operação
### Agentes de IA
Os agentes podem ser configurados via arquivo YAML:
```yaml
agents:
  trae_agent:
    model: trae_agent_model
    max_steps: 200
  langchain_agent:
    model: langchain_model
    max_steps: 150
```
### Segurança
Keycloak e Vault formam a base de segurança:
```bash
# Iniciar Keycloak
./scripts/deploy-keycloak.sh

# Iniciar Vault
./scripts/deploy-vault.sh
```
### Monitoramento
Monitoramento com Prometheus e Grafana:

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)

## 💡 Configurações Avançadas
Consulte nossa documentação para configurações avançadas:

- Arquitetura Detalhada
- API e Integrações
- Perguntas Frequentes
- Roadmap

## 🔧 Troubleshooting

### Problemas Comuns

**❌ APIs não respondem:**
```bash
# Testar conectividade
curl -X POST http://localhost:8081/health
./scripts/test-apis.sh
```
**❌ Containers não iniciam:**
```bash
# Verificar logs
docker-compose logs -f
# Resetar ambiente
docker-compose down -v && docker-compose up -d
```
**❌ Gemini API error:**
```bash
# Verificar chave API
echo $GOOGLE_API_KEY
# Testar conectividade
curl -H "Authorization: Bearer $GOOGLE_API_KEY" \
  https://generativelanguage.googleapis.com/v1beta/models
```
**❌ Roteamento não funciona:**
```bash
# Verificar logs do proxy
docker logs litellm-proxy

# Reiniciar proxy
docker-compose restart litellm-proxy
```
### Suporte
📧 Email: arturdr@gmail.com

🐙 Issues: GitHub Issues

📖 Docs: Documentação Completa

## 🔧 Manutenção
Atualize componentes regularmente:
```bash
# Atualizar Trae Agent
cd trae-agent
git pull origin main
pip install -r requirements.txt --upgrade

# Atualizar containers
docker-compose pull
docker-compose up -d
```
## 🤝 Contribuição
Contribuições são bem-vindas! Por favor, leia nosso guia de contribuição para mais detalhes sobre:

- Processo de fork e pull request
- Padrões de código
- Testes
- Documentação

## 📄 Licença
Este projeto está licenciado sob a Licença MIT - veja o arquivo LICENSE para detalhes.

## 📚 Links Úteis

### Documentação
- [Trae Agent](https://github.com/bytedance/trae-agent)
- [LangChain](https://python.langchain.com/docs/)
- [Keycloak](https://www.keycloak.org/guides)
- [Vault](https://developer.hashicorp.com/vault/docs)
- [LiteLLM Proxy CLI](https://github.com/BerriAI/litellm)
- [AutoGen CLI](https://microsoft.github.io/autogen/)
- [ChromaDB](https://docs.trychroma.com/)
- [Qdrant](https://qdrant.tech/documentation/)
- [LightRAG](https://github.com/lightrag/lightrag)
- [SonarQube CE](https://docs.sonarqube.org/latest/)
- [Syncthing](https://docs.syncthing.net/)
- [OpenNLP](https://opennlp.apache.org/)
- [Lark](https://lark-parser.readthedocs.io/)
- [LocalAI](https://github.com/mudler/LocalAI)

### Ferramentas
- [Next.js](https://nextjs.org/docs)
- [Kubernetes](https://kubernetes.io/docs/)
- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [n8n](https://docs.n8n.io/)
- [Apache NiFi](https://nifi.apache.org/docs.html)
- [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
- [Ollama](https://ollama.ai/library)
- [HuggingFace](https://huggingface.co/docs)
- [Bitwarden](https://bitwarden.com/help/article/install-on-premise/)
- [Abacus AI](https://docs.abacus.ai/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Penpot](https://help.penpot.app/)
- [Langflow](https://docs.langflow.org/)
- [Flowise](https://docs.flowiseai.com/)


<p align="center"><strong>Desenvolvido com ❤️ para máxima produtividade em desenvolvimento de IA</strong></p>
<p align="center">📧 <strong>Contato</strong>: arturdr @gmail.com | 🐙 <strong>GitHub</strong>: @arturdrr</p>
