# Multi-stage build for 轻阅读 (solon-read)
# 项目构建方式: 主jar + 依赖复制到 libs/ , manifest 用 Class-Path 引用 libs/
FROM gradle:8.10-jdk21 AS builder

WORKDIR /app
COPY . .
RUN chmod +x gradlew && ./gradlew build -x test --no-daemon

# Runtime image
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
# jar 与依赖 libs/ 同级(Class-Path 相对引用 libs/xxx.jar)
COPY --from=builder /app/build/libs/*.jar /app/
COPY --from=builder /app/libs /app/libs
COPY --from=builder /app/src/main/resources /app/resources

# 暴露端口
EXPOSE 8080

RUN mkdir -p /app/storage/assets
ENV SERVER_PORT=8080
VOLUME ["/app/storage"]

# 用 shell 通配符匹配 build/libs 下的具体 jar(避免固定名/多jar导致 /app/read.jar 变成目录的问题)
ENTRYPOINT ["sh", "-c", "java -jar /app/*.jar"]
