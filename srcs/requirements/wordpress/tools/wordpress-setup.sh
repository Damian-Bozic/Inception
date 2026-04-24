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

if [ ! -f /var/www/html/wp-config-sample.php ]; then
  echo "[wordpress-setup] Copying WordPress core into the persistent volume"
  cp -a /usr/src/wordpress/. /var/www/html/
fi

if [ ! -f /var/www/html/wp-config.php ]; then
  echo "[wordpress-setup] Creating wp-config.php"
  cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/html/wp-config.php
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php
fi

if [ -z "${WORDPRESS_SITE_TITLE:-}" ] || [ -z "${WORDPRESS_ADMIN_USER:-}" ] || [ -z "${WORDPRESS_ADMIN_PASSWORD:-}" ] || [ -z "${WORDPRESS_ADMIN_EMAIL:-}" ]; then
  echo "[wordpress-setup] Error: WORDPRESS_SITE_TITLE, WORDPRESS_ADMIN_USER, WORDPRESS_ADMIN_PASSWORD, and WORDPRESS_ADMIN_EMAIL must be set"
  exit 1
fi

if ! wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then
  echo "[wordpress-setup] Installing WordPress for the first time"
  wp core install \
    --allow-root \
    --path=/var/www/html \
    --url="https://${DOMAIN}" \
    --title="${WORDPRESS_SITE_TITLE}" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}"
else
  echo "[wordpress-setup] WordPress is already installed"
fi

regular_user="${WORDPRESS_USER:-}"
regular_user_password="${WORDPRESS_PASSWORD:-}"
regular_user_email="${WORDPRESS_USER_EMAIL:-}"

if [ -n "${regular_user}${regular_user_password}${regular_user_email}" ] && \
   { [ -z "${regular_user}" ] || [ -z "${regular_user_password}" ] || [ -z "${regular_user_email}" ]; }; then
  echo "[wordpress-setup] Error: WORDPRESS_USER, WORDPRESS_PASSWORD, and WORDPRESS_USER_EMAIL must all be set together"
  exit 1
fi

if [ -n "${regular_user}" ]; then
  if wp user get "${regular_user}" --allow-root --path=/var/www/html >/dev/null 2>&1; then
    echo "[wordpress-setup] Updating default non-admin user '${regular_user}'"
    wp user update "${regular_user}" \
      --allow-root \
      --path=/var/www/html \
      --user_pass="${regular_user_password}" \
      --user_email="${regular_user_email}" \
      --role=author
  else
    echo "[wordpress-setup] Creating default non-admin user '${regular_user}'"
    wp user create "${regular_user}" "${regular_user_email}" \
      --allow-root \
      --path=/var/www/html \
      --user_pass="${regular_user_password}" \
      --role=author
  fi
fi

chown -R www-data:www-data /var/www/html

echo "WordPress setup completed. Starting php-fpm..."
echo "[wordpress-setup] Launching php-fpm"

exec php-fpm8.2 -F