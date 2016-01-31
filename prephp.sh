#!/bin/bash

sed -i -e "s~;date.timezone\s*=.*~date.timezone=$TIMEZONE~g" /etc/php/7.0/fpm/php.ini
sed -i -e "s~;date.timezone\s*=.*~date.timezone=$TIMEZONE~g" /etc/php/7.0/cli/php.ini

sed -i "s/DB_HOST/$MYSQL_HOST/g" /var/www/html/PHPCI/config.yml
sed -i "s/DB_USER/$MYSQL_USER/g" /var/www/html/PHPCI/config.yml
sed -i "s/DB_NAME/$MYSQL_NAME/g" /var/www/html/PHPCI/config.yml
sed -i "s/DB_PASSWORD/$MYSQL_PASSWORD/g" /var/www/html/PHPCI/config.yml
sed -i "s~URL~$URL~g" /var/www/html/PHPCI/config.yml
supervisorctl start php
