#!/usr/bin/env bash

#
# use "docker volume" to create or find composer cache volume
#
set -e

docker build --force-rm --tag lims-test:dev .

docker run --rm \
    --name lims_test \
    --entrypoint /usr/local/bin/dockerlims-test \
    -v docker_composer_cache:/var/lims/composer/cache \
    -v /Volumes/TBA-data/projects/stowers/lims-docker/:/var/www/html/ \
    lims-test:dev


