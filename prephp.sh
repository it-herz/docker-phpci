#!/bin/bash

sed -i -e "s~;date.timezone\s*=.*~date.timezone=$TIMEZONE~g" /etc/php/7.0/cli/php.ini

sed -i "s/DB_HOST/$MYSQL_HOST/g" /var/www/html/PHPCI/config.yml
sed -i "s/DB_USER/$MYSQL_USER/g" /var/www/html/PHPCI/config.yml
sed -i "s/DB_NAME/$MYSQL_DBNAME/g" /var/www/html/PHPCI/config.yml
sed -i "s/DB_PASSWORD/$MYSQL_PASSWORD/g" /var/www/html/PHPCI/config.yml
sed -i "s~URL~$URL~g" /var/www/html/PHPCI/config.yml

sed -i "s/BEANSTALK_HOST/$BEANSTALK_HOST/g" /var/www/html/PHPCI/config.yml
sed -i "s/BEANSTALK_QUEUE/$BEANSTALK_QUEUE/g" /var/www/html/PHPCI/config.yml

RAND=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32`
sed -i "s/RANDOM_MD5/$RAND/g" /var/www/html/PHPCI/config.yml
sed -i "s/SMTP_HOST/$SMTP_HOST/g" /var/www/html/PHPCI/config.yml
sed -i "s/SMTP_PORT/$SMTP_PORT/g" /var/www/html/PHPCI/config.yml
sed -i "s/SMTP_USER/$SMTP_USER/g" /var/www/html/PHPCI/config.yml
sed -i "s/SMTP_PASSWORD/$SMTP_PASSWORD/g" /var/www/html/PHPCI/config.yml
sed -i "s/SMTP_FROM/$SMTP_FROM/g" /var/www/html/PHPCI/config.yml
sed -i "s/SMTP_DEFAULTTO/$SMTP_DEFAULTTO/g" /var/www/html/PHPCI/config.yml

