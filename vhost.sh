#!/bin/bash

# Verifica se o script está sendo executado com permissões de superusuário
if [ "$EUID" -ne 0 ]; then
  echo "Este script precisa ser executado com permissões de superusuário (root)."
  exit 1
fi

# Solicita informações ao usuário
read -p "Digite o nome do domínio (exemplo.com): " DOMAIN
read -p "Digite o caminho completo para o diretório do site (/var/www/$DOMAIN): " WEB_ROOT

# Criação do diretório do site
mkdir -p $WEB_ROOT
chown -R www-data:www-data $WEB_ROOT

# Criação do arquivo de configuração do vhost
cat > /etc/nginx/sites-available/$DOMAIN <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /var/log/nginx/$DOMAIN-access.log;
    error_log /var/log/nginx/$DOMAIN-error.log;

    include /etc/nginx/snippets/security.conf;
}
EOF

# Criação do link simbólico para ativar o vhost
ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

# Testa a configuração do Nginx
nginx -t

# Reinicia o Nginx para aplicar as alterações
systemctl restart nginx

echo "Virtual host para $DOMAIN criado com sucesso!"
