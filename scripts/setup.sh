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
    # Exemplo: Verificar se o Docker está instalado
    # if ! command -v docker &> /dev/null; then
    #     log_error "Docker não encontrado. Por favor, instale o Docker."
    #     exit 1
    # fi
    echo "Dependências satisfeitas."
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
