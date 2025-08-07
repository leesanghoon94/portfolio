#!/bin/bash

# Set namespace
NAMESPACE="prometheus"

# Create namespace if not exists
kubectl get namespace $NAMESPACE >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Creating namespace: $NAMESPACE"
    kubectl create namespace $NAMESPACE
else
    echo "Namespace $NAMESPACE already exists"
fi

# Add Prometheus Helm repo
echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install or upgrade Prometheus
echo "Installing/upgrading Prometheus..."
helm upgrade -i prometheus prometheus-community/prometheus \
    --namespace $NAMESPACE \
    --set alertmanager.persistence.storageClass="gp2" \
    --set server.persistentVolume.storageClass="gp2"

echo "Prometheus installation complete!"
