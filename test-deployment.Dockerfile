# This Dockerfile is not to be used for end users. It is used to deploy the chobots.org test server.

FROM webratio/ant:1.10.1 AS client-builder
ARG CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}
ENV CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}

COPY client /client
WORKDIR /client
RUN chmod +x flex/bin/fcsh
RUN ant

FROM openjdk:8-jdk-slim AS server-builder
# Accept build arguments
ARG DATABASE_HOST
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD

# Set as environment variables for the build process
ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USER=$DATABASE_USER
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD

RUN apt-get update && apt-get install -y \
    ant \
    wget \
    maven \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /server

COPY server /server
RUN ant build-app

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

COPY --from=server-builder /server/red5-1.0.2 /opt/red5
RUN chmod +x /opt/red5/red5.sh

COPY --from=client-builder /client/bin /usr/share/nginx/html/game
COPY --from=client-builder /client/website /usr/share/nginx/html

# Copy and modify nginx config with Git commit SHA
COPY test-deployment/nginx.conf /tmp/nginx.conf
RUN CLEAN_SHA=$(echo "${CAPROVER_GIT_COMMIT_SHA}" | sed 's/[^a-zA-Z0-9]//g') && \
    export CAPROVER_GIT_COMMIT_SHA="${CLEAN_SHA}" && \
    envsubst < /tmp/nginx.conf > /etc/nginx/sites-available/default && \
    rm /tmp/nginx.conf

# Modify play.html to include Git commit SHA in game paths
RUN CLEAN_SHA=$(echo "${CAPROVER_GIT_COMMIT_SHA}" | sed 's/[^a-zA-Z0-9]//g') && \
    find /usr/share/nginx/html -name "*.html" -type f -exec sed -i "s|/game/|/game/${CLEAN_SHA}/|g" {} \;

RUN mkdir -p /var/log/supervisor
COPY test-deployment/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 1935

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
