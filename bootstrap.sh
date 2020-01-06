#!/usr/bin/env bash

#install needed modules via apt
if [ ! -f /var/log/aptsetup ];
then

apt-get update
apt-get upgrade -y
apt-get autoremove -y

apt-get install nginx-full -y

apt-get install -y \
       mariadb-server \
       php7.2 php7.2-common php7.2-cli php7.2-fpm \
       php-mysql php-gd php-curl php-pear php-json php-bcmath php-dev php-iconv php-intl php-mbstring php-opcache php-pdo php-soap php-xml php-zip \
       git git-core

    touch /var/log/aptsetup
fi



# Setup database
if [ ! -f /var/log/databasesetup ];
then
    echo "DROP DATABASE IF EXISTS vagrant"
    echo "CREATE DATABASE IF NOT EXISTS vagrant;"
    echo "CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'vagrant\!\@\#\$';"
    echo "GRANT ALL PRIVILEGES ON vagrant.* TO 'vagrant'@'localhost';"
    echo "FLUSH PRIVILEGES;"

    touch /var/log/databasesetup

    if [ -f /var/sqldump/database.sql ];
    then
        mysql vagrant < /var/sqldump/database.sql
    fi
fi

#Setup Apache
if [ ! -f /var/log/webserversetup ];
then

    touch /var/log/webserversetup
fi

# Install Composer
if [ ! -f /var/log/composersetup ];
then
    curl -s https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer # Make Composer available globally

    touch /var/log/composersetup
fi

#copy Vhosts
rm /etc/nginx/sites-enabled/default
cp /vagrant/sites-conf/*.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/*.conf /etc/nginx/sites-enabled/

service nginx restart

