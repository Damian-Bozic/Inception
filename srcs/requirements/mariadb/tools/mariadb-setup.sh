#!/bin/sh

set -eu

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    if command -v mariadb-install-db >/dev/null 2>&1; then
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/dev/null
    else
        mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null
    fi

    mysqld --user=mysql --skip-networking=1 --socket=/run/mysqld/mysqld.sock --datadir=/var/lib/mysql &
    pid="$!"

    until mysqladmin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; do
        sleep 1
    done

    mysql --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mysqladmin --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"${MARIADB_ROOT_PASSWORD}" shutdown
    wait "${pid}"
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock
