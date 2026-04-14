# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dbozic <marvin@42.fr>                      +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/03/16 19:06:16 by dbozic            #+#    #+#              #
#    Updated: 2026/03/16 19:06:16 by dbozic           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

LOGIN=dbozic
REBOOT_STAMP=/home/${LOGIN}/.inception_reboot_required
BOOT_ID_FILE=/proc/sys/kernel/random/boot_id
#forced reboot behaviour to force the docker group to be applied

all: up

create:
		mkdir -p /home/${LOGIN}/data/db
		mkdir -p /home/${LOGIN}/data/wp
		sudo sh -c 'grep -q "127.0.0.1.*${LOGIN}\.42\.fr" /etc/hosts || echo "127.0.0.1 ${LOGIN}.42.fr" >> /etc/hosts'
		if ! id -nG ${LOGIN} | grep -qw docker; then sudo usermod -aG docker ${LOGIN}; cat ${BOOT_ID_FILE} > ${REBOOT_STAMP}; echo "Docker group assigned to ${LOGIN}."; echo "System restart required before continuing."; echo "Reboot, then run: make"; \
			exit 1; \
		fi
		if [ -f ${REBOOT_STAMP} ] && [ "`cat ${BOOT_ID_FILE}`" = "`cat ${REBOOT_STAMP}`" ]; then echo "\n\nSystem restart is still required before continuing."; echo "Reboot, then run: make"; \
			exit 1; \
		fi
		rm -f ${REBOOT_STAMP}
		sudo chmod 755 /home/${LOGIN}
		sudo chmod 755 /home/${LOGIN}/data
		sudo chmod 775 /home/${LOGIN}/data/db
		sudo chmod 775 /home/${LOGIN}/data/wp

up: create
		sudo docker-compose -f srcs/docker-compose.yml up -d --build

down:
		sudo docker-compose -f srcs/docker-compose.yml down

clean:
		sudo sed -i '/${LOGIN}\.42\.fr/d' /etc/hosts
		sudo docker system prune -a -f

fclean: down clean
		sudo docker volume rm srcs_wp_vol
		sudo docker volume rm srcs_db_vol
		sudo rm -rf /home/${LOGIN}/data

re: fclean up

.PHONY: create up down clean fclean re
