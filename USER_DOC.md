This file has been created as end-user documentation for the Inception stack.

**USER_DOC**
*-What services are provided*
This project runs a 3-service web stack inside Docker:
+Nginx (HTTPS web server on port 443)
+WordPress (PHP-FPM application service)
+MariaDB (database service for WordPress)
All services communicate through an internal Docker network.

*-How to start and stop the project*
From the repository root:
+Start/build: make
+Stop containers (keep data): make down
+Cleanup Docker artifacts: make clean
+Full cleanup including project data: make fclean

*-How to access the website and admin panel*
Open your browser and go to:
+Website: https://YourLogin.42.fr
+Admin panel: https://YourLogin.42.fr/wp-admin
Notes:
+YourLogin.42.fr must match LOGIN from the Makefile.
+DOMAIN in srcs/.env and server_name in nginx default.conf should match.
+A self-signed certificate is used, so browser warnings are expected.

*-Where to find and manage credentials*
Credentials are stored in srcs/.env.
Required variables include:
+DOMAIN
+MARIADB_ROOT_PASSWORD
+MARIADB_DATABASE
+MARIADB_USER
+MARIADB_PASSWORD
+WORDPRESS_DB_NAME
+WORDPRESS_DB_HOST
+WORDPRESS_DB_USER
+WORDPRESS_DB_PASSWORD
Credential management recommendations:
+Restrict permissions on srcs/.env
+Do not publish real secrets in public repositories
+Rotate passwords if credentials are exposed

*-How to verify services are running correctly*
Use the following checks:
+docker ps (should show mariadb, wordpress, nginx)
+docker logs mariadb
+docker logs wordpress
+docker logs nginx
+Visit https://YourLogin.42.fr
+Visit https://YourLogin.42.fr/wp-admin
