FROM debian:bullseye

RUN apt-get update -y && \
	apt-get install -y  \
	--no-install-recommends \
	--fix-missing mariadb-server \
	&& rm -fr /var/lib/apt/lists/*

RUN mkdir -p /run/mysqld \
	&& chown -R mysql:mysql /run/mysqld

# COPY ./tools/my_custom.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# RUN chmod 775 /etc/mysql/mariadb.conf.d/50-server.cnf

RUN sed -i 's/^bind-address\s*=.*$/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/mariadb-setup.sh /usr/local/bin/mariadb-setup.sh
RUN chmod 775 /usr/local/bin/mariadb-setup.sh

#metadata, doesn't actually port to host for external access
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/mariadb-setup.sh"]
