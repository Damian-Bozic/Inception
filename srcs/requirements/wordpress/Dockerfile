FROM debian:bullseye
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 9000
WORKDIR /var/www/html/
RUN apt-get update -y && \
	apt-get install -y --no-install-recommends \
	curl \
	ca-certificates \
	php7.4 \
	php7.4-fpm \
	php7.4-mysql \
	mariadb-client && \
	rm -fr /var/lib/apt/lists/*
RUN chmod 777 /var/www/html

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy the custom WordPress setup script and make it executable
COPY ./tools/wordpressscript.sh /
RUN chmod +x /wordpressscript.sh

# Run the setup script when the container starts
CMD ["/wordpressscript.sh"]