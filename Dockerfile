# Development build
FROM php:fpm-alpine as base

ARG WORKFOLDER

ENV WORKPATH ${WORKFOLDER}
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS icu-dev make autoconf git libzip-dev curl \
    && docker-php-ext-install zip intl pdo_mysql opcache json mysqli \
    && pecl install apcu \
    && docker-php-ext-enable apcu mysqli

COPY docker/php/conf/php.ini /usr/local/etc/php/php.ini

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mkdir -p ${WORKPATH} \
    && chown -R www-data /tmp/ \
    && mkdir -p \
       ${WORKPATH}/var/cache \
       ${WORKPATH}/var/logs \
       ${WORKPATH}/var/sessions \
    && chown -R www-data ${WORKPATH}/var

WORKDIR ${WORKPATH}

COPY --chown=www-data:www-data . ./

## Production build
FROM base

COPY docker/php/conf/production/php.ini /usr/local/etc/php/php.ini
