
# Event Processing System

Large-scale applications often process millions of events per second (e.g., IoT systems, log processing pipelines, or financial transaction monitors). Traditional monolithic architectures struggle to meet these demands due to scalability bottlenecks and cost inefficiencies.

### Key Challenges Addressed

- **High Throughput Event Processing**: Kafka acts as the central message broker, decoupling producers and consumers for asynchronous, high-speed communication.
- **Dynamic Auto-Scaling**: Kubernetes manages containerized services and can auto-scale based on resource usage or queue depth.
- **Cost-Efficient Serverless Execution**: Modular microservices allow fine-grained resource allocation, reducing overhead and enabling possible migration to FaaS platforms (like OCI Functions).
- **Low-Latency Responses**: Services communicate over lightweight REST endpoints, and Kafka ensures real-time event delivery with minimal delay.

This system is designed with scalability, modularity, and performance in mind—ideal for event-driven architectures operating at scale.


## Project Structure

```
event-processing/
├── producer-service/        # Publishes events to Kafka
├── consumer-service/        # Consumes and processes Kafka events
├── alerting-service/        # Sends alerts based on specific conditions
├── k8s/                     # Kubernetes deployment files
├── run-all.sh               # Script to deploy all services
```

## Getting Started

### Prerequisites

Make sure the following tools are installed:

- Docker
- Kubernetes 
- Maven
- Java 17+

### Step-by-Step Deployment Guide

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd event-processing
```

#### 2. Build Docker Images

Run the following inside each microservice directory:

```bash
cd producer-service
mvn clean install
docker build -t producer-service .

cd ../consumer-service
mvn clean install
docker build -t consumer-service .

cd ../alerting-service
mvn clean install
docker build -t alerting-service .
```

#### 3. Load Docker Images into Kubernetes 

```bash
colima start --with-kubernetes --memory 4 --cpu 2
```

Then build the images again to load them into the Minikube Docker daemon.

#### 4. Run docker instance  

From the root directory:

```bash
chmod +x run-all.sh
./run-all.sh
```
* This will clean any previously up containers (if any).
* Create a shared network
* This will build and deploy:
  - Zookeeper
  - Kafka
  - Postgres
  - Producer, Consumer, and Alerting microservices

#### 5. Verifying docker run 
Docker running instances 
```bash
docker ps
```
--------------
#### 6. Deploy Using Kubernetes

From the root directory:

```bash
cd k8s
chmod +x deploy-all.sh
./deploy-all.sh
```

This will deploy:
- Zookeeper
- Kafka
- Postgres
- Producer, Consumer, and Alerting microservices

#### 7. Verifying Deployment

```bash
kubectl get pods
kubectl logs <pod-name>
```

You should see logs from the services interacting with Kafka.

## Services Overview

- **ProducerService**: Publishes user-defined events to a Kafka topic.
- **ConsumerService**: Listens to the Kafka topic and processes the events.
- **AlertingService**: Triggers alerts based on event type/threshold.

## Testing

Use Postman or CURL to send test events to the `/publish` endpoint of the producer service (usually exposed via a NodePort or Ingress).

Example:

```bash
curl -X POST http://<node-id>:<nodeport>/publish -H "Content-Type: application/json" -d  -d '{"type":"TEMP","value":"ALERT:90"}'
```

Expected:
- `consumer-service` logs the event to DB
- `alerting-service` prints alert to console

## Kubernetes YAML Files

All Kubernetes resource definitions are under the `k8s/` directory. This includes:

- Deployments
- Services
- ConfigMaps 

## Troubleshooting

- Ensure Docker images are accessible from within Kubernetes.
- Use `kubectl logs -f <pod-name> -n event-system` for error logs.
- Check resource status using `kubectl get all`.
- Check the pods status using `kubectl get pods -n event-system`.

## Optional Checks

### Check Kafka Topic (inside Kafka container):
```bash
docker exec -it kafka bash
kafka-topics.sh --bootstrap-server kafka:9092 --list
```

### Connect to Postgres:
```bash
docker exec -it postgres psql -U postgres -d eventdb
SELECT * FROM events;
```

- If you directly deploy docker images into local. 
- Use `docker ps` to list out running docker instance. 
- Use `docker logs <CONTAINER ID>`

## Notes
- This is a simulation of OCI Functions using sidecar microservices.
- Kafka setup uses Bitnami images.
- Recommended for dev/testing environments.
  
## Authors

Created by the IIT Jodhpur Executive M-Tech AI 2023 Team group # 30.
|Name | Roll No. | Role |
|------|--------------------|----|
|Torsha Chatterjee	|M23CSA536| Alerting Services |
|Suvodip Som	|M23CSA533| Consumer Services  |
|Swapnil Adak	|M23CSA534| Producer Service |
|Anindya Bandopadhyay	|M23CSA508| Deployment |
