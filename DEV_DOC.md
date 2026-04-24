*This file has been created as developer documentation for the Inception stack.*

**DEV_DOC**

*-How to set up from scratch*

Host prerequisites (Debian 12 tested):
+ sudo
+ git
+ make
+ docker.io
+ docker-compose
+ user which you use to build must have sudo permissions.

Required project configuration:
+ Makefile: set LOGIN to your local Linux username
+ Create your own srcs/.env from srcs/.env_example
+ srcs/.env: define DOMAIN, MARIADB_*, WORDPRESS_DB_* and the WordPress first-run admin values
+ Optional regular user provisioning: define WORDPRESS_USER, WORDPRESS_PASSWORD, and WORDPRESS_USER_EMAIL together (or leave all three unset)
+ WORDPRESS_DB_HOST must be mariadb
+ srcs/requirements/nginx/tools/default.conf: server_name should match DOMAIN
+ The WordPress startup script performs the initial wp core install automatically on first boot.
 
Secrets handling:
+ Current setup uses srcs/.env (not Docker secrets)
+ Do not commit real secrets in public repositories
+ Rotate credentials when sharing or exposing the project

*-How to build and launch with Makefile and Docker Compose*

From repository root:
+ make
What this does:
+ Creates /home/${LOGIN}/data/db and /home/${LOGIN}/data/wp
+ Adds ${LOGIN}.42.fr to /etc/hosts
+ Adds user to docker group if needed (reboot required once in that case)
+ Runs docker-compose -f srcs/docker-compose.yml up -d --build
First-run behavior:
+ WordPress waits for MariaDB, copies the core files into the persistent volume, creates wp-config.php, and runs wp-cli install once.
+ If WORDPRESS_USER, WORDPRESS_PASSWORD, and WORDPRESS_USER_EMAIL are provided, startup also creates a default non-admin WordPress user with role=author.
+ On subsequent starts, if the user already exists, startup updates that user's email/password and keeps role=author.

Related lifecycle commands:
+ make down
+ make re

*-Relevant management commands for containers and volumes*
Makefile commands:
+ make
+ make down
+ make clean
+ make fclean (Deletes all databases and any data stored inside)

Docker Compose commands:
+ docker-compose -f srcs/docker-compose.yml ps
+ docker-compose -f srcs/docker-compose.yml logs -f
+ docker-compose -f srcs/docker-compose.yml up -d --build
+ docker-compose -f srcs/docker-compose.yml down

Container checks:
+ docker ps
+ docker logs mariadb
+ docker logs wordpress
+ docker logs nginx

Volume checks:
+ docker volume ls
+ docker volume inspect srcs_wp_vol
+ docker volume inspect srcs_db_vol

*-Where data is stored and how persistence works*
Persistent data paths (via compose bind-backed volumes):
+ srcs_wp_vol -> /home/dbozic/data/wp/
+ srcs_db_vol -> /home/dbozic/data/db/

Persistence behavior:
+ make down keeps data
+ make clean removes docker artifacts and host entry from /etc/hosts
+ make fclean removes srcs_wp_vol, srcs_db_vol, and /home/${LOGIN}/data
 
If LOGIN is changed in the Makefile, expected host data paths change also.
