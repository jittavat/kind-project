#!/bin/bash
NEXUS_URL="10.10.4.134:8083"
NEXUS_USER="admin"
NEXUS_PWD="P@ssw0rd"
APP_NAME="app-b"
HASHED="$(openssl rand -hex 64)"
LOCAL_IMAGE="$APP_NAME:$HASHED"
NEXUS_IMAGE="$NEXUS_URL/repository/poc/${APP_NAME}:latest"

docker login $NEXUS_URL -u $NEXUS_USER -p $NEXUS_PWD
docker build -t "$LOCAL_IMAGE" .
docker tag "$LOCAL_IMAGE" "$NEXUS_IMAGE"
docker push "$NEXUS_IMAGE"
docker rmi "$NEXUS_IMAGE" "$LOCAL_IMAGE"

aws eks update-kubeconfig --name new-customer-platform-dev-k8s-clusters-ap-southeast-1 --profile lotus-th-role-dev
kubectl config set-context --current --namespace=$APP_NAME
kubectl apply -f deployment.yaml
kubectl rollout restart deployment/$APP_NAME