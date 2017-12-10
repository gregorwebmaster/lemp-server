FROM debian:stretch-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

#installation nginx server
RUN apt-get install -y nginx

RUN rm -rf /var/www/*
RUN rm /etc/nginx/sites-enabled/*

COPY docker-server/nginx_configuration/vhosts/*.conf /etc/nginx/sites-enabled/
COPY source/index.php /var/www/

#instalation MySQL
RUN apt-get -y install supervisor mysql-server

# Supervisor configuration files
ADD docker-server/install/supervisord.conf /etc/supervisor/
ADD docker-server/install/supervisor-lemp.conf /etc/supervisor/conf.d/

# Create new MySQL admin user
RUN service mysql start; mysql -u root -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'P!zza123';";mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;";

# MySQL configuration
RUN sed -i 's/bind-address/#bind-address/' /etc/mysql/my.cnf

#instalation PHP
RUN apt-get install -y php7.0-fpm

RUN apt-get -y install php7.0-opcache php7.0-fpm php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth-sasl php7.0-mcrypt mcrypt imagemagick libruby php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl memcached php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring

RUN phpenmod mcrypt
RUN phpenmod mbstring

RUN apt-get clean

EXPOSE 80 3306
CMD ["supervisord"]
