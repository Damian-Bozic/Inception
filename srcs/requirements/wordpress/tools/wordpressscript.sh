#!/bin/bash
#TODO REMAKE TEMP FILE
sed -i -e 's/listen =.*/listen = 0.0.0.0:9000/g' /etc/php/7.4/fpm/pool.d/www.conf
mkdir -p /run/php

# Don't re-install WP
if ! wp-cli.phar core is-installed 2>/dev/null; then

    # Downloads WP
    wp-cli.phar core download --allow-root --force

    # Creates the config file using the .env values
    wp-cli.phar config create --allow-root --dbname=$MDB_DATABASE --dbuser=$MDB_USER --dbpass=$MDB_PASSWORD --dbhost=mariadb:3306 --skip-check

    # Runs the install script using the .env values, and creates the admin user
    wp-cli.phar core install --allow-root --url=$DOMAIN --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email

    # Creates a new user
    wp-cli.phar user create --allow-root $WP_USER $WP_EMAIL --user_pass=$WP_PASSWORD

    # Changes the installation owner and permissions
    chown -R www-data:www-data /var/www/html/
    chmod -R 775 /var/www/html

    # Redis setup (bonus)
    wp-cli.phar config set WP_CACHE true --allow-root
	wp-cli.phar config set WP_CACHE_KEY_SALT $R_KEY --allow-root
	wp-cli.phar config set WP_REDIS_HOST $R_HOST --allow-root
	wp-cli.phar config set WP_REDIS_PORT 6379 --allow-root
    wp-cli.phar plugin install redis-cache --allow-root --activate
    wp-cli.phar redis enable --allow-root
fi

# Starts the PHP fastcgi module
/usr/sbin/php-fpm7.4 --nodaemonize