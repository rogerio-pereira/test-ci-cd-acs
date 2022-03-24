#!/bin/bash

# ssh key
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKcUTIqFph2chK+QRt15NbD9fRLqcF4UHHbdEv8k1XPxvlYir8SBGCb+m9XXV/JHyqZP2uyPnDd47xnnX19L03Tqm6YDiTz1h/eFbOwe+8R3M1War6cGWWKpQqVwo0FUrjVfwkqnvdMTP490x2/SNiwGrwU9IU1YfX2LxiPQmWC1R7e6OR4kWu8mB2Yu8u9puq8gJt334s9DHEAmqmbdXZMYwWsaLaNxIV/tbWWj2DDanyyxsL3vyuvln496iIuYzcw4HvSh0ZtnJhX5MjSL7tYCqGKCVNkpNZ7zo8csvQ3lW2u2IcFZEo1M50EwQOVd1N3CV0B+hOW2qHC1eZegrUlWExAtQ3el7ZRSfr0jNTjDOGDvHQasgy3KbM5VVQtLFeMGaaYimOJojTQ8NRbUFDZ1AJMuQKv/GktXgOHztplrw6udEcy5oa0L0ARayFM8sRezCa2oUZnNz06RvMPd73xWH+WG8pAk+wO4Gy8RHKpK2CUcxRvv+1GIQAl1mewHPo+tbt0ZNdUjg/8oMshzkZkxvyHCvW9XliIVNmtKGM6aMj+tXy2gNVm8phqfanWSVr8MjCU3xcvSturnMeNzAUReqanubbvG+aJkCwIYWDwhPS9aI9WqyfL4TIWdWI9okFpgZVK3htbLhIg28nSft2LzZqB3YeAGMk/NA5M3q3hQ== rpereira@acslabtest.com" >> ~/.ssh/authorized_keys
chown -R $USER:$USER ~/.ssh

#updates
sudo apt-get update
sudo apt-get upgrade -y

#apt-get
sudo apt install apache2 git qpdf npm php sqlite3 libapache2-mod-php php-mbstring php-xmlrpc php-soap php-gd php-xml php-cli php-zip php-bcmath php-tokenizer php-json php-pear php-curl php-redis php7.4-zip php-mysql php-sqlite3 -y

#softwares
cd /tmp
wget -q0- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
source ~/.bashrc
npm cache clean -f
npm install -g n
n stable
source ~/.bashrc
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '906a84df04cea2aa72f40b5f787e49f22d4c2f19492ac310e8cba5b96ac8b64115ac402c8cd292b8a03482574915d1a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y

#app
cd /var/www
sudo git config --system core.longpaths true
git clone https://github.com/rogerio-pereira/test-ci-cd-acs.git ./mahi
sudo chown www-data:www-data -R mahi
sudo find mahi -type f -exec chmod 644 {} \;
sudo find mahi -type d -exec chmod 755 {} \;
cd mahi
cp .env.example .env
touch database/database.sqlite
composer install --no-interaction
php artisan key:generate
php artisan migrate

#virtualhost
printf "<VirtualHost *:80>\n    ServerAdmin webmaster@localhost\n    DocumentRoot /var/www/mahi/public\n\n    <Directory \"/var/www/mahi/public\">\n        Options FollowSymLinks MultiViews\n        Order Allow,Deny\n        Allow from all\n        ReWriteEngine On\n    </Directory>\n\n    ErrorLog \${APACHE_LOG_DIR}/error.log\n    CustomLog \${APACHE_LOG_DIR}/access.log combined\n</VirtualHost>\n" > /etc/apache2/sites-available/mahi.conf

#apache
sudo a2dissite 000-default
sudo a2ensite mahi
sudo a2enmod rewrite
sudo service apache2 restart

#reboot
reboot