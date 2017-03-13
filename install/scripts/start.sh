#!/bin/bash
set -e -o pipefail

# main entrypoint of the docker container

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

if [ $(id -u) -ne 0 ]; then
    echo 'must be root to start pcscd'
fi

logger -p local0.info "Starting Smartcard Service"
$sudo /usr/sbin/pcscd

su - livecd

exec bash