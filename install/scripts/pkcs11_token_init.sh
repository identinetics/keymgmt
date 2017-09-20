#!/usr/bin/env bash

set -e
 
[ -z "$PYKCS11PIN" ] && export PYKCS11PIN='Secret.1'
[ -z "$SOPIN" ] && export SOPIN='Secret.2'

echo 'Initializing Token'
pkcs11-tool --module $PYKCS11LIB --init-token --label test --pin $PYKCS11PIN --so-pin $SOPIN

echo 'Initializing User PIN'
pkcs11-tool --module $PYKCS11LIB --login --init-pin --pin $PYKCS11PIN --so-pin $SOPIN

echo 'Generating RSA key'
pkcs11-tool --module $PYKCS11LIB --login --keypairgen --key-type rsa:2048 -d 1 --label test --pin $PYKCS11PIN

echo 'Checking objects on card'
pkcs11-tool --module $PYKCS11LIB --login --list-objects --pin $PYKCS11PIN
