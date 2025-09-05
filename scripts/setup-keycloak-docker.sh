#!/bin/bash
# setup-keycloak-docker.sh
set -e

echo "🔐 Iniciando deploy do Keycloak via Docker..."

# Criar rede Docker se não existir
docker network create keycloak-network 2>/dev/null || true

# Deploy do banco PostgreSQL
docker run -d --name keycloak-db \
  --network keycloak-network \
  -e POSTGRES_DB=keycloak \
  -e POSTGRES_USER=keycloak \
  -e POSTGRES_PASSWORD=keycloak123 \
  -v keycloak-db:/var/lib/postgresql/data \
  postgres:15

# Aguardar banco estar pronto
echo "⏳ Aguardando banco de dados..."
sleep 10

# Deploy do Keycloak
docker run -d --name keycloak \
  --network keycloak-network \
  -p 8080:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin123 \
  -e KC_DB=postgres \
  -e KC_DB_URL=jdbc:postgresql://keycloak-db:5432/keycloak \
  -e KC_DB_USERNAME=keycloak \
  -e KC_DB_PASSWORD=keycloak123 \
  quay.io/keycloak/keycloak:23.0.0 start

echo "✅ Keycloak iniciado em http://localhost:8080"
echo "👤 Login: admin / admin123"
