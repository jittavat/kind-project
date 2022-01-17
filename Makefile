SHELL=/bin/bash

all: setup context metric kong app


setup:
	echo "############# Setup Kind Cluster ############# "
	kind create cluster --config kind-example-config.yaml
	kubectl cluster-info --context kind-kind

context:
	kubectl cluster-info --context kind-kind

metric: context
	echo "############# Setup Prometheus Server ############# "
	kubectl apply -f monitoring/monitoring-ns.yaml
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update
	helm install prometheus-community/prometheus --namespace monitoring --generate-name
	kubectl apply -f monitoring/monitoring.yaml
	echo "############# Setup Metrics Server ############# "
	kubectl apply -f metrics-server.yaml

kongnamespace: context
	kubectl create namespace kong

postgres: kongnamespace
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm install my-release bitnami/postgresql --namespace kong --set "postgresqlUsername=postgres,postgresqlPassword=postgres,postgresqlDatabase=kong"


kong: postgres
	echo "############# Setup Kong ############# "
	helm repo add kong https://charts.konghq.com
	helm repo update
	helm install kong/kong --namespace kong --generate-name -f kong/values.yaml

app: context
	echo "############# Load build image ############# "
	# docker build -t app-a:1.0 ./app/app-a/TracingA/
	docker build -t app-b:1.0 ./app/app-b/TracingB/
	echo "############# Load app Kong ############# "
	kind load docker-image app-b:1.0
	# kind load docker-image app-a:1.0
	kubectl apply -f app/test-ns.yaml
	# kubectl apply -f app/app-a/deployment.yaml
	# kubectl apply -f app/app-a/kong-ingress.yaml
	kubectl apply -f app/app-b/deployment.yaml
	kubectl apply -f app/app-b/kong-ingress.yaml

clean:
	docker rmi -f app-a:1.0
	docker rmi -f app-b:1.0
	kind delete cluster

