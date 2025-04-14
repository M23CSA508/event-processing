#!/bin/bash

set -e

echo " Cleaning up previous containers (if any)..."
docker rm -f zookeeper kafka postgres producer-service consumer-service alerting-service 2>/dev/null || true

echo " Checking if 'event-net' network exists..."

if docker network ls --format '{{.Name}}' | grep -q "^event-net$"; then
  echo " 'event-net' already exists. Skipping creation."
else
  echo " Creating Docker network 'event-net'..."
  docker network create event-net
fi

echo " Starting Zookeeper..."
docker run -d --name zookeeper --network event-net -p 2181:2181 \
  -e ALLOW_ANONYMOUS_LOGIN=yes \
  bitnami/zookeeper:latest



# Wait until Zookeeper is healthy or responding on port 2181
echo -e "\033[1;35m Waiting for Zookeeper to become ready...\033[0m"
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

echo -e "\033[1;35m Waiting for Kafka to be reachable on port 9092...\033[0m"
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

echo -e "\033[1;35m Waiting 10 seconds for Kafka & Postgres to initialize..."
sleep 10

echo " Building Docker images..."
cd producer-service && mvn clean install && docker build -t producer-service:latest . && cd ..
cd consumer-service && mvn clean install -Dspring.profiles.active=test && docker build -t consumer-service:latest . && cd ..
cd alerting-service && mvn clean install && docker build -t alerting-service:latest . && cd ..

echo " Running Producer Service..."
docker run -d --name producer-service --network event-net -p 8080:8080 --link kafka producer-service:latest

echo " Running Consumer Service..."
docker run -d --name consumer-service --network event-net -p 8081:8081 --link kafka --link postgres consumer-service:latest

echo " Running Alerting Service..."
docker run -d --name alerting-service --network event-net -p 8082:8082 --link kafka alerting-service:latest

echo " All services are up and running!"
echo " Test publishing using the below command"
echo -e "\033[0;32m curl -X POST http://localhost:8080/publish -H 'Content-Type: application/json' -d '{\"type\":\"TEMP\",\"value\":\"ALERT:90\"}' \033[0m"

