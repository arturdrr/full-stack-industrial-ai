# Frontend da Full-Stack Industrial AI

Este diretório contém o código frontend da stack Full-Stack Industrial AI, construído com Next.js, Tailwind CSS e integrado com Penpot para design.

## 🚀 Começando

### Pré-requisitos

- Node.js 16+
- npm ou yarn
- Acesso aos serviços backend (APIs e autenticação Keycloak)

### Instalação

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env.local
# Edite .env.local com suas configurações

# Iniciar servidor de desenvolvimento
npm run dev
```
O frontend estará disponível em http://localhost:3000

## 🏗️ Estrutura do Projeto
```
frontend/
├── components/       # Componentes React reutilizáveis
├── contexts/         # Contextos React (auth, theme, etc.)
├── hooks/            # Hooks personalizados
├── pages/            # Rotas da aplicação
├── public/           # Arquivos estáticos
├── services/         # Serviços de API e integração
├── styles/           # Arquivos CSS/Tailwind
└── utils/            # Utilitários e funções auxiliares
```
## 🔒 Autenticação
A autenticação é gerenciada via Keycloak usando o NextAuth.js. Consulte `pages/api/auth/[...nextauth].js` para detalhes de implementação.

### Exemplo de Página Protegida
```jsx
import { useSession, signIn } from "next-auth/react";

export default function ProtectedPage() {
  const { data: session, status } = useSession();

  if (status === "loading") return <div>Carregando...</div>;
  if (!session) {
    signIn();
    return <div>Redirecionando para login...</div>;
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold">
        Bem-vindo, {session.user.name || session.user.email}!
      </h1>
      {/* Conteúdo protegido aqui */}
    </div>
  );
}
```
## 🎨 Design com Penpot
Os designs da interface são mantidos no Penpot, uma alternativa open source ao Figma.

### Fluxo de Trabalho de Design

- Acesse o Penpot em `http://[penpot-url]`
- Consulte o projeto "Industrial AI Interface"
- Exporte componentes como SVG ou use-os como referência
- Implemente usando Tailwind CSS seguindo nosso guia de estilo

## 🔄 Integração com APIs
### Exemplo de chamada para Trae Agent
```jsx
import { useAgent } from '../hooks/useAgent';

export default function AgentControl() {
  const { runCommand, isLoading, result } = useAgent();
  
  const handleSubmit = async (e) => {
    e.preventDefault();
    const command = e.target.command.value;
    await runCommand('trae-agent', command);
  };
  
  return (
    <form onSubmit={handleSubmit}>
      <input 
        type="text" 
        name="command"
        className="border p-2 rounded"
        placeholder="Digite um comando para o agente..." 
      />
      <button 
        type="submit"
        className="bg-blue-500 text-white p-2 rounded ml-2"
        disabled={isLoading}
      >
        {isLoading ? 'Processando...' : 'Executar'}
      </button>
      
      {result && (
        <div className="mt-4 p-4 bg-gray-100 rounded">
          <pre>{JSON.stringify(result, null, 2)}</pre>
        </div>
      )}
    </form>
  );
}
```
## 📊 Visualização de Dados
Para visualizações, usamos componentes React com Recharts ou D3.js. Exemplos podem ser encontrados em `components/charts/`.

## 🧪 Testes
```bash
# Executar testes unitários
npm run test

# Executar testes e2e
npm run test:e2e
```
## 🔨 Construção para Produção
```bash
# Construir para produção
npm run build

# Iniciar servidor de produção
npm run start
```
## 🤝 Contribuição
Veja `CONTRIBUTING.md` para diretrizes de contribuição.
