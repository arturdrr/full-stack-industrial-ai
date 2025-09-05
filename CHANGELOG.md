# Changelog

Todas as mudanças significativas neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planejado
- Integração completa MCP Proxy com LangChain e Trae Agent
- Automação CI/CD para todos componentes
- Dashboards Grafana personalizados

## [0.2.0] - 2025-09-XX

### Adicionado
- Permissões RBAC com máximos privilégios para ambiente de testes
- Novas ferramentas open source: SonarQube CE, Penpot, ChromaDB/Qdrant, LocalAI, Langflow e Flowise

### Alterado
- Substituição de ferramentas proprietárias/limitadas por alternativas open source:
  - Figma → Penpot
  - Snyk → SonarQube Community Edition
  - Pinecone → ChromaDB/Qdrant
- Arquitetura atualizada para refletir as novas ferramentas

## [0.1.0] - 2025-09-04

### Adicionado
- Arquitetura geral da stack e documentação técnica
- Configurações Helm Chart para Trae Agent
- Pipeline CI/CD básico para agentes IA
- Scripts de auto-hospedagem para Keycloak, Vault e Bitwarden
- Exemplo frontend Next.js com autenticação Keycloak
- Workflows n8n para integração com LLMs
- Documentação para troubleshooting e suporte

### Alterado
- N/A

### Removido
- N/A

### Corrigido
- N/A

### Segurança
- N/A
