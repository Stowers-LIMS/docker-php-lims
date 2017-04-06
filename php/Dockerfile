FROM php:7.1-apache

MAINTAINER "Eric Poe" <eric.poe@gmail.com>

# Set TERM environment var - so terminal cmds like `top` work
ENV TERM dumb

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
    # Included applications
    git \
    mysql-client \
    php-pear \
    tree \
    vim \
    # Needed for building extensions
    # For gd
    libpng-dev \
    # For imap
    libc-client-dev \ 
    libkrb5-dev \
    # For intl
    libicu-dev \
    # For ldap
    libldap2-dev \
    # For mcrypt
    libmcrypt-dev \
    # For memcached
    libmemcached-dev \
    # For PDO MSSQL/SYBASE
    freetds-common \
    freetds-dev \
    # For zip
    zlib1g-dev

# Clean up unneccessary package information
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean all

# Install php extension: gd
# Used by molbio to generate images and sparklines
RUN docker-php-ext-install -j$(nproc) gd

# Install php extension: imap
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install -j$(nproc) imap

# Install php extension: intl
RUN docker-php-ext-install -j$(nproc) intl

# Install php extension: ldap
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install -j$(nproc) ldap

# Install php extension: mcrypt
RUN docker-php-ext-install -j$(nproc) mcrypt

# Install php extension: memcached
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/v3.0.3.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

# Install php extension: OCI-8
# RUN docker-php-ext-install -j$(nproc) oci8

# Enable Opcache
RUN docker-php-ext-enable opcache

# Install php extension: PDO
RUN docker-php-ext-install -j$(nproc) pdo

# Install php extension: PDO: MSSQL/SYBASE
RUN ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a && \
    ldconfig -v && \
    docker-php-ext-install -j$(nproc) pdo_dblib

# Install php extension: PDO: MySQL
RUN docker-php-ext-install -j$(nproc) pdo_mysql

# Install php extension: mysqli (used by the legacy system)
RUN docker-php-ext-install mysqli

# Install php extension: zip
RUN docker-php-ext-install -j$(nproc) zip

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