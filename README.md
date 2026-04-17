This project has been created as part of the 42 curriculum by <dbozic>.

**Description**
This project builds a full WordPress stack using Docker and Docker Compose.
It runs three isolated services (nginx, wordpress, mariadb), each with its own Dockerfile and startup script.
The goal is reproducible infrastructure: same build steps, same runtime behavior, and clear service boundaries.

*-Sources included in the project*
+srcs/docker-compose.yml: service orchestration, network, volumes, and restart policy
+srcs/requirements/mariadb/: MariaDB image definition and bootstrap logic
+srcs/requirements/wordpress/: WordPress + PHP-FPM image and startup logic
+srcs/requirements/nginx/: HTTPS reverse-proxy/web-server config and certificate setup
+srcs/.env: runtime configuration and credentials injected into containers
+Makefile: single command interface for create/up/down/clean/fclean workflows

*-Main design choices*
+Separate containers per concern: database, application runtime, and web server
+Internal Docker bridge network for container-to-container communication
+TLS termination at nginx, with php requests forwarded to wordpress (php-fpm)
+Persistent storage for database and WordPress files using Docker-managed volumes backed by host paths
+Automated bootstrap scripts so first startup initializes services without manual in-container setup

*-Virtual Machines vs Docker*
+Virtual machines emulate full operating systems and require more resources (memory, storage, boot time).
+Docker containers share the host kernel, start faster, and are lighter to distribute and rebuild.
+For this project, Docker is chosen for quick iteration, reproducible builds, and service isolation without full VM overhead.

*-Secrets vs Environment Variables*
+Environment variables are simple and practical for a school project and local setup.
+Docker secrets are safer for production because values are not exposed the same way as plain env files.
+This project currently uses environment variables from srcs/.env for simplicity and compatibility with the current scripts.

*-Docker Network vs Host Network*
+Host network mode removes network isolation and exposes services directly on host interfaces.
+Docker bridge networking gives isolated service-to-service communication and explicit published ports.
+This project uses a dedicated Docker bridge network so services can resolve each other by name (mariadb, wordpress, nginx) while only exposing port 443 externally.

*-Docker Volumes vs Bind Mounts*
+Bind mounts directly map host paths and are useful when exact host location control is needed.
+This project uses Docker named volumes configured with bind-backed host paths (/home/.../data) to keep persistent data in predictable locations while retaining compose-level volume management.

**Instructions**
*-Dependencies (full list from project scan)*
Host machine dependencies:
+Linux (Debian 12/bookworm tested)
+A user with sudo access
+git
+make
+Docker Engine (docker.io package on Debian)
+Docker Compose with docker-compose command available (Makefile uses docker-compose directly)
+Internet access (images/packages/WordPress download during build)

Project-specific required configuration:
+srcs/.env must exist and contain at minimum:
DOMAIN
MARIADB_ROOT_PASSWORD
MARIADB_DATABASE
MARIADB_USER
MARIADB_PASSWORD
WORDPRESS_DB_NAME
WORDPRESS_DB_HOST (must be mariadb)
WORDPRESS_DB_USER
WORDPRESS_DB_PASSWORD
+Makefile variable LOGIN must match your local Linux username
+Nginx server_name in srcs/requirements/nginx/tools/default.conf should match your DOMAIN

Dependencies installed automatically inside containers (no host install needed):
+MariaDB container: mariadb-server
+WordPress container: php8.2-fpm, php8.2-mysql, php8.2-cli, php8.2-mbstring, curl, mariadb-client, wp-cli
+Nginx container: nginx, openssl

*-Install on a fresh Linux machine*
1. Use Debian 12 bookworm if possible.
2. Ensure your apt sources are set to:
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
3. Install required host packages:
su
apt update
apt install -y sudo git make docker.io docker-compose
4. Add your user to sudoers if needed, then exit root:
YourUserName ALL=(ALL:ALL) ALL
exit
5. Clone the repository and enter it:
git clone https://github.com/Damian-Bozic/Inception
cd Inception
6. Edit Makefile and set LOGIN to your Linux username.
7. Edit srcs/.env and fill all variables listed above.
8. If your domain changed, update nginx server_name in srcs/requirements/nginx/tools/default.conf.
9. Run make.
10. If make asks for reboot (docker group assignment), reboot and run make again.
11. Verify containers:
docker ps

*-Install on a machine that already has dependencies*
1. Confirm these are already available: sudo, git, make, docker, docker-compose.
2. Clone the repository and enter it:
git clone https://github.com/Damian-Bozic/Inception
cd Inception
3. Edit Makefile and set LOGIN to your Linux username.
4. Edit srcs/.env and fill all required variables.
5. If needed, update nginx server_name in srcs/requirements/nginx/tools/default.conf to match DOMAIN.
6. Run make.
7. If prompted for reboot, reboot once and run make again.
8. Verify status:
docker ps

If you encounter errors, inspect container logs:
docker logs mariadb
docker logs wordpress
docker logs nginx

*-Running*
+Run "make" in the Inception folder. It can take some time. Once you see green text showing that mariadb, wordpress, and nginx is running, you should be able to visit the site at YourUserName.42.fr
+If you encounter errors you can use the command "docker ps" to check if all three containers are running ok, or something like "docker logs containerName" to inspect their logs.
*-Turning off*
+Run "make down". This should turn everything off, while keeping any data stored for the next time you start the server again.
*-Deleting all data*
+Run "make fclean". /!\ THIS IS A DESTRUCTIVE ACTION /!\ It will clear the databases removing all saved data.

**Resources**

*-Classic references (documentation, articles, tutorials)*
+Docker official docs: https://docs.docker.com/
+Docker Compose file reference: https://docs.docker.com/compose/compose-file/
+Docker networking overview: https://docs.docker.com/network/
+Docker storage (volumes, bind mounts, tmpfs): https://docs.docker.com/storage/
+Docker secrets: https://docs.docker.com/engine/swarm/secrets/
+Nginx docs: https://nginx.org/en/docs/
+MariaDB docs: https://mariadb.com/kb/en/documentation/
+WordPress docs: https://wordpress.org/documentation/
+PHP-FPM docs: https://www.php.net/manual/en/install.fpm.php
+OpenSSL docs: https://www.openssl.org/docs/

*-How AI was used in this project*
+AI was used to turn rough implementation ideas into clear written configuration and documentation across multiple file formats.
+AI support was used for in-depth debugging inside VS Code (Codex/Copilot workflow), especially when tracing issues across Dockerfiles, shell scripts, nginx config, and compose setup.
+Because this was a first deep exposure to both web stack architecture and containerization, AI was used as a technical assistant for explanation, troubleshooting strategy, and faster iteration.
+The final technical decisions, integration choices, testing, and validation remained manual.
+Personal reflection: without AI-assisted debugging and writing support, this project would likely not have been completed within the available deadline window.

**Additional Info**
*-Usage examples*
*-feature lists*