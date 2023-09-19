FROM maven:3.9.4-amazoncorretto-8-debian AS builder
WORKDIR /build
COPY . .
# TODO 修改压缩包名称
RUN apt update && apt install -y unzip &&  \
    cp settings.xml /usr/share/maven/conf/settings.xml && \
    mvn -DskipTests=true package && unzip target/assembly-demo.zip && \
    sed -i 's/\r//' assembly-demo/bin/app.sh

FROM openjdk:8-jre
# TODO 修改文件夹名称
COPY --from=builder /build/assembly-demo /app
VOLUME /app/logs
VOLUME /app/resources
WORKDIR /app/bin
ENTRYPOINT ["bash","app.sh"]