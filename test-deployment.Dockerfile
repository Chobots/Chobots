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
ARG DATABASE_USER=chobots
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
ARG DATABASE_USER=chobots
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
COPY <<'SH' /entrypoint.sh
#!/bin/sh
set -eu

MDB_BASE="/opt/mariadb-rootfs"
export LD_LIBRARY_PATH="${MDB_BASE}/usr/lib:${MDB_BASE}/lib:${LD_LIBRARY_PATH:-}"

# create mysql user and group (busybox adduser; no packages)
if ! id -u mysql >/dev/null 2>&1; then
  addgroup -S mysql || true
  adduser -S -H -s /sbin/nologin -G mysql mysql || true
fi

mkdir -p "${MDB_BASE}/var/lib/mysql" "${MDB_BASE}/run/mysqld"
chown -R mysql:mysql "${MDB_BASE}/var/lib/mysql" "${MDB_BASE}/run/mysqld"

need_init=1
if [ -d "${MDB_BASE}/var/lib/mysql/mysql" ] && [ -f "${MDB_BASE}/var/lib/mysql/mysql/user.MAD" -o -f "${MDB_BASE}/var/lib/mysql/mysql/user.frm" -o -f "${MDB_BASE}/var/lib/mysql/mysql/user.ibd" ]; then
  need_init=0
fi

if [ "$need_init" -eq 1 ]; then
  echo "Initialising MariaDB data directory..."
  "${MDB_BASE}/usr/bin/mariadb-install-db" \
    --basedir="${MDB_BASE}/usr" \
    --datadir="${MDB_BASE}/var/lib/mysql" \
    --skip-test-db \
    --auth-root-authentication-method=normal \
    --user=mysql >/dev/null
fi

# Start nginx (foreground, backgrounded by this script)
echo "Starting nginx..."
nginx -g 'daemon off;' &
NGINX_PID=$!
echo "Nginx started with PID: ${NGINX_PID}"

# Check if nginx is running
sleep 2
if kill -0 "${NGINX_PID}" 2>/dev/null; then
  echo "Nginx is running successfully"
else
  echo "Nginx failed to start"
fi

# Start Red5 (background)
# If 'run' isn't supported, switch to 'sh /opt/red5/red5.sh start'
echo "Checking Red5 script..."
ls -la /opt/red5/red5.sh || echo "Red5 script not found!"
cd /opt/red5 && ./red5.sh run &
RED5_PID=$!

# Start MariaDB server (background)
"${MDB_BASE}/usr/bin/mariadbd" \
  --basedir="${MDB_BASE}/usr" \
  --datadir="${MDB_BASE}/var/lib/mysql" \
  --plugin-dir="${MDB_BASE}/usr/lib/mariadb/plugin" \
  --socket="${MDB_BASE}/run/mysqld/mysqld.sock" \
  --pid-file="${MDB_BASE}/run/mysqld/mysqld.pid" \
  --bind-address=0.0.0.0 \
  --user=mysql &
MDB_PID=$!

# Wait for MariaDB socket ready (max ~60s)
echo "Waiting for MariaDB to become ready..."
for i in $(seq 1 60); do
  if [ -S "${MDB_BASE}/run/mysqld/mysqld.sock" ]; then
    if "${MDB_BASE}/usr/bin/mariadb-admin" --protocol=SOCKET --socket="${MDB_BASE}/run/mysqld/mysqld.sock" ping >/dev/null 2>&1; then
      echo "MariaDB ready!"
      break
    fi
  fi
  sleep 1
done

# Bootstrap database with default values (or override with MARIADB_* env vars)
DB_NAME="${MARIADB_DATABASE:-${DATABASE_NAME}}"
DB_USER="${MARIADB_USER:-${DATABASE_USER}}"
DB_PASSWORD="${MARIADB_PASSWORD:-${DATABASE_PASSWORD}}"

echo "Setting up database: ${DB_NAME} with user: ${DB_USER}"

# Optional: Set root password if provided
if [ -n "${MARIADB_ROOT_PASSWORD:-}" ]; then
  echo "Securing root account..."
  "${MDB_BASE}/usr/bin/mariadb" --protocol=SOCKET --socket="${MDB_BASE}/run/mysqld/mysqld.sock" <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL
fi

# Create database
echo "Creating database: ${DB_NAME}"
"${MDB_BASE}/usr/bin/mariadb" --protocol=SOCKET --socket="${MDB_BASE}/run/mysqld/mysqld.sock" -u root ${MARIADB_ROOT_PASSWORD:+-p"${MARIADB_ROOT_PASSWORD}"} <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL

# Create user and grant privileges
echo "Creating user: ${DB_USER}"
"${MDB_BASE}/usr/bin/mariadb" --protocol=SOCKET --socket="${MDB_BASE}/run/mysqld/mysqld.sock" -u root ${MARIADB_ROOT_PASSWORD:+-p"${MARIADB_ROOT_PASSWORD}"} <<SQL
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

terminate() {
  echo "Stopping services..."
  kill -TERM "${MDB_PID}" 2>/dev/null || true
  if [ -f /opt/red5/red5.pid ]; then
    kill -TERM "$(cat /opt/red5/red5.pid)" 2>/dev/null || true
  else
    kill -TERM "${RED5_PID}" 2>/dev/null || true
  fi
  kill -TERM "${NGINX_PID}" 2>/dev/null || true
}
trap terminate INT TERM

# Wait for any to exit; then stop others
wait ${MDB_PID}
MDB_STATUS=$? || true
terminate
wait ${RED5_PID} 2>/dev/null || true
wait ${NGINX_PID} 2>/dev/null || true
exit ${MDB_STATUS}
SH
RUN chmod +x /entrypoint.sh

EXPOSE 80 1935 3306
STOPSIGNAL SIGTERM
CMD ["/entrypoint.sh"]
