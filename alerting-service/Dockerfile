FROM openjdk:17-jdk-slim

WORKDIR /app
COPY target/alerting-service.jar alerting-service.jar
ENTRYPOINT ["java", "-jar", "alerting-service.jar"]
