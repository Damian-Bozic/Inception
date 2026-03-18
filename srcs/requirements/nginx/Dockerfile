FROM debian:bookworm
EXPOSE 443

RUN apt update -y;
RUN apt install -y nginx
#OPENSSL installs TLS protocols I can use later.
Run apt install -y openssl

RUN mkdir certifications
RUN openssl req -x509 -nodes - days 365 \
	-newkey rsa:2048 \
	-keyout certifications/nginx.key \
	-out certifications/nginx.crt
#TODO move the .key to secrets