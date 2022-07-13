#!/bin/bash

cd /tmp

apt-get install -y apache2 libapache2-mod-php mariadb-server php-mysql
apt-get install -y php-{mbstring,curl,gd,xml,intl,ldap,apcu,xmlrpc,cas,zip,bz2}
wget https://github.com/glpi-project/glpi/releases/download/10.0.2/glpi-10.0.2.tgz

mysql -uroot -pglpi -e "create database glpidb charset utf8mb4 collate utf8mb4_unicode_ci;"
mysql -uroot -pglpi -e "create user glpi_user@localhost identified by 'glpi';"
mysql -uroot -pglpi -e "grant all privileges on glpidb.* to glpi_user@localhost;"

tar xf glpi-10.0.2.tgz
rm /tmp/glpi/locales/pt_PT.*
mv /tmp/locales/pt_PT.* /tmp/glpi/locales/

mv glpi /var/www/
chmod 755 -R /var/www/glpi/
chown www-data:www-data -R /var/www/glpi/


cat <<EOF > /etc/apache2/sites-available/glpi.conf
<VirtualHost *:80>
   ServerAdmin lorenzo.verbicaro@tmlmobilidade.pt
   DocumentRoot /var/www/glpi
   ServerName glpi

   <Directory /var/www/glpi>
        Options FollowSymlinks
        AllowOverride All
        Require all granted
   </Directory>

   ErrorLog ${APACHE_LOG_DIR}/glpi_error.log
   CustomLog ${APACHE_LOG_DIR}/glpi_access.log combined
</VirtualHost>
EOF

ln -s /etc/apache2/sites-available/glpi.conf /etc/apache2/sites-enabled/glpi.conf
a2enmod expires rewrite
systemctl restart apache2