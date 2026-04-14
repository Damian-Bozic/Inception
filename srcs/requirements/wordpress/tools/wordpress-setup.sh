#!/bin/sh

set -eu

wordpress_admin_user="${WORDPRESS_ADMIN_USER:-}"
if [ -n "${wordpress_admin_user}" ]; then
  wordpress_admin_user_lower=$(printf '%s' "${wordpress_admin_user}" | tr '[:upper:]' '[:lower:]')
  case "${wordpress_admin_user_lower}" in
    *admin*)
      echo "[wordpress-setup] Error: WORDPRESS_ADMIN_USER cannot contain 'admin' in any form (got '${wordpress_admin_user}')."
      exit 1
      ;;
  esac
fi

wp_admin_user="${WP_ADMIN_USER:-}"
if [ -n "${wp_admin_user}" ]; then
  wp_admin_user_lower=$(printf '%s' "${wp_admin_user}" | tr '[:upper:]' '[:lower:]')
  case "${wp_admin_user_lower}" in
    *admin*)
      echo "[wordpress-setup] Error: WP_ADMIN_USER cannot contain 'admin' in any form (got '${wp_admin_user}')."
      exit 1
      ;;
  esac
fi

admin_user="${ADMIN_USER:-}"
if [ -n "${admin_user}" ]; then
  admin_user_lower=$(printf '%s' "${admin_user}" | tr '[:upper:]' '[:lower:]')
  case "${admin_user_lower}" in
    *admin*)
      echo "[wordpress-setup] Error: ADMIN_USER cannot contain 'admin' in any form (got '${admin_user}')."
      exit 1
      ;;
  esac
fi

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