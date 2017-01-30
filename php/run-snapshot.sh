#!/usr/bin/env bash

#
# use "docker volume" to create or find composer cache volume
#
# Mounts in ~/.ssh directory are so git operations work as expected (with the correct permissions) and
# do not prompt for confirming keys. These files could be embedded in the container as well.
set -e

docker build --force-rm --tag lims-snapshot:dev .

docker run --rm \
    --name lims_test \
    --entrypoint /root/docker-entrypoint-snapshot.sh \
    -v docker_composer_cache:/var/lims/composer/cache \
    -v ~/.ssh/id_limsreadonly_rsa:/root/.ssh/id_rsa \
    -v ~/.ssh/known_hosts:/root/.ssh/known_hosts \
    lims-snapshot:dev


