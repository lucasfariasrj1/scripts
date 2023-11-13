#!/bin/bash

# Atualiza o sistema
sudo apt update
sudo apt upgrade -y

# Instalação do Nginx
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Instalação do MariaDB
sudo apt install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Instalação do PHP 7.4 e PHP-FPM
sudo apt install -y php7.4-fpm php7.4-mysql php7.4-common php7.4-curl php7.4-json php7.4-zip php7.4-gd php7.4-mbstring php7.4-xml

# Configuração do PHP-FPM
sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /etc/php/7.4/fpm/php.ini
sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /etc/php/7.4/fpm/php.ini
sudo systemctl restart php7.4-fpm

# Instalação do IonCube Loader
wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -zxvf ioncube_loaders_lin_x86-64.tar.gz
sudo cp ioncube/ioncube_loader_lin_7.4.so /usr/lib/php/20190902/

# Configuração do IonCube Loader no PHP
echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" | sudo tee -a /etc/php/7.4/fpm/php.ini
sudo systemctl restart php7.4-fpm

echo "CONFIGURACOES CONCLUIDAS, SEU SERVIDOR ESTÁ PRONTO....VAMOS REINICIAR...."

# REINICIANDO
sudo reboot
