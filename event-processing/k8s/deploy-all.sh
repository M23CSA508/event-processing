#!/bin/bash

set -e

NAMESPACE="event-system"

# Set the KUBECONFIG environment variable
# export KUBECONFIG=/Users/ab040616/.kube/config

echo " Starting Kubernetes deployment for local event-processing system..."

# Check if namespace exists
if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo " Namespace '$NAMESPACE' already exists."
else
  echo " Creating namespace '$NAMESPACE'..."
  kubectl create namespace "$NAMESPACE"
fi

echo " Cleaning up existing pods..."

kubectl delete deployment zookeeper --ignore-not-found=true -n "$NAMESPACE"
kubectl delete deployment kafka --ignore-not-found=true -n "$NAMESPACE"
kubectl delete deployment postgres --ignore-not-found=true -n "$NAMESPACE"
kubectl delete deployment producer --ignore-not-found=true -n "$NAMESPACE"
kubectl delete deployment consumer --ignore-not-found=true -n "$NAMESPACE"
kubectl delete deployment alerting --ignore-not-found=true -n "$NAMESPACE"

echo " Waiting 5 seconds to give k8s to clean up old pods..."
sleep 5


echo " Deploying Zookeeper..."
kubectl apply -f zookeeper-deployment.yaml -n "$NAMESPACE"

echo " Waiting atleast 3 mins for Zookeeper to be ready..."
kubectl wait --for=condition=Ready pod -l app=zookeeper -n "$NAMESPACE" --timeout=180s

echo " Deploying Kafka..."
kubectl apply -f kafka-deployment.yaml -n "$NAMESPACE"

echo " Deploying PostgreSQL..."
kubectl apply -f postgres-deployment.yaml -n "$NAMESPACE"

echo " Waiting 10 seconds for PostgreSQL to initialize..."
sleep 10

echo " Deploying Producer Service..."
kubectl apply -f producer-deployment.yaml -n "$NAMESPACE"

echo " Deploying Consumer Service..."
kubectl apply -f consumer-deployment.yaml -n "$NAMESPACE"

echo " Deploying Alerting Service..."
kubectl apply -f alerting-deployment.yaml -n "$NAMESPACE"

echo " All components deployed successfully in namespace '$NAMESPACE'."

echo " Enabling auto-scaling..."
kubectl apply -f hpa/producer-hpa.yaml -n "$NAMESPACE"
kubectl apply -f hpa/consumer-hpa.yaml -n "$NAMESPACE"
kubectl apply -f hpa/alerting-hpa.yaml -n "$NAMESPACE"


# echo " Waiting for Producer Service to be ready..."
# kubectl wait --for=condition=Ready pod -l app=producer-service -n "$NAMESPACE" --timeout=120s

# echo " Deploy Producer Service ingress..."
# kubectl apply -f producer-ingress.yaml


kubectl get pods,svc -n "$NAMESPACE"

echo " All services are up and running!"
echo " Test publishing using the below command to run locally"
echo " curl -X POST http://localhost:8080/publish -H 'Content-Type: application/json' -d '{\"type\":\"TEMP\",\"value\":\"ALERT:90\"}'"

echo " To run locally" 
kubectl port-forward service/producer-service 8080:8080 -n event-system

