# Multi-stage build for 轻阅读 (solon-read)
# 构建: gradle build → jar(build/libs/*.jar) + 依赖复制到根 libs/
# 运行: Solon 从工作目录读 ./conf.yml (app.yml: solon.config.add: "./conf.yml")
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
# 配置文件(Solon 从 ./conf.yml 读取 admin/数据库等配置)
COPY conf/conf.yml /app/conf.yml
# 静态资源 (web前端/图片等)
COPY --from=builder /app/src/main/resources /app/resources
COPY png /app/png

EXPOSE 8080
RUN mkdir -p /app/storage/assets
ENV SERVER_PORT=8080
VOLUME ["/app/storage"]

# 用 shell 通配符匹配 build/libs 下的具体 jar
ENTRYPOINT ["sh", "-c", "java -jar /app/*.jar"]
