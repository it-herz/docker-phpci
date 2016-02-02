#!/bin/bash

mkdir /root/.ssh
ln -s /deploy/config /root/.ssh/config
chmod 600 /deploy/*

eval "$(ssh-agent -s)"

H=`cat /deploy/config | grep "Hostname\s" | awk -F' ' '{ print $2 }' `
P=`cat /deploy/config | grep "Port\s" | awk -F' ' '{ print $2 }' `
I=`cat /deploy/config | grep "IdentityFile\s" | awk -F' ' '{ print $2 }' `
LEN=${#H[@]}
(( LEN = LEN - 1 ))
for A in `seq 0 $LEN`
do
  PS=${P[$A]}
  HS=${H[$A]}
  IS=${I[$A]}
#check for existense
  ssh-add $IS
  cat /root/.ssh/known_hosts | grep $HS | grep $PS
  if [ $? -ne 0 ]
  then
#add to known_hosts
    ssh-keyscan -t rsa -p $PS $HS >> ~/.ssh/known_hosts
  fi
done

if [ ! -f /initialized ]
then
  RC=1
  while [ $RC != 0 ]
  do
    mysql -u $MYSQL_USER --password="$MYSQL_PASSWORD" -h $MYSQL_HOST -e 'CREATE DATABASE IF NOT EXISTS phpci;'
    RC=$?
    sleep 3
  done

#patch for PHPUnit Plugin
  sed -i "s~getLastOutput~getLastError~g" /var/www/html/PHPCI/Plugin/PhpUnit.php
  sed -i "s~--tap~--log-tap php://stderr~g" /var/www/html/PHPCI/Plugin/PhpUnit.php
  sed -i "/public function getLastOutput/i \    public function getLastError() \{ return \$this->commandExecutor->getLastError();}" /var/www/html/PHPCI/Builder.php

#patch for !quiet mode (executor)
  sed -i "s/(\$this->quiet)/(!\$this->quiet)/g" /var/www/html/PHPCI/Helper/BaseCommandExecutor.php

#Add repository for maven plugin
  cd /var/www/html
  cp composer.json 1.json
  jshon -F 1.json -n [] -n {} -s vcs -i type -s http://git.herzen.spb.ru/phpci/maven.git -i url -i 0 -n {} -s vcs -i type -s http://git.herzen.spb.ru/phpci/rocketeer.git -i url -i 1 -n {} -s vcs -i type -s http://git.herzen.spb.ru/phpci/symfony3-plugin.git -i url -i 2 -i repositories >composer.json

#Apply russian localization
  cd /
  ./localize.sh

  touch /initialized
fi
mkdir -p /root/.m2
ln -s /settings.xml /root/.m2/settings.xml
echo "$TIMEZONE" >/etc/timezone && dpkg-reconfigure -f noninteractive tzdata
composer self-update
dep self-update
npm update -g

echo '{ "allow_root": true }' >/root/.bowerrc

cd /var/www/html
./console phpci:update
composer config -g github-oauth.github.com $GITHUB_TOKEN
composer require itherz/phpci-rocketeer:dev-master
composer require itherz/phpci-maven:dev-master
composer require mindteam/phpci-symfony3-plugin:dev-master
composer require thijskok/phpci-bower-plugin:dev-master
composer require upassist/phpci-deployer
composer update

rm /var/www/html/vendor/composer.lock
composer update

chmod 777 /var/www/html/PHPCI/config.yml

./daemonise phpci:daemonise
