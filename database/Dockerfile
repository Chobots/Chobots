FROM mariadb:11.8.2-noble

COPY init.sql /docker-entrypoint-initdb.d/.

CMD ["mariadbd", "--log-bin=mysql-bin", "--server-id=1", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--sql-mode=STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION", "--bind-address=0.0.0.0", "--wait-timeout=28800", "--interactive-timeout=28800", "--max-connections=200", "--connect-timeout=60", "--net-read-timeout=60", "--net-write-timeout=60", "--max-allowed-packet=64M", "--innodb-buffer-pool-size=256M", "--innodb-log-file-size=64M", "--innodb-flush-log-at-trx-commit=2", "--innodb-flush-method=O_DIRECT", "--skip-name-resolve", "--skip-host-cache"]