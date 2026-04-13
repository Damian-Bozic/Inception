FROM debian:bookworm

RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY tools/setup.sh /usr/local/bin/
RUN chmod 775 /usr/local/bin/setup.sh

	#old
	# && openssl req -x509 -nodes -days 365 \
	# -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=Domain" \
	# -newkey rsa:2048 \
	# -keyout /etc/nginx/ssl/cert.key \
	# -out /etc/nginx/ssl/cert.crt

COPY ./tools/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/setup.sh"]
