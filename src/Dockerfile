FROM php:7.4-apache

# Install necessary extensions and tools
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    libicu-dev \
    libcurl4-openssl-dev
RUN docker-php-ext-install pdo pdo_mysql bcmath
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install intl
RUN apt-get update && apt-get upgrade -y
RUN docker-php-ext-install curl
RUN docker-php-ext-install imagick
RUN docker-php-ext-install gd
RUN docker-php-ext-install simplexml
RUN docker-php-ext-install redis
RUN docker-php-ext-install dom
RUN docker-php-ext-install libxml
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini
RUN docker-php-ext-install json
RUN docker-php-ext-install mbstring
RUN apt-get update && apt-get install -y supervisor

# Copy Apache and SSL configurations
COPY apache-config.conf ./etc/apache2/sites-available/000-default.conf
COPY ./ssl/server.crt ./etc/ssl/certs/server.crt
COPY ./ssl/server.key ./etc/ssl/certs/server.key

# Enable Apache modules and SSL
RUN a2enmod proxy proxy_http ssl
RUN a2ensite default-ssl

# Copy the SSL generation script and make it executable
COPY generate_ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate_ssl.sh

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the project files
WORKDIR /var/www/html
COPY src .

# Install project dependencies
RUN composer install --no-scripts

# Start Supervisor
CMD ["/usr/bin/supervisord", "-n"]
