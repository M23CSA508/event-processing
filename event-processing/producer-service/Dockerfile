FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/producer-service.jar producer-service.jar
ENTRYPOINT ["java", "-jar", "producer-service.jar"]
