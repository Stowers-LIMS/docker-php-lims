FROM php:7.0-apache

MAINTAINER "Eric Poe" <eric.poe@gmail.com>

# Set TERM environment var - so terminal cmds like `top` work
ENV TERM dumb

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
    git \
    mysql-client \
    php-pear \
    tree

# Install needed php extension: imap
RUN apt-get install -y \
    libc-client-dev \
    libkrb5-dev && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

# Install needed php extension: intl
RUN apt-get install -y \
    libicu-dev && \
    docker-php-ext-install -j$(nproc) intl

# Install needed php extension: ldap
RUN apt-get install -y \
    libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install -j$(nproc) ldap

# Install needed php extension: memcached
RUN apt-get install -y \
    libmemcached-dev && \
    curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

# Install needed php extension: mcrypt
RUN apt-get install -y \
    libmcrypt-dev && \
    docker-php-ext-install -j$(nproc) mcrypt

# Enable Opcache
RUN docker-php-ext-enable opcache

# Install PDO
RUN docker-php-ext-install -j$(nproc) pdo

# Install PDO: MSSQL/SYBASE
RUN apt-get install -y \
    freetds-common \
    freetds-dev && \
    ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a && \
    ldconfig -v && \
    docker-php-ext-install -j$(nproc) pdo_dblib

# Install PDO: MySQL
RUN docker-php-ext-install -j$(nproc) pdo_mysql

# Install needed php extension: zip
RUN apt-get install -y \
    zlib1g-dev && \
    docker-php-ext-install -j$(nproc) zip

# Clean up unneccessary package information
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean all

COPY php.ini /usr/local/etc/php/

# Set up Apache
RUN a2enmod rewrite

WORKDIR /var/www/html
