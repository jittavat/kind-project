#!/bin/bash
kubectl cluster-info --context kind-kind

echo "############# Load build image ############# "
docker build -t app-a:1.0 ./app/app-a/TracingA/
docker build -t app-b:1.0 ./app/app-b/TracingB/
echo "############# Load app Kong ############# "
kind load docker-image app-b:1.0
kind load docker-image app-a:1.0

kubectl apply -f app/app-a/deployment.yaml
kubectl apply -f app/app-a/kong-ingress.yaml

kubectl apply -f app/app-b/deployment.yaml
kubectl apply -f app/app-b/kong-ingress.yaml