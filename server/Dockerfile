FROM openjdk:8-jdk-slim AS builder

ARG DATABASE_HOST
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD

ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USER=$DATABASE_USER
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD

RUN apt-get update && apt-get install -y \
    ant \
    && rm -rf /var/lib/apt/lists/*

COPY . /server
WORKDIR /server

RUN ant build-app

FROM openjdk:8-jre-slim

COPY red5-1.0.2 /opt/red5
WORKDIR /opt/red5

COPY --from=builder /server/red5-1.0.2/webapps/kavalok/ webapps/kavalok

RUN chmod +x red5.sh
CMD ["./red5.sh"]

EXPOSE 8935 5080