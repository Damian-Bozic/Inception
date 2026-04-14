#!/bin/sh

set -eu
echo "[wordpress-setup] Starting WordPress container init"
echo "[wordpress-setup] Waiting for MariaDB at ${WORDPRESS_DB_HOST}"

until mariadb -h "${WORDPRESS_DB_HOST}" -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" "${WORDPRESS_DB_NAME}" -e "SELECT 1;" >/dev/null 2>&1; do
  echo "[wordpress-setup] MariaDB not ready yet; retrying in 2s"
  sleep 2
done
echo "[wordpress-setup] MariaDB is reachable"

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "[wordpress-setup] Creating wp-config.php"
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
fi

echo "WordPress setup completed. Starting php-fpm..."
echo "[wordpress-setup] Launching php-fpm"

exec php-fpm8.2 -F