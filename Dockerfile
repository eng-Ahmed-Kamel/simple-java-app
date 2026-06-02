# Stage 1: Build execution
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /app

# 1. Copy only the files needed to restore dependencies
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# 2. Go offline to download and cache dependencies in this layer
RUN ./mvnw dependency:go-offline -B

# 3. Copy the actual source code (Changes here won't re-download dependencies)
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Stage 2: Minimal runtime image
FROM openjdk:17-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 7777
ENTRYPOINT ["java", "-jar", "app.jar"]
