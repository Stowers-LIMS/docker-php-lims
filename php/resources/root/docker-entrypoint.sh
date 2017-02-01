#!/usr/bin/env bash
set -e

# exit when docker sends SIGTERM (aka docker stop)
onTerminate() {
    echo "Got SIGTERM, stopping apache..."
    kill `cat /run/apache2/apache2.pid`
    exit
}
trap 'onTerminate' SIGTERM

#
# Ensure database is set up correctly
#

# Wait for database to be started...
until echo "show tables" | mysql -h db -u limsdbuser --password='limsdbpassword' limsdockerdb &> /dev/null
do
    echo "Waiting for mysql..."
    sleep 2
done

mysql -u root --password='root' -h db < /var/lims/setup/legacy-setup.sql
mysql -u root --password='root' -h db < /var/lims/setup/setup.sql

#
# Initialize container-specific files
#

# Ensure limsuser uid and gid matches environment configuration (see docker-compose.yml)
: ${DOCKERLIMS_SHELL_UID:=5000}
echo "Switching to UID ${DOCKERLIMS_SHELL_UID}"
usermod -u ${DOCKERLIMS_SHELL_UID} limsuser
groupmod -g ${DOCKERLIMS_SHELL_UID} limsuser


# Ensure limsuser will have permissions on all lims-related files
chown -R limsuser:limsuser /var/lims/

# This will install dependencies. --no-scripts is necessary because building
# the bootstrap file is another step

#todo: enable --no-scripts when PR 194 is merged
#su -p limsuser -c '/var/www/html/Symfony/bin/composer.phar install --no-scripts'

# build bootstrap file
# re-enable when this PR is merged: https://bitbucket.stowers.org/projects/LIMS/repos/symfony/pull-requests/194/overview
#su -p limsuser -c '/var/www/html/Symfony/bin/rebuild-bootstrap.sh'


# Run composer install
su -p limsuser -c '/var/www/html/Symfony/bin/composer.phar install'

#
# Start apache in the foreground as the limsuser
#
/usr/local/bin/apache2-foreground &
wait $!
