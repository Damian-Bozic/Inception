FROM debian:bullseye
EXPOSE 3306

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends --fix-missing mariadb-server && \
    rm -fr /var/lib/apt/lists/*

COPY ./tools/mariadbscript.sh /
RUN chmod 777 ./mariadbscript.sh

CMD ["./mariadbscript.sh"]
