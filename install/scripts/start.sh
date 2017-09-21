#!/bin/bash

# main entrypoint of the docker container

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

if [ $(id -u) -ne 0 ]; then
    echo 'Env variable PYKCS11LIB is set for root!'
    sudo='sudo'
fi

/startup_p11.sh

exec bash