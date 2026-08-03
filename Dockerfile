# Multi-stage build for 轻阅读 (solon-read)
# 项目构建方式: 主jar + 依赖复制到 libs/ , manifest 用 Class-Path 引用 libs/
FROM gradle:8.10-jdk21 AS builder

WORKDIR /app
COPY . .
RUN chmod +x gradlew && ./gradlew build -x test --no-daemon

# Runtime image
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app
COPY --from=builder /app/build/libs/*.jar /app/read.jar
# 复制运行依赖目录(libs)与 Class-Path 匹配; 也复制静态资源/配置
COPY --from=builder /app/build/libs/libs /app/libs 2>/dev/null || true
COPY --from=builder /app/libs /app/libs 2>/dev/null || true
COPY --from=builder /app/src/main/resources /app/resources

# 暴露端口
EXPOSE 8080

# 数据/静态目录
RUN mkdir -p /app/storage/assets

ENV SERVER_PORT=8080
VOLUME ["/app/storage"]

# 运行: java -jar 依赖 Class-Path(libs/)
ENTRYPOINT ["java", "-jar", "/app/read.jar"]
