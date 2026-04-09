FROM debian:bookworm

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
	apache2 \
	php \
	php-mysql \
	php-curl \
	php-gd \
	php-mbstring \
	php-xml \
	php-zip \
	curl \
	unzip \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

# Apache
RUN a2enmod rewrite headers

RUN curl -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1 && \
    rm /tmp/wordpress.tar.gz

# WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./tools/wordpress-setup.sh /usr/local/bin/setup-wordpress.sh
RUN chmod +x /usr/local/bin/setup-wordpress.sh

RUN chown -R www-data:www-data /var/www/html

# Make apache and wordpress listen to 9000 instead of default
RUN sed -i 's/Listen 80/Listen 9000/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost *:9000>/' /etc/apache2/sites-available/000-default.conf

EXPOSE 9000

CMD ["/bin/bash", "-c", "/usr/local/bin/setup-wordpress.sh && apache2ctl -D FOREGROUND"]