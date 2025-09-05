#!/bin/bash
# configure-keycloak.sh
set -e

KEYCLOAK_URL="http://localhost:8080"
ADMIN_USER="admin"
ADMIN_PASS="admin123"

echo "⚙️ Configurando Keycloak automaticamente..."

# Função para obter token de admin
get_admin_token() {
  curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$ADMIN_USER" \
    -d "password=$ADMIN_PASS" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" | jq -r '.access_token'
}

TOKEN=$(get_admin_token)

# Criar realm para aplicação
echo "🏢 Criando realm 'fullstack-ai'..."
curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "fullstack-ai",
    "enabled": true,
    "displayName": "Full-Stack AI Environment",
    "loginWithEmailAllowed": true,
    "registrationAllowed": true,
    "resetPasswordAllowed": true,
    "rememberMe": true,
    "verifyEmail": false,
    "sslRequired": "external",
    "accessTokenLifespan": 3600,
    "refreshTokenMaxReuse": 0
  }'

# Criar cliente para Next.js
echo "🖥️ Criando cliente 'nextjs-app'..."
curl -s -X POST "$KEYCLOAK_URL/admin/realms/fullstack-ai/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "nextjs-app",
    "name": "Next.js Application",
    "enabled": true,
    "publicClient": false,
    "protocol": "openid-connect",
    "redirectUris": [
      "http://localhost:3000/*",
      "https://app.seudominio.com/*"
    ],
    "webOrigins": ["+"],
    "standardFlowEnabled": true,
    "directAccessGrantsEnabled": true,
    "serviceAccountsEnabled": true,
    "authorizationServicesEnabled": true
  }'

# Criar usuário de teste
echo "👤 Criando usuário de teste..."
curl -s -X POST "$KEYCLOAK_URL/admin/realms/fullstack-ai/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "developer",
    "email": "dev@example.com",
    "firstName": "Developer",
    "lastName": "User",
    "enabled": true,
    "emailVerified": true,
    "credentials": [{
      "type": "password",
      "value": "dev123",
      "temporary": false
    }]
  }'

# Criar roles
echo "🎭 Criando roles..."
for role in "admin" "developer" "viewer"; do
  curl -s -X POST "$KEYCLOAK_URL/admin/realms/fullstack-ai/roles" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$role\",
      \"description\": \"$role role for the application\"
    }"
done

echo "✅ Configuração do Keycloak concluída!"
echo "📋 Credenciais criadas:"
echo "   - Admin: admin / admin123"
echo "   - Usuário teste: developer / dev123"
echo "   - Realm: fullstack-ai"
echo "   - Cliente: nextjs-app"
