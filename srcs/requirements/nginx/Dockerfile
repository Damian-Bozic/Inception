FROM debian:bookworm

RUN apt-get update \
	&& apt-get install -y nginx openssl \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ARG DOMAIN
ENV DOMAIN=${DOMAIN}

# TODO fix CN=$DOMAIN being empty
RUN mkdir -p /etc/nginx/ssl \
	&& openssl req -x509 -nodes -days 365 \
	-subj "/C=FR/ST=Paris/L=Paris/O=42/OU=Inception/CN=$DOMAIN" \
	-newkey rsa:2048 \
	-keyout /etc/nginx/ssl/cert.key \
	-out /etc/nginx/ssl/cert.crt

COPY ./tools/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

# deamon off; is needed for the container to stay alive.
CMD ["nginx", "-g", "daemon off;"]