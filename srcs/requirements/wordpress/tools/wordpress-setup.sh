#!/bin/bash
su -s /bin/bash www-data -c "cd /var/www/html && wp core download"
su -s /bin/bash www-data -c "rm -fr /var/www/html/index.html"
echo "WordPress container started"
