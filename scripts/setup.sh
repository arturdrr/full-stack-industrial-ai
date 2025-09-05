#!/usr/bin/env bash

# Encerra o script se um comando falhar
set -e
# Trata variáveis não definidas como um erro
set -u
# Falha o script se um comando em um pipe falhar
set -o pipefail

# --- Funções Auxiliares ---

# Função para exibir mensagens de erro
log_error() {
    echo "[ERRO] $1" >&2
}

# Função para exibir a mensagem de ajuda
usage() {
    echo "Uso: $0 [-h]"
    echo "  -h: Exibe esta mensagem de ajuda."
    echo "Este script configura o ambiente de desenvolvimento do projeto."
}

# --- Lógica Principal ---

# Função para instalar dependências (exemplo)
install_dependencies() {
    echo "Verificando e instalando dependências..."

    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker não encontrado. Por favor, instale o Docker para usar ferramentas baseadas em contêineres."
        exit 1
    fi
    echo "Docker encontrado."

    # Verificar docker-compose (necessário para Penpot, por exemplo)
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "docker-compose não encontrado. Penpot requer docker-compose para configuração completa."
        echo "Por favor, instale docker-compose (V1) ou o plugin 'compose' para Docker (V2)."
    else
        echo "docker-compose encontrado."
    fi

    echo ""
    echo "--- Instalação de Ferramentas de Desenvolvimento ---"
    echo ""

    # SonarQube Community Edition (via Docker)
    echo "--- Configurando SonarQube Community Edition (via Docker) ---"
    echo "Puxando a imagem do SonarQube (sonarqube:community)..."
    docker pull sonarqube:community || log_error "Falha ao puxar a imagem do SonarQube."
    echo "Para iniciar o SonarQube: docker run -d --name sonarqube -p 9000:9000 sonarqube:community"
    echo "Aguarde alguns minutos para que o SonarQube inicialize e acesse em http://localhost:9000"
    echo ""

    # Penpot (via Docker, menciona docker-compose)
    echo "--- Configurando Penpot (via Docker) ---"
    echo "Penpot requer docker-compose para uma configuração completa. Se ainda não tiver, instale-o."
    echo "Para configurar o Penpot, você pode clonar o repositório oficial e usar o docker-compose:"
    echo "  git clone https://github.com/penpot/penpot.git"
    echo "  cd penpot/docker && docker-compose up -d"
    echo "Mais informações em: https://penpot.app/docs/setup/"
    echo ""

    # ChromaDB (via Docker)
    echo "--- Configurando ChromaDB (via Docker) ---"
    echo "Puxando a imagem do ChromaDB (chromadb/chroma)..."
    docker pull chromadb/chroma || log_error "Falha ao puxar a imagem do ChromaDB."
    echo "Para iniciar o ChromaDB: docker run -d -p 8000:8000 chromadb/chroma"
    echo "Acesse em http://localhost:8000 para verificar."
    echo ""

    # Qdrant (via Docker)
    echo "--- Configurando Qdrant (via Docker) ---"
    echo "Puxando a imagem do Qdrant (qdrant/qdrant)..."
    docker pull qdrant/qdrant || log_error "Falha ao puxar a imagem do Qdrant."
    echo "Para iniciar o Qdrant: docker run -d -p 6333:6333 -p 6334:6334 qdrant/qdrant"
    echo "Acesse em http://localhost:6333 para a API e http://localhost:6334 para a interface web."
    echo ""

    # LocalAI (via Docker)
    echo "--- Configurando LocalAI (via Docker) ---"
    echo "LocalAI permite rodar modelos de IA localmente. Você precisará de modelos específicos para uso."
    echo "Para iniciar o LocalAI (exemplo sem modelos):"
    echo "  docker run -d -p 8080:8080 --name local-ai quay.io/go-gitea/local-ai:latest"
    echo "Você pode baixar modelos para o volume /models do contêiner. Mais informações em: https://localai.io/"
    echo ""

    # OpenNLP (menciona)
    echo "--- Considerações para OpenNLP ---"
    echo "OpenNLP é uma biblioteca baseada em Java. Não há uma 'instalação' direta via script para ela."
    echo "Pode ser incluída como dependência em projetos Maven/Gradle ou baixando os pacotes binários diretamente."
    echo "Mais informações em: https://opennlp.apache.org/"
    echo ""

    # Langflow (menciona)
    echo "--- Considerações para Langflow ---"
    echo "Langflow é uma ferramenta de orquestração de LLM (Python/JS)."
    echo "Pode ser instalada via pip ('pip install langflow'), npm ou executada via Docker."
    echo "Para iniciar via Docker: docker run -d -p 7860:7860 logspace/langflow:latest"
    echo "Mais informações em: https://langflow.org/"
    echo ""

    # Flowise (menciona)
    echo "--- Considerações para Flowise ---"
    echo "Flowise é uma ferramenta de orquestração de LLM (Node.js)."
    echo "Pode ser instalada via npm ('npm install -g flowise && flowise start') ou executada via Docker."
    echo "Para iniciar via Docker: docker run -d -p 3000:3000 flowiseai/flowise"
    echo "Mais informações em: https://flowiseai.com/"
    echo ""

    echo "Todas as dependências foram verificadas/mencionadas."
}

# Função para configurar o ambiente (exemplo)
configure_environment() {
    echo "Configurando o ambiente..."
    # Exemplo: Criar um arquivo .env a partir de um template
    # if [ ! -f ".env" ]; then
    #     echo "Criando arquivo .env..."
    #     cp .env.example .env
    # fi
    echo "Ambiente configurado."
}


# --- Execução do Script ---

main() {
    # Processa as opções da linha de comando
    while getopts "h" opt; do
        case ${opt} in
            h )
                usage
                exit 0
                ;;
            \? )
                usage
                exit 1
                ;;
        esac
    done

    echo "--- Iniciando a Configuração do Projeto ---"

    install_dependencies
    configure_environment

    echo "--- Configuração do Projeto Concluída! ---"
}

# Executa a função principal
main "$@"
