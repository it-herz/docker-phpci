#!/bin/bash

mkdir /root/.ssh
mkdir -p /deploy
touch /deploy/config
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
    mysql -u $MYSQL_USER --password="$MYSQL_PASSWORD" -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DBNAME;"
    RC=$?
    sleep 3
  done

#Add repository for maven plugin
  cd /var/www/html
  cp composer.json 1.json
  jshon -F 1.json -n {} -n false -i secure-http -i config -n [] -n {} -s vcs -i type -s http://git.herzen.spb.ru/phpci/maven.git -i url -i 0 -n {} -s vcs -i type -s http://git.herzen.spb.ru/phpci/rocketeer.git -i url -i 1 -n {} -s vcs -i type -s http://git.herzen.spb.ru/phpci/symfony3-plugin.git -i url -i 2 -i repositories >composer.json
  rm 1.json

  touch /initialized
fi
mkdir -p /root/.m2
ln -s /settings.xml /root/.m2/settings.xml
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
dpkg-reconfigure -f noninteractive tzdata
composer self-update
dep self-update
npm update -g

echo '{ "allow_root": true }' >/root/.bowerrc
echo "Host $GITHOST" > /root/.ssh/config
echo "  Port $GITPORT" >> /root/.ssh/config
cd /var/www/html
echo $GITHUB_TOKEN
composer config -g github-oauth.github.com $GITHUB_TOKEN
composer require sebastian/phpcpd
composer require itherz/phpci-rocketeer:dev-master
composer require itherz/phpci-maven:dev-master
composer require mindteam/phpci-symfony3-plugin:dev-master
composer require thijskok/phpci-bower-plugin:dev-master
composer require upassist/phpci-deployer
composer require robmorgan/phinx
composer config repositories.deployphp git "https://github.com/ket4yii/recipes.git"
composer require deployphp/recipes:dev-phinx-recipe
composer require ket4yii/phpci-deployer-plugin:dev-identity_key_feature

composer install --prefer-source
composer update
./console phpci:update

chmod 777 /var/www/html/PHPCI/config.yml

exit 0
