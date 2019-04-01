#!/bin/bash
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# main entrypoint of the docker container

source /opt/venv/py3/bin/activate

if [ $(id -u) -ne 0 ]; then
    echo 'Env variable PYKCS11LIB is set for root!'
    sudo='sudo'
fi

/scripts/startup_p11.sh

exec bash