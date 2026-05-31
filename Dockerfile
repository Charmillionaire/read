# Multi-stage build for 轻阅读
FROM gradle:8.5-jdk21 AS builder

WORKDIR /app
COPY . .
RUN gradle build -x test --no-daemon

# Runtime image
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy built JAR and dependencies
COPY --from=builder /app/build/libs/read-1.0-SNAPSHOT.jar /app/read.jar
COPY --from=builder /app/libs /app/libs

# Copy static resources
COPY --from=builder /app/src/main/resources /app/resources

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "read.jar"]
