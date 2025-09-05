#!/bin/bash
# deploy-keycloak-helm.sh
set -e

echo "⛵ Deploy do Keycloak via Helm..."

# Adicionar repositório Helm do Keycloak
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Criar values customizados
cat > keycloak-values.yaml <<EOF
auth:
  adminUser: admin
  adminPassword: $(openssl rand -base64 32)

postgresql:
  enabled: true
  auth:
    postgresPassword: $(openssl rand -base64 32)
    database: keycloak
  primary:
    persistence:
      size: 20Gi
    resources:
      limits:
        cpu: 1000m
        memory: 2Gi
      requests:
        cpu: 500m
        memory: 1Gi

replicaCount: 2

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi

service:
  type: ClusterIP
  ports:
    http: 8080

ingress:
  enabled: true
  hostname: auth.seudominio.com
  tls: true
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod

metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: monitoring

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
EOF

# Deploy via Helm
helm upgrade --install keycloak bitnami/keycloak \
  --namespace keycloak \
  --create-namespace \
  --values keycloak-values.yaml \
  --wait

echo "✅ Deploy via Helm concluído!"
echo "🔐 Senha do admin salva em: kubectl get secret keycloak -n keycloak -o jsonpath='{.data.admin-password}' | base64 -d"
