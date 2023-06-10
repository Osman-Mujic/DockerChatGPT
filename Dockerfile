FROM php:7.4-apache

# Install necessary extensions and tools
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    libicu-dev \
    libcurl4-openssl-dev \
    libmagickwand-dev \
    libxml2-dev \
    build-essential \
    && apt-get clean all

RUN docker-php-ext-install pdo pdo_mysql bcmath
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install intl
RUN apt-get update && apt-get install -y --no-install-recommends \
    libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick
RUN docker-php-ext-install curl
RUN docker-php-ext-install gd
RUN docker-php-ext-install simplexml
RUN pecl install redis \
    && docker-php-ext-enable redis
RUN docker-php-ext-install dom
RUN apt-get update && apt-get install -y libxml2-dev \
    && docker-php-ext-configure xml \
    && docker-php-ext-install xml

# Download and install Xdebug
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    && wget https://xdebug.org/files/xdebug-3.1.1.tgz \
    && tar -xf xdebug-3.1.1.tgz \
    && rm xdebug-3.1.1.tgz \
    && cd xdebug-3.1.1 \
    && phpize \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -r xdebug-3.1.1 \
    && apt-get purge -y --auto-remove wget \
    && apt-get clean all

# Configure Xdebug
RUN echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN docker-php-ext-install json

RUN apt-get update && apt-get install -y supervisor

# Copy Apache and SSL configurations
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf
COPY ssl/server.crt /etc/ssl/certs/server.crt
COPY ssl/server.key /etc/ssl/certs/server.key

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

# Copy WebSocket server code to the container
WORKDIR /app
COPY websocket_server.php /app

# Install dependencies for WebSocket server
RUN apt-get install -y git

# Install dependencies using Composer for WebSocket server
RUN composer install --no-dev --optimize-autoloader

# Set the entrypoint for the container
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start Supervisor
CMD ["/usr/bin/supervisord", "-n"]
