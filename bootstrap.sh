#!/usr/bin/env bash
MYSQL_PASSWORD='VG1234!@#$'

### !!!!!!!!!! DO NOT UNCOMMENT THESE LINES THEY INSTALL WRONG PASSENGER VERSION !!!!!!!!!!!!! ###
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
#apt-get install apt-transport-https ca-certificates
##### !!!! Only add ONE of these lines, not all of them !!!! #####
# Ubuntu 14.04
#echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' > /etc/apt/sources.list.d/passenger.list
# Ubuntu 12.04
#echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main' > /etc/apt/sources.list.d/passenger.list
#chown root: /etc/apt/sources.list.d/passenger.list
#chmod 600 /etc/apt/sources.list.d/passenger.list

#install needed modules via apt
if [ ! -f /var/log/aptsetup ];
then

debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"

apt update
apt upgrade -y
apt autoremove -y

apt install nginx-full -y
echo "ServerName localhost" | tee /etc/apache2/httpd.conf > /dev/null
echo "Include httpd.conf" | tee -a /etc/apache2/apache2.conf > /dev/null

apt install -y \
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

