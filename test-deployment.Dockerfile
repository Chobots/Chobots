# This Dockerfile is not to be used for end users. It is used to deploy the chobots.org test server.

# -----------------------------------------------------------------------------
# Builder: Ant + JDK8 (preinstalled) — no apk/apt
# -----------------------------------------------------------------------------
FROM webratio/ant:1.10.1 AS server-builder

ARG RTMP_USE_TLS=true
ARG RTMP_HOSTNAME=tls.test-server.chobots.org
ARG RTMP_PORT=8443

# (kept for parity)
ARG DATABASE_HOST=localhost
ARG DATABASE_NAME=chobots
ARG DATABASE_USER=root
ARG DATABASE_PASSWORD=chobots_password
ARG CAPROVER_GIT_COMMIT_SHA

ENV DATABASE_HOST="$DATABASE_HOST" \
    DATABASE_NAME="$DATABASE_NAME" \
    DATABASE_USER="$DATABASE_USER" \
    DATABASE_PASSWORD="$DATABASE_PASSWORD" \
    CAPROVER_GIT_COMMIT_SHA="$CAPROVER_GIT_COMMIT_SHA"

# --- Build client ---
WORKDIR /client
COPY client/ /client/

RUN sed -i "s/\${RTMP_USE_TLS}/${RTMP_USE_TLS}/g" kavalok_core/src/com/kavalok/login/LoginManager.as && \
    sed -i "s/\${RTMP_HOSTNAME}/${RTMP_HOSTNAME}/g" kavalok_core/src/com/kavalok/login/LoginManager.as && \
    sed -i "s/\${RTMP_PORT}/${RTMP_PORT}/g" kavalok_core/src/com/kavalok/login/LoginManager.as

RUN chmod +x flex/bin/fcsh
RUN ant

# --- Build server ---
WORKDIR /server
COPY server/ /server/
RUN ant build-app


# -----------------------------------------------------------------------------
# Source for Java runtime (copy only; no installers)
# -----------------------------------------------------------------------------
FROM eclipse-temurin:8-jre-alpine AS jre-src


# -----------------------------------------------------------------------------
# Source for MariaDB runtime (copy only; no installers)
# -----------------------------------------------------------------------------
FROM yobasystems/alpine-mariadb:11.4.5 AS mariadb-src


# -----------------------------------------------------------------------------
# Final runtime: nginx:alpine + copied Temurin JRE + MariaDB + app artefacts
# -----------------------------------------------------------------------------
FROM nginx:alpine

# Commit SHA for cache-busting in paths
ARG CAPROVER_GIT_COMMIT_SHA
ENV CAPROVER_GIT_COMMIT_SHA="${CAPROVER_GIT_COMMIT_SHA}"

# Database environment variables for the application
ARG DATABASE_HOST=localhost
ARG DATABASE_NAME=chobots
ARG DATABASE_USER=root
ARG DATABASE_PASSWORD=chobots_password
ENV DATABASE_HOST="${DATABASE_HOST}" \
    DATABASE_NAME="${DATABASE_NAME}" \
    DATABASE_USER="${DATABASE_USER}" \
    DATABASE_PASSWORD="${DATABASE_PASSWORD}"

# ---- Java runtime: copy from Temurin Alpine JRE stage ----
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY --from=jre-src /opt/java/openjdk /opt/java/openjdk

# ---- MariaDB runtime: copy from yobasystems image into /opt/mariadb-rootfs ----
ENV MDB_BASE=/opt/mariadb-rootfs
# Core binaries, libraries, share data, and configs
COPY --from=mariadb-src /usr /opt/mariadb-rootfs/usr
COPY --from=mariadb-src /lib /opt/mariadb-rootfs/lib
COPY --from=mariadb-src /etc /opt/mariadb-rootfs/etc
# Data dir will be created/owned at runtime; copy if present (safe if empty)
COPY --from=mariadb-src /var/lib/mysql /opt/mariadb-rootfs/var/lib/mysql
# Ensure runtime dirs exist
RUN mkdir -p ${MDB_BASE}/run/mysqld

# ---- Red5 artefacts built by Ant ----
COPY server/red5-1.0.6 /opt/red5
RUN chmod +x /opt/red5/red5.sh && ls -la /opt/red5/red5.sh
COPY --from=server-builder /server/red5-1.0.6/webapps/kavalok /opt/red5/webapps/kavalok

# ---- Static site + game build output ----
COPY --from=server-builder /client/bin /usr/share/nginx/html/game
COPY --from=server-builder /client/website /usr/share/nginx/html

# ---- Nginx config templating with sed (no envsubst) ----
COPY test-deployment/nginx.conf /tmp/nginx.conf
RUN CLEAN_SHA="$(printf '%s' "${CAPROVER_GIT_COMMIT_SHA}" | tr -cd '[:alnum:]')" && \
    sed "s|\${CAPROVER_GIT_COMMIT_SHA}|${CLEAN_SHA}|g" /tmp/nginx.conf > /etc/nginx/conf.d/default.conf && \
    rm /tmp/nginx.conf

# Version the /game/ paths in HTML with the SHA
RUN CLEAN_SHA="$(printf '%s' "${CAPROVER_GIT_COMMIT_SHA}" | tr -cd '[:alnum:]')" && \
    find /usr/share/nginx/html -type f -name '*.html' -exec sed -i "s|/game/|/game/${CLEAN_SHA}/|g" {} \;

# Forward nginx logs to container stdio
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# ---- Minimal supervisor entrypoint (nginx + red5 + mariadb) ----
# Supports optional DB bootstrap via env:
#   MARIADB_ROOT_PASSWORD (recommended)
#   MARIADB_DATABASE, MARIADB_USER, MARIADB_PASSWORD (optional)
COPY test-deployment/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 1935 3306
STOPSIGNAL SIGTERM
CMD ["/entrypoint.sh"]
