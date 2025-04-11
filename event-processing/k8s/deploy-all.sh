#!/bin/bash

set -e

echo " Starting Kubernetes deployment for local event-processing system..."

kubectl create namespace event-system || echo " Namespace 'event-system' already exists"

echo " Deploying Zookeeper..."
kubectl apply -f zookeeper-deployment.yaml -n event-system

echo " Deploying Kafka..."
kubectl apply -f kafka-deployment.yaml -n event-system

echo " Deploying PostgreSQL..."
kubectl apply -f postgres-deployment.yaml -n event-system

echo " Waiting 15 seconds for services to initialize..."
sleep 15

echo " Deploying Publisher Service..."
kubectl apply -f publisher-deployment.yaml -n event-system

echo " Deploying Consumer Service..."
kubectl apply -f consumer-deployment.yaml -n event-system

echo " Deploying Alerting Service..."
kubectl apply -f alerting-deployment.yaml -n event-system

echo " All components deployed successfully in namespace 'event-system'."

kubectl get pods,svc -n event-system
