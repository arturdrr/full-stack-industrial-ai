#!/bin/bash
# setup-keycloak-k8s.sh
set -e

echo "☸️ Iniciando deploy do Keycloak no Kubernetes..."

# Criar namespace
kubectl create namespace keycloak --dry-run=client -o yaml | kubectl apply -f -

# Aplicar manifesto do PostgreSQL
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-db-secret
  namespace: keycloak
type: Opaque
stringData:
  POSTGRES_DB: keycloak
  POSTGRES_USER: keycloak
  POSTGRES_PASSWORD: $(openssl rand -base64 32)
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: keycloak-db-pvc
  namespace: keycloak
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak-db
  namespace: keycloak
spec:
  replicas: 1
  selector:
    matchLabels:
      app: keycloak-db
  template:
    metadata:
      labels:
        app: keycloak-db
    spec:
      containers:
      - name: postgres
        image: postgres:15
        envFrom:
        - secretRef:
            name: keycloak-db-secret
        volumeMounts:
        - name: db-data
          mountPath: /var/lib/postgresql/data
        resources:
          limits:
            cpu: 1000m
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 1Gi
      volumes:
      - name: db-data
        persistentVolumeClaim:
          claimName: keycloak-db-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak-db
  namespace: keycloak
spec:
  ports:
  - port: 5432
  selector:
    app: keycloak-db
EOF

# Aguardar banco estar pronto
echo "⏳ Aguardando banco de dados..."
kubectl wait --for=condition=ready pod -l app=keycloak-db -n keycloak --timeout=300s

# Aplicar manifesto do Keycloak
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-secret
  namespace: keycloak
type: Opaque
stringData:
  KEYCLOAK_ADMIN: admin
  KEYCLOAK_ADMIN_PASSWORD: $(openssl rand -base64 32)
  KC_DB: postgres
  KC_DB_URL: jdbc:postgresql://keycloak-db:5432/keycloak
  KC_DB_USERNAME: keycloak
  KC_DB_PASSWORD: $(kubectl get secret keycloak-db-secret -n keycloak -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 -d)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keycloak
  namespace: keycloak
spec:
  replicas: 2
  selector:
    matchLabels:
      app: keycloak
  template:
    metadata:
      labels:
        app: keycloak
    spec:
      containers:
      - name: keycloak
        image: quay.io/keycloak/keycloak:23.0.0
        args: ["start"]
        envFrom:
        - secretRef:
            name: keycloak-secret
        ports:
        - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /realms/master
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /realms/master
            port: 8080
          initialDelaySeconds: 60
          periodSeconds: 30
        resources:
          limits:
            cpu: 2000m
            memory: 4Gi
          requests:
            cpu: 1000m
            memory: 2Gi
---
apiVersion: v1
kind: Service
metadata:
  name: keycloak
  namespace: keycloak
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    app: keycloak
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak
  namespace: keycloak
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - auth.seudominio.com
    secretName: keycloak-tls
  rules:
  - host: auth.seudominio.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: keycloak
            port:
              number: 8080
EOF

echo "✅ Deploy do Keycloak concluído!"
echo "🌐 Aguarde alguns minutos e acesse: https://auth.seudominio.com"
