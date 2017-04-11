#!/bin/bash

# main entrypoint of the docker container

export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

if [ $(id -u) -ne 0 ]; then
    echo 'Env variable PKCS11_CARD_DRIVER is set for root!'
    sudo='sudo'
fi

logger -p local0.info "Starting PC/SC Smartcard Service"
$sudo /usr/sbin/pcscd

#logger -p local0.info "Starting HAVEGE Entropy Service"
#disabled because gpg2 --sign is failing with "signing failed: Operation cancelled"
#$sudo /usr/sbin/haveged

exec bash