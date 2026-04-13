#!/bin/bash

if [ ! -f /etc/nginx/ssl/inception.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -out /etc/nginx/ssl/cert.crt \
        -keyout /etc/nginx/ssl/cert.key \
        -subj "/C=PL/ST=Masovia/L=Warsaw/O=42/OU=42/CN=${DOMAIN}"
fi

exec nginx -g "daemon off;"