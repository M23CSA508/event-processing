#!/bin/bash

set -e

echo " Cleaning up previous containers (if any)..."
docker rm -f zookeeper kafka postgres producer-service consumer-service alerting-service 2>/dev/null || true

echo " Create a shared network "
docker network create event-net || true

echo " Starting Zookeeper..."
docker run -d --name zookeeper --network event-net -p 2181:2181 \
  -e ALLOW_ANONYMOUS_LOGIN=yes \
  bitnami/zookeeper:latest



# Wait until Zookeeper is healthy or responding on port 2181
echo " Waiting for Zookeeper to become ready..."
while ! nc -z localhost 2181; do
  sleep 1
done
echo " Zookeeper is up."

echo " Starting Kafka..."
docker run -d --name kafka --network event-net -p 9092:9092 \
  -e KAFKA_BROKER_ID=1 \
  -e KAFKA_CFG_ZOOKEEPER_CONNECT=zookeeper:2181 \
  -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092 \
  -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
  -e ALLOW_PLAINTEXT_LISTENER=yes \
  bitnami/kafka:3.5

echo " Waiting for Kafka to be reachable on port 9092..."
while ! nc -z localhost 9092; do
  sleep 1
done
echo " Kafka is up."

echo " Starting PostgreSQL..."
docker run -d --name postgres --network event-net -p 5432:5432 \
  -e POSTGRES_DB=eventdb \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=pass \
  postgres:14

echo " Waiting 10 seconds for Kafka & Postgres to initialize..."
sleep 10

echo " Building Docker images..."
cd producer-service && docker build -t producer-service:latest . && cd ..
cd consumer-service && docker build -t consumer-service:latest . && cd ..
cd alerting-service && docker build -t alerting-service:latest . && cd ..

echo " Running Publisher Service..."
docker run -d --name producer-service --network event-net -p 8080:8080 --link kafka producer-service:latest

echo " Running Consumer Service..."
docker run -d --name consumer-service --network event-net -p 8081:8081 --link kafka --link postgres consumer-service:latest

echo " Running Alerting Service..."
docker run -d --name alerting-service --network event-net -p 8082:8082 --link kafka alerting-service:latest

echo " All services are up and running!"
echo " Test publishing using the below command"
echo " curl -X POST http://localhost:8080/publish -H 'Content-Type: application/json' -d '{\"type\":\"TEMP\",\"value\":\"ALERT:90\"}'"

