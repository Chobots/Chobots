# This Dockerfile is not to be used for end users. It is used to deploy the chobots.org test server.

FROM openjdk:8-jdk-slim AS server-builder

ARG DATABASE_HOST
ARG DATABASE_NAME
ARG DATABASE_USER
ARG DATABASE_PASSWORD
ARG CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}
ARG RTMP_USE_TLS=true
ARG RTMP_HOSTNAME=tls.test-server.chobots.org
ARG RTMP_PORT=8443

ENV DATABASE_HOST=$DATABASE_HOST
ENV DATABASE_NAME=$DATABASE_NAME
ENV DATABASE_USER=$DATABASE_USER
ENV DATABASE_PASSWORD=$DATABASE_PASSWORD
ENV CAPROVER_GIT_COMMIT_SHA=${CAPROVER_GIT_COMMIT_SHA}

RUN apt-get update && apt-get install -y ant \
    && rm -rf /var/lib/apt/lists/*

# Build client
COPY client /client
WORKDIR /client

# Process the ActionScript file to inject RTMP configuration
RUN sed -i "s/\${RTMP_USE_TLS}/$RTMP_USE_TLS/g" kavalok_core/src/com/kavalok/login/LoginManager.as && \
    sed -i "s/\${RTMP_HOSTNAME}/$RTMP_HOSTNAME/g" kavalok_core/src/com/kavalok/login/LoginManager.as && \
    sed -i "s/\${RTMP_PORT}/$RTMP_PORT/g" kavalok_core/src/com/kavalok/login/LoginManager.as

RUN chmod +x flex/bin/fcsh
RUN ant

# Build server
COPY server /server
WORKDIR /server
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

# Add network optimization settings
RUN echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf && \
    echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf && \
    echo 'net.ipv4.tcp_rmem = 4096 87380 16777216' >> /etc/sysctl.conf && \
    echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf && \
    echo 'net.ipv4.tcp_congestion_control = bbr' >> /etc/sysctl.conf && \
    echo 'net.ipv4.tcp_window_scaling = 1' >> /etc/sysctl.conf && \
    echo 'net.ipv4.tcp_timestamps = 1' >> /etc/sysctl.conf && \
    echo 'net.ipv4.tcp_sack = 1' >> /etc/sysctl.conf

COPY --from=server-builder /server/red5-1.0.6 /opt/red5
COPY --from=server-builder /server/red5-1.0.6/webapps/kavalok /opt/red5/webapps/kavalok
RUN chmod +x /opt/red5/red5.sh

COPY --from=server-builder /client/bin /usr/share/nginx/html/game
COPY --from=server-builder /client/website /usr/share/nginx/html

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
