# Documentação da API

Esta documentação descreve a API RESTful do Full-Stack Industrial AI Environment.

## Autenticação

Todas as requisições à API devem ser autenticadas usando OAuth2 via Keycloak:

- **Tipo**: Bearer Token
- **Cabeçalho**: `Authorization: Bearer {token}`

Para obter um token:

```bash
curl -X POST "http://keycloak-server/realms/industrial-ai/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=api" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "grant_type=password" \
  -d "username=YOUR_USERNAME" \
  -d "password=YOUR_PASSWORD"
```
## Endpoints Principais

### Agentes IA

#### Executar Agente
- **Endpoint**: `/agent/run`
- **Método**: `POST`
- **Descrição**: Executa tarefa ou comando no agente IA específico.
- **Parâmetros**:

| Nome      | Tipo   | Obrigatório | Descrição                                  |
|-----------|--------|-------------|--------------------------------------------|
| `agent_id`| `string` | Sim         | ID do agente a ser acionado                |
| `command` | `string` | Sim         | Comando ou prompt a executar               |
| `context` | `string` | Não         | Contexto adicional (opcional)              |

**Exemplo de requisição:**
```bash
curl -X POST "https://api.seu-servidor.com/agent/run" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "trae-agent",
    "command": "Gerar resumo do relatório",
    "context": "Relatório de vendas Q3 2025"
  }'
```
**Exemplo de resposta:**
```json
{
  "status": "success",
  "request_id": "req-123456",
  "output": "Resumo do relatório de vendas Q3 2025: Crescimento de 15% YoY...",
  "execution_time": 1.2
}
```

#### Status do Agente
- **Endpoint**: `/agent/status/{agent_id}`
- **Método**: `GET`
- **Descrição**: Retorna o status atual do agente especificado.
- **Parâmetros de URL**:

| Nome      | Tipo   | Descrição                |
|-----------|--------|--------------------------| 
| `agent_id`| `string` | ID do agente desejado    |

**Exemplo de requisição:**
```bash
curl -X GET "https://api.seu-servidor.com/agent/status/trae-agent" \
  -H "Authorization: Bearer {token}"
```
**Exemplo de resposta:**
```json
{
  "status": "active",
  "version": "1.5.2",
  "model": "abacus-llm-v1",
  "queue_size": 0,
  "last_activity": "2025-09-04T10:15:30Z"
}
```

### Modelos LLM

#### Status dos Modelos
- **Endpoint**: `/model/status`
- **Método**: `GET`
- **Descrição**: Retorna status e uso dos modelos configurados.

**Exemplo de requisição:**
```bash
curl -X GET "https://api.seu-servidor.com/model/status" \
  -H "Authorization: Bearer {token}"
```
**Exemplo de resposta:**
```json
{
  "models": [
    {
      "id": "abacus-llm-v1",
      "provider": "abacus",
      "status": "active",
      "usage_count": 245,
      "average_latency": 0.8
    },
    {
      "id": "ollama-local",
      "provider": "ollama",
      "status": "active",
      "usage_count": 87,
      "average_latency": 1.2
    }
  ],
  "default_model": "abacus-llm-v1"
}
```

#### Adicionar Modelo ao MCP Proxy
- **Endpoint**: `/proxy/model/add`
- **Método**: `POST`
- **Descrição**: Adiciona um novo modelo ao MCP Proxy.
- **Parâmetros**:

| Nome        | Tipo     | Obrigatório | Descrição                                  |
|-------------|----------|-------------|--------------------------------------------|
| `model_id`  | `string` | Sim         | Identificador do modelo                    |
| `provider`  | `string` | Sim         | Provedor do modelo                         |
| `endpoint`  | `string` | Sim         | URL do endpoint                            |
| `api_key`   | `string` | Não         | Chave de API (se necessária)               |
| `max_tokens`| `number` | Não         | Limite de tokens (opcional)                |

**Exemplo de requisição:**
```bash
curl -X POST "https://api.seu-servidor.com/proxy/model/add" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "model_id": "huggingface-llama3",
    "provider": "huggingface",
    "endpoint": "https://api.huggingface.co/models/meta-llama/Llama-3-70b",
    "api_key": "YOUR_HF_API_KEY",
    "max_tokens": 4096
  }'
```
**Exemplo de resposta:**
```json
{
  "status": "success",
  "message": "Modelo huggingface-llama3 adicionado com sucesso",
  "model_id": "huggingface-llama3"
}
```

### Workflows e Automação

#### Listar Workflows
- **Endpoint**: `/workflows`
- **Método**: `GET`
- **Descrição**: Lista todos os workflows disponíveis.
- **Parâmetros de Query**:

| Nome    | Tipo     | Obrigatório | Descrição                                  |
|---------|----------|-------------|--------------------------------------------|
| `status`| `string` | Não         | Filtrar por status (active/inactive)       |
| `page`  | `number` | Não         | Página para paginação                      |
| `limit` | `number` | Não         | Limite de itens por página                 |

**Exemplo de requisição:**
```bash
curl -X GET "https://api.seu-servidor.com/workflows?status=active&page=1&limit=10" \
  -H "Authorization: Bearer {token}"
```

#### Executar Workflow
- **Endpoint**: `/workflow/execute/{workflow_id}`
- **Método**: `POST`
- **Descrição**: Executa um workflow específico.
- **Parâmetros de URL**:

| Nome          | Tipo     | Descrição                        |
|---------------|----------|----------------------------------|
| `workflow_id` | `string` | ID do workflow a ser executado   |

- **Parâmetros do Body**: Variáveis necessárias para o workflow (dependem do workflow específico)

**Exemplo de requisição:**
```bash
curl -X POST "https://api.seu-servidor.com/workflow/execute/data-processing-flow" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "input_data": "https://storage.example.com/data.csv",
    "options": {
      "normalize": true,
      "remove_outliers": true
    }
  }'
```

## Códigos de Erro


| Código | Status             | Descrição                                  |
|--------|--------------------|--------------------------------------------|
| `200`  | `OK`               | Requisição bem-sucedida                    |
| `201`  | `Created`          | Recurso criado com sucesso                 |
| `400`  | `Bad Request`      | Parâmetros inválidos ou ausentes           |
| `401`  | `Unauthorized`     | Token de autenticação inválido ou ausente  |
| `403`  | `Forbidden`        | Permissões insuficientes para o recurso    |
| `404`  | `Not Found`        | Recurso não encontrado                     |
| `429`  | `Too Many Requests`| Taxa de requisições excedida               |
| `500`  | `Internal Error`   | Erro interno do servidor                   |
| `503`  | `Service Unavailable`| Serviço temporariamente indisponível       |

## Versionamento da API
A API utiliza versionamento via URL path. A versão atual é v1.

**Exemplo:**
`https://api.seu-servidor.com/v1/agent/run`

## Recursos Adicionais

- Swagger UI - Documentação interativa
- Postman Collection - Coleção Postman pronta para uso
