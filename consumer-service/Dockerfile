FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/consumer-service.jar consumer-service.jar
ENTRYPOINT ["java", "-jar", "consumer-service.jar"]
