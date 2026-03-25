#!/bin/bash
set -e

# Optional: allow external connections (0.0.0.0) 
# Remove or change if you only need local/container access
sed -i 's/bind-address .*=.*/bind-address = 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

# Start MariaDB temporarily in the background without networking to run setup commands
mysqld_safe --skip-networking &

# Wait a few seconds for the server to be ready
sleep 5

# Set up the database and user
mariadb -uroot -e "CREATE DATABASE IF NOT EXISTS \`$MDB_DATABASE\`;"
mariadb -uroot -e "CREATE USER IF NOT EXISTS '$MDB_USER'@'%' IDENTIFIED BY '$MDB_PASSWORD';"
mariadb -uroot -e "GRANT ALL PRIVILEGES ON \`$MDB_DATABASE\`.* TO '$MDB_USER'@'%';"

# Optional: remove temporary background server before starting proper server
killall mysqld_safe || true
killall mysqld || true

# Start MariaDB in the foreground for Docker
exec mysqld --console
