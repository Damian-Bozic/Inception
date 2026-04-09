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

all: up

create:
		mkdir -p /home/${LOGIN}/data/db
		mkdir -p /home/${LOGIN}/data/wp
		sudo sh -c 'echo "127.0.0.1 ${LOGIN}.42.fr" >> /etc/hosts'
		sudo chmod 755 /home/${LOGIN}
		sudo chmod 755 /home/${LOGIN}/data
		sudo chmod 775 /home/${LOGIN}/data/db
		sudo chmod 775 /home/${LOGIN}/data/wp

up: create
		sudo docker-compose -f srcs/docker-compose.yml up -d --build

down:
		sudo docker-compose -f srcs/docker-compose.yml down

clean:
		sudo rm -rf /home/${LOGIN}/data
		sudo sed -i '/${LOGIN}\.42\.fr/d' /etc/hosts
		docker system prune -a -f

fclean: down clean
		docker volume rm srcs_wp_vol
		docker volume rm srcs_db_vol

re: fclean up

.PHONY: create up down clean fclean re
