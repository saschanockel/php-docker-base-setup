FROM php:8.1.2-fpm-alpine AS production

# Update image packages
RUN apk update && apk upgrade

# Install dependencies, only dependencies installed with pecl need to be enabled manually
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install redis-5.3.6 \
    && docker-php-ext-enable redis \
    && docker-php-ext-install mysqli

# Use the production configuration
COPY ./docker/php/production/php.ini /usr/local/etc/php/php.ini

COPY ./public/ /var/www/html/public/
COPY ./src/ /var/www/html/src/

# Make the app run as an unprivileged user for additional security
USER www-data

FROM php:8.1.2-fpm-alpine AS development

# Update image packages
RUN apk update && apk upgrade

# Install dependencies and development tools, only dependencies installed with pecl need to be enabled manually
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-3.1.2 redis-5.3.6 \
    && docker-php-ext-enable xdebug redis \
    && docker-php-ext-install mysqli

# Make the app run as an unprivileged user for additional security
USER www-data
