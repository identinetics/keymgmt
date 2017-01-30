#!/bin/bash
# startup script used in entrypoint of the docker container

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

if [ $(id -u) -ne 0 ]; then
    sudo="sudo"
fi

logger -p local0.info "Starting Smartcard Service"
$sudo /usr/sbin/pcscd

