FROM php:7.2-apache

ENV APACHE_DOCUMENT_ROOT ${APACHE_DOCUMENT_ROOT:-/var/www/html}

RUN apt update

# Required for zip; php zip extension; png; node; vim; gd; gd; postgres
RUN apt install -y zip zlib1g-dev libpng-dev gnupg vim libfreetype6-dev libjpeg62-turbo-dev libpq-dev

# PHP extensions - pdo-mysql; mysqli; postgres; zip (used to download packages with Composer); mbstring;
RUN docker-php-ext-install pdo_mysql mysqli pdo_pgsql zip mbstring

# GD (Image library)
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nodejs (comes with npm)
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Copy custom apache virtual host configuration into container
COPY apache.conf /etc/apache2/sites-available/000-default.conf

# Set apache root permission
RUN chown -R www-data:www-data /var/www

# Activate Apache mod_rewrite
RUN a2enmod rewrite

# Cleanup
RUN apt clean
RUN apt autoclean
