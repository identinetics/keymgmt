#!/usr/bin/env bash

set -e
 
[ -z "$USERPIN" ] && export USERPIN='Secret.1'
[ -z "$SOPIN" ] && export SOPIN='Secret.2'

echo 'Initializing Token'
pkcs11-tool --module $PKCS11_CARD_DRIVER --init-token --label test --pin $USERPIN --so-pin $SOPIN

echo 'Initializing User PIN'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --init-pin --pin $USERPIN --so-pin $SOPIN

echo 'Generating RSA key'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --keypairgen --key-type rsa:2048 -d 1 --label test --pin $USERPIN

echo 'Checking objects on card'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --list-objects --pin $USERPIN
