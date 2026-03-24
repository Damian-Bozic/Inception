FROM debian:bookworm
EXPOSE 443

RUN apt update -y && \
	apt install -y --fix-missing --no-install-recommends nginx openssl && \
	rm -fr /var/lib/apt/lists/*

RUN mkdir certifications && \
	 openssl req -x509 -nodes -days 365 \
	-newkey rsa:2048 \
	-keyout certifications/nginx.key \
	-out certifications/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/OU=Org/CN=localhost"
#TODO move the .key to secrets
# Copy server config
COPY ./tools/nginxdefault.conf /etc/nginx/sites-available/default

# Start server
ENTRYPOINT ["nginx", "-g", "daemon off;"]
