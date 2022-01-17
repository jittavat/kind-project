#!/bin/bash
echo "############# Setup Kind Cluster ############# "
kind create cluster --config kind-example-config.yaml
kubectl cluster-info --context kind-kind

echo "############# Setup Kong ############# "
helm repo add kong https://charts.konghq.com
helm repo update
helm install kong/kong --namespace kong --generate-name --set proxy.type=NodePort,proxy.http.nodePort=31500,proxy.tls.nodePort=32500,admin.http.nodePort=30020,admin.enabled=true,admin.http.enabled=true,admin.ingress.enabled=true
# kubectl apply -f kong/kong.yaml


echo "############# Create test namespace ############# "
kubectl apply -f app/test-ns.yaml

echo "############# Setup Prometheus Server ############# "
kubectl apply -f monitoring/monitoring-ns.yaml
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-community/prometheus --namespace monitoring --generate-name
kubectl apply -f monitoring/monitoring.yaml
echo "############# Setup Metrics Server ############# "
kubectl apply -f metrics-server.yaml
