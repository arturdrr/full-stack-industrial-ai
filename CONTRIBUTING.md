# 🤝 Contribuindo para o Projeto

Obrigado pelo interesse em contribuir com nossa stack full-stack industrial AI! Este documento fornece as diretrizes para contribuir com este projeto.

## 📋 Processo de Contribuição

1. **Fork** o repositório
2. **Clone** seu fork para sua máquina local
3. **Configure o ambiente** seguindo as instruções em [Ambiente de Desenvolvimento](#ambiente-de-desenvolvimento)
4. **Crie uma branch** para sua feature ou correção (`git checkout -b feature/nova-funcionalidade`)
5. **Desenvolva** suas alterações
6. **Teste** suas alterações conforme descrito na [seção de testes](#testes)
7. **Commit** suas mudanças com mensagens descritivas (`git commit -am 'Adiciona nova funcionalidade: XYZ'`)
8. **Push** para a branch no seu fork (`git push origin feature/nova-funcionalidade`)
9. **Envie um Pull Request** para a branch principal

## 🛠️ Ambiente de Desenvolvimento

### Requisitos

- Python 3.10+
- Docker e Docker Compose
- Node.js 16+ (para o frontend)
- Kubectl (para desenvolvimento com Kubernetes)

### Configuração Inicial

```bash
# Clone o repositório
git clone https://github.com/SEU_USUARIO/full-stack-industrial-ai.git
cd full-stack-industrial-ai

# Configurar ambiente Python com Poetry
pip install poetry
poetry install

# Iniciar containers de desenvolvimento
docker-compose -f docker-compose.dev.yml up -d

# Configurar ambiente frontend
cd src/frontend
npm install
```
## 🌟 Padrões de Código

### Geral

- Siga os padrões de código existentes no projeto
- Mantenha o código limpo e bem documentado
- Escreva testes para suas alterações quando aplicável
- Atualize a documentação para refletir suas mudanças

### Python

- Siga o PEP 8 para estilo de código
- Use docstrings para documentar funções e classes
- Utilize tipagem estática quando possível
- Execute `poetry run black .` e `poetry run isort .` antes de commits

### JavaScript/TypeScript (Frontend)

- Utilize padrões modernos de ES6+
- Siga as convenções do ESLint configuradas no projeto
- Mantenha componentes React simples e funcionais
- Execute `npm run lint` e `npm run format` antes de commits

### Kubernetes/Docker

- Mantenha os Dockerfiles simples e eficientes
- Siga as melhores práticas de segurança para containers
- Documente todas as configurações Kubernetes

## 📊 Testes

- Escreva testes unitários para todas as novas funcionalidades
- Garanta que todos os testes passem antes de enviar um PR
- Considere adicionar testes de integração quando necessário

### Executando Testes
```bash
# Testes Python
poetry run pytest

# Testes Frontend
cd src/frontend
npm run test
```
## 📝 Commits

- Use mensagens de commit claras e descritivas
- Referencie issues ou PRs quando relevante
- Estruture suas mensagens de commit:
  ```
  tipo(escopo): descrição concisa

  Descrição detalhada se necessário. Explique o "por quê" e não o "o quê".

  Refs #123
  ```
  Onde `tipo` pode ser:
  - `feat`: Nova funcionalidade
  - `fix`: Correção de bug
  - `docs`: Mudanças na documentação
  - `style`: Formatação, ponto e vírgula, etc.
  - `refactor`: Refatoração de código
  - `test`: Adição de testes
  - `chore`: Tarefas de manutenção



## 📄 Pull Requests

- Use o template fornecido para criar seu PR
- Descreva claramente o propósito e escopo da alteração
- Referencie quaisquer issues relacionadas
- Mantenha os PRs focados em uma única mudança/funcionalidade

## 🔍 Revisão de Código

- Os PRs precisam ser aprovados por pelo menos um mantenedor
- Esteja aberto a feedback e faça as alterações solicitadas
- Responda a comentários e perguntas de forma clara

## 📚 Documentação

- Atualize o README.md se necessário
- Mantenha o CHANGELOG.md atualizado
- Adicione documentação para novas funcionalidades
- Toda nova funcionalidade deve incluir documentação em `docs/`

## 🐛 Reportando Bugs
Se você encontrar um bug, por favor abra uma issue seguindo o template de bug report. Inclua:

- Passos detalhados para reproduzir o problema
- Ambiente (SO, versão do Docker, etc.)
- Comportamento esperado vs. comportamento observado
- Screenshots, logs ou mensagens de erro relevantes

## ❓ Dúvidas
Se você tiver dúvidas sobre como contribuir, abra uma issue ou entre em contato com a equipe de mantenedores através do e-mail listado no README.

Agradecemos suas contribuições para tornar este projeto melhor!
