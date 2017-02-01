FROM php:7.1-apache

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

# Install needed php extension: mcrypt
RUN apt-get install -y \
    libmcrypt-dev && \
    docker-php-ext-install -j$(nproc) mcrypt

# Install needed php extension: memcached
RUN apt-get install -y \
    libmemcached-dev && \
    curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

# Install OCI-8
# RUN docker-php-ext-install -j$(nproc) oci8

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

# Utility packages
RUN apt-get install -y vim

# Clean up unneccessary package information
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean all

COPY resources/usr/local/etc/php/php.ini /usr/local/etc/php/

# Set up Apache
RUN a2enmod rewrite

COPY resources/etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html/Symfony

# Create user to run webserver and shell commands as
# These need to be the same because the web app requires writable access to many
# directories
RUN useradd --create-home --uid 5000 --shell /bin/bash limsuser && \
    usermod --lock limsuser && \
    chown -R limsuser:limsuser ~limsuser/

#
# a+r on /root/.bash_profile to prevent error message when doing su -p - limsuser in shell commands
#
RUN echo "Configuring directories..." \
    && mkdir -p /var/lims/composer/vendor \
    && mkdir -p /var/lims/composer/cache \
    && mkdir -p /var/lims/composer/bin \
    && mkdir -p /var/lims/symfony/bootstrap \
    && mkdir -p /var/lims/symfony/cache \
    && mkdir -p /var/lims/symfony/logs \
    && mkdir -p /var/lims/symfony/www \
    && mkdir -p /var/lims/symfony/sessions \
    && mkdir -p /var/lims/datastore \
    && mkdir -p /var/lims/zanmodules/smarty \
    && mkdir -p /var/lims/environment \
    && mkdir -p /var/lims/external-drives/n/projects \
    \
    && chown -R limsuser:limsuser /var/lims \
    && echo "DONE"

COPY resources/etc/apache2/envvars /etc/apache2/

COPY resources/root/docker-entrypoint.sh /root/
COPY resources/usr/local/bin/dockerlims-shell /usr/local/bin/
COPY resources/usr/local/bin/dockerlims-test /usr/local/bin/

COPY resources/var/lims/setup/legacy-setup.sql /var/lims/setup/
COPY resources/var/lims/setup/setup.sql /var/lims/setup/

COPY resources/var/lims/environment/test /var/lims/environment/

COPY resources/home/limsuser/.zan/zanmodules-defaults /home/limsuser/.zan/
COPY resources/home/limsuser/bin/auto-sf-console /home/limsuser/bin/
COPY resources/home/limsuser/.profile /home/limsuser/

# NOTE: must use json syntax process is not started in a subshell (and signals are passed correctly)
ENTRYPOINT ["/root/docker-entrypoint.sh"]