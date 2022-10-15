ARG PHP_VERSION=8.1.11
ARG REDIS_EXT_VERSION=5.3.7
ARG XDEBUG_EXT_VERSION=3.1.5

FROM php:${PHP_VERSION}-fpm-alpine AS production
ARG REDIS_EXT_VERSION

# Update image packages
RUN apk update && apk upgrade

# Install dependencies, only dependencies installed with pecl need to be enabled manually
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install redis-$REDIS_EXT_VERSION \
    && docker-php-ext-enable redis \
    && docker-php-ext-install mysqli

# Use the production configuration
COPY ./docker/php/production/php.ini /usr/local/etc/php/php.ini

# Copy files needed by the app
COPY ./public/ /var/www/html/public/
COPY ./src/ /var/www/html/src/

# Make the app run as an unprivileged user for additional security
USER www-data

FROM php:${PHP_VERSION}-fpm-alpine AS development
ARG REDIS_EXT_VERSION
ARG XDEBUG_EXT_VERSION

# Update image packages
RUN apk update && apk upgrade

# Install dependencies and development tools, only dependencies installed with pecl need to be enabled manually
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install redis-$REDIS_EXT_VERSION xdebug-$XDEBUG_EXT_VERSION \
    && docker-php-ext-enable redis xdebug \
    && docker-php-ext-install mysqli

# Make the app run as the most common uid:gid to avoid permission mismatches when executing commands inside the container
USER 1000:1000
