FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    git unzip zip \
    libzip-dev libicu-dev libxml2-dev libonig-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    default-mysql-client \
    && docker-php-ext-install intl pdo_mysql zip bcmath soap

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g gulp-cli

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --prefer-dist --no-interaction

RUN php bin/magento setup:di:compile
RUN php bin/magento setup:static-content:deploy -f
