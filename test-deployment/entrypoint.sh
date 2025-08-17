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

# Bootstrap database with root user only
DB_NAME="${MARIADB_DATABASE:-${DATABASE_NAME}}"
ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD:-${DATABASE_PASSWORD}}"

echo "Setting up database: ${DB_NAME} with root user"

# Set root password (use DATABASE_PASSWORD as default if MARIADB_ROOT_PASSWORD not provided)
echo "Setting root password..."
"${MDB_BASE}/usr/bin/mariadb" --protocol=SOCKET --socket="${MDB_BASE}/run/mysqld/mysqld.sock" <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL

# Create database
echo "Creating database: ${DB_NAME}"
"${MDB_BASE}/usr/bin/mariadb" --protocol=SOCKET --socket="${MDB_BASE}/run/mysqld/mysqld.sock" -u root -p"${ROOT_PASSWORD}" <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL

# Start Red5 (background) - only after database is ready
echo "Starting Red5..."
echo "Checking Red5 script..."
ls -la /opt/red5/red5.sh || echo "Red5 script not found!"
cd /opt/red5 && ./red5.sh run &
RED5_PID=$!

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
