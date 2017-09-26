#!/usr/bin/env bash
set -e

# exit when docker sends SIGTERM (aka docker stop)
onTerminate() {
    echo "Got SIGTERM, stopping apache..."
    kill `cat /var/run/httpd/httpd.pid`
    exit
}
trap 'onTerminate' SIGTERM

# Ensure limsuser uid and gid matches environment configuration (see docker-compose.yml)
: ${DOCKERLIMS_SHELL_UID:=5000}
echo "Switching to UID ${DOCKERLIMS_SHELL_UID}"
usermod -u ${DOCKERLIMS_SHELL_UID} limsuser
groupmod -g ${DOCKERLIMS_SHELL_UID} limsuser

# Ensure limsuser will have permissions on all lims-related files
chown -R limsuser:limsuser /var/lims/

#
# Start apache in the foreground as the limsuser
#
/usr/sbin/httpd -D FOREGROUND &
wait $!
