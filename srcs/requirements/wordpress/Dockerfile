FROM debian:bookworm

RUN apt-get update && apt-get install -y php8.2-fpm php8.2-mysql php8.2-cli php8.2-mbstring curl mariadb-client && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/wordpress.tar.gz

RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/wordpress-setup.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/setup-wordpress.sh"]
