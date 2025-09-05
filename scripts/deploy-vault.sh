#!/usr/bin/env bash

# Modo Estrito para segurança e robustez
set -e
set -u
set -o pipefail

# --- Constantes ---
readonly VAULT_CONTAINER_NAME="vault-server"
readonly VAULT_DOCKER_NETWORK="vault-net"
readonly VAULT_DOCKER_VOLUME="vault-data"
readonly VAULT_ROOT_TOKEN="root-token-dev" # Apenas para desenvolvimento!

# --- Funções Auxiliares ---
log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERRO] $1" >&2
}

# --- Lógica Principal ---

verificar_dependencias() {
    log_info "Verificando dependências..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker não está instalado. Por favor, instale o Docker para continuar."
        exit 1
    fi
    log_info "Docker encontrado."
}

configurar_recursos_docker() {
    log_info "Configurando a rede e o volume do Docker..."
    
    # Cria a rede Docker se não existir
    if ! docker network ls | grep -q "$VAULT_DOCKER_NETWORK"; then
        log_info "Criando rede Docker: $VAULT_DOCKER_NETWORK"
        docker network create "$VAULT_DOCKER_NETWORK"
    else
        log_info "A rede Docker '$VAULT_DOCKER_NETWORK' já existe."
    fi

    # Cria o volume Docker se não existir
    if ! docker volume ls | grep -q "$VAULT_DOCKER_VOLUME"; then
        log_info "Criando volume Docker: $VAULT_DOCKER_VOLUME"
        docker volume create "$VAULT_DOCKER_VOLUME"
    else
        log_info "O volume Docker '$VAULT_DOCKER_VOLUME' já existe."
    fi
}

deploy_container_vault() {
    log_info "Iniciando o deploy do container do HashiCorp Vault..."
    if [ "$(docker ps -q -f name=$VAULT_CONTAINER_NAME)" ]; then
        log_info "Container do Vault já está em execução."
        return
    fi

    if [ "$(docker ps -a -q -f name=$VAULT_CONTAINER_NAME)" ]; then
        read -p "Um container do Vault já existe, mas está parado. Deseja removê-lo e recriar? (s/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            log_info "Removendo container existente..."
            docker rm -f "$VAULT_CONTAINER_NAME"
        else
            log_info "Recriação do container pulada. Tentando iniciar o container existente."
            docker start "$VAULT_CONTAINER_NAME"
            return
        fi
    fi

    log_info "Iniciando novo container do Vault em modo de desenvolvimento..."
    docker run -d --name "$VAULT_CONTAINER_NAME" \
        --network "$VAULT_DOCKER_NETWORK" \
        -p 8200:8200 \
        -v "$VAULT_DOCKER_VOLUME:/vault/file" \
        --cap-add=IPC_LOCK \
        -e "VAULT_DEV_ROOT_TOKEN_ID=$VAULT_ROOT_TOKEN" \
        -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
        hashicorp/vault:latest

    log_info "Aguardando o Vault iniciar..."
    sleep 5 # Aguarda um tempo para o serviço subir
}

configurar_vault() {
    log_info "Configurando policies e secrets no Vault..."

    # Exporta as variáveis de ambiente para os comandos do Vault
    export VAULT_ADDR='http://127.0.0.1:8200'
    export VAULT_TOKEN="$VAULT_ROOT_TOKEN"

    # Verifica o status do Vault para garantir que está acessível
    if ! docker exec "$VAULT_CONTAINER_NAME" vault status > /dev/null; then
        log_error "O servidor Vault não está acessível. A configuração falhou."
        exit 1
    fi
    log_info "Conexão com o Vault estabelecida com sucesso."

    # Habilita o secrets engine KV v2 se não estiver habilitado
    log_info "Habilitando o secrets engine KV v2 em 'secret/'..."
    if ! docker exec "$VAULT_CONTAINER_NAME" vault secrets list | grep -q "secret/"; then
         docker exec "$VAULT_CONTAINER_NAME" vault secrets enable -path=secret kv-v2
    else
        log_info "O secrets engine KV em 'secret/' já está habilitado."
    fi

    # Cria uma policy básica para a aplicação
    log_info "Criando a 'app-policy'..."
    docker exec "$VAULT_CONTAINER_NAME" vault policy write app-policy - <<EOF
path "secret/data/app/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOF

    # Cria secrets iniciais
    log_info "Criando secrets iniciais para a aplicação..."
    docker exec "$VAULT_CONTAINER_NAME" vault kv put secret/data/app/database username="db-user" password="super-secret-password"
    docker exec "$VAULT_CONTAINER_NAME" vault kv put secret/data/app/api-keys external-service-key="key-12345"

    log_info "Configuração do Vault concluída."
}

# --- Execução do Script ---
main() {
    echo "--- Script de Deploy do HashiCorp Vault ---"
    verificar_dependencias
    configurar_recursos_docker
    deploy_container_vault
    configurar_vault
    echo
    log_info "--- Deploy e configuração do Vault finalizados com sucesso! ---"
    log_info "Vault está rodando em: http://localhost:8200"
    log_info "Token Root (para desenvolvimento): $VAULT_ROOT_TOKEN"
}

main "$@"
