#!/bin/sh

set -eu
# -eu means exit on error and treat unset variables as errors

echo "[mariadb-setup] Starting MariaDB container init"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql
# make sure the user isnt root, instead it's mysql (safer and it doesn't complain)

if [ ! -d /var/lib/mysql/mysql ]; then
    echo "[mariadb-setup] No existing datadir found; initializing database"
    if command -v mariadb-install-db >/dev/null 2>&1; then
        echo "[mariadb-setup] Running mariadb-install-db"
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
    else
        echo "[mariadb-setup] Couldn't run mariadb-install-db, falling back to mysql_install_db"
        echo "[mariadb-setup] Running backup install mysql_install_db"
        mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null
    fi
fi
# super safe install, it tries to install mariadb, if it fails, it goes the mysql route

echo "[mariadb-setup] Starting temporary mysqld for bootstrap"
cat > /tmp/mariadb-bootstrap.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
CREATE USER IF NOT EXISTS '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';
ALTER USER '${WORDPRESS_DB_USER}'@'%' IDENTIFIED BY '${WORDPRESS_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${WORDPRESS_DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mysqld --user=mysql --skip-networking=1 --socket=/run/mysqld/mysqld.sock --datadir=/var/lib/mysql --init-file=/tmp/mariadb-bootstrap.sql &
pid="$!"

until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; do
    sleep 1
done

echo "[mariadb-setup] Bootstrap SQL has been loaded by mysqld"

echo "[mariadb-setup] Bootstrap complete; shutting down temporary mysqld"

mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"${MARIADB_ROOT_PASSWORD}" shutdown
wait "${pid}"

echo "[mariadb-setup] Temporary mysqld stopped; launching final mysqld"

exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock
