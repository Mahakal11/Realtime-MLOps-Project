#!/bin/bash

set -e

# ==============================
# CONFIGURATION
# ==============================

APP_NAME="churn-api"
NAMESPACE="mlops"
IMAGE_NAME="your-docker-username/mlops-churn"
IMAGE_TAG="latest"
CONTAINER_PORT=8000
SERVICE_PORT=80

echo "🚀 Starting Deployment..."

# ==============================
# 1. Build Docker Image
# ==============================

echo "📦 Building Docker Image..."
docker build -t $IMAGE_NAME:$IMAGE_TAG .

# ==============================
# 2. Push Docker Image
# ==============================

echo "📤 Pushing Image to Registry..."
docker push $IMAGE_NAME:$IMAGE_TAG

# ==============================
# 3. Create Namespace (if not exists)
# ==============================

echo "📁 Creating Namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# ==============================
# 4. Deploy Application
# ==============================

echo "🚀 Deploying Application..."

cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $APP_NAME
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $APP_NAME
  template:
    metadata:
      labels:
        app: $APP_NAME
    spec:
      containers:
      - name: $APP_NAME
        image: $IMAGE_NAME:$IMAGE_TAG
        ports:
        - containerPort: $CONTAINER_PORT
        resources:
          requests:
            cpu: "200m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: $APP_NAME-service
spec:
  type: LoadBalancer
  selector:
    app: $APP_NAME
  ports:
  - port: $SERVICE_PORT
    targetPort: $CONTAINER_PORT
EOF

# ==============================
# 5. Wait for Rollout
# ==============================

echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/$APP_NAME -n $NAMESPACE

echo "✅ Deployment Successful!"

echo "🌍 Get Service URL:"
kubectl get svc -n $NAMESPACE