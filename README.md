This project has been created as part of the 42 curriculum by <dbozic>.

**Description**
*-Virtual Machines vs Docker*
*-Secrets vs Environmental Variables*
*-Docker Network vs Host Network*
*-Docker Volumes vs Bind Mounts*

**Instructions**
*-Installing from zero*
To install, make sure you have the following requirements:
+You are using debian 12 (bookworm) distribution of linux. (If you have something else it is ok but this guide is made for debian 12)
+You use the following sources in your /etc/apt/sources.list
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
(If you have anything else in there just comment it out)
+Install the following packages by opening terminal and running:
su
apt update
apt install git
apt install make
apt install docker.io
apt install docker-compose
apt install sudo
+Add yourself to the sudoers file by adding a line similar to:
YourUserName  ALL=(ALL:ALL) ALL
You can do that by using nano or any editor (be cautios to not soft lock yourself)
+Exit out of root by using: "exit"
(TODO there may be more things you need to install)
+Clone the git repository off github (https://github.com/Damian-Bozic/Inception) or my intra evaluation page
+move to the Inception folder by running "cd Inception"
+edit the .env file using nano or any editor. Make sure to fill everything out. WORDPRESS_DB_HOST should be named mariadb, and it is safe to name both WORDPRESS_DB_NAME and MARIADB_DATABASE the same thing (I didn't check if it matters and everything is delicate so better to do that as a precaution)
+run "make" in the terminal. It will ask you to restart your computer and use "make" again. Once done it should install everything else for you (this can take some time to build and is the most likely place errors can occur). After it is finished you should see green text showing that mariadb, wordpress, and nginx is running. (That means everything should've worked!!)
+If you encounter errors you can use the command "docker ps" to check if all three containers are running ok, or something like "docker logs containerName" to inspect their logs. 
*-Running*
+Run "make" in the Inception folder. It can take some time. Once you see green text showing that mariadb, wordpress, and nginx is running, you should be able to visit the site at YourUserName.42.fr
+If you encounter errors you can use the command "docker ps" to check if all three containers are running ok, or something like "docker logs containerName" to inspect their logs.
*-Turning off*
+Run "make down". This should turn everything off, while keeping any data stored for the next time you start the server again.
*-Deleting all data*
+Run "make fclean". /!\ THIS IS A DESTRUCTIVE ACTION /!\ It will clear the databases removing all saved data.

**Resources**

**Additional Info**
*-Usage examples*
*-feature lists*