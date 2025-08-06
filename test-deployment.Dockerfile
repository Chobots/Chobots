# This Dockerfile is not to be used for end users. It is used to deploy the chobots.org test server.

FROM webratio/ant:1.10.1 AS client-builder
ARG CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}
ENV CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}

COPY client /client
WORKDIR /client
RUN chmod +x flex/bin/fcsh
RUN ant

FROM openjdk:8-jdk-slim AS server-builder
RUN apt-get update && apt-get install -y \
    ant \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

COPY server/pom.xml /server/pom.xml
WORKDIR /server
RUN mvn -f /server/pom.xml dependency:copy-dependencies -DoutputDirectory=/server/lib

COPY server /server
RUN ant

# Final image
FROM openjdk:8-jre-slim

# Redeclare ARG for this stage
ARG CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}
ENV CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}

RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    gettext \
    && rm -rf /var/lib/apt/lists/*

COPY --from=server-builder /server/red5.jar /app/red5.jar
COPY --from=server-builder /server/red5/conf /app/conf
COPY --from=server-builder /server/red5/webapps /app/webapps
COPY --from=server-builder /server/lib /app/lib


COPY --from=client-builder /client/bin /usr/share/nginx/html/client
COPY --from=client-builder /client/website /usr/share/nginx/html/website

# Copy and modify nginx config with Git commit SHA
COPY test-deployment/nginx.conf /tmp/nginx.conf
RUN envsubst < /tmp/nginx.conf > /etc/nginx/conf.d/default.conf && rm /tmp/nginx.conf

# Modify play.html to include Git commit SHA in game paths
RUN find /usr/share/nginx/html/website -name "*.html" -type f -exec sed -i "s|/game/|/game/${CAPROVER_GIT_COMMIT_SHA}/|g" {} \;

RUN mkdir -p /var/log/supervisor
COPY test-deployment/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 1935

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
