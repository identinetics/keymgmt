#!/usr/bin/env bash
#

[ -z "$PYKCS11PIN" ] && export PYKCS11PIN=Secret.1
[ -z "$SOPIN" ] && Sexport OPIN=Secret.2
echo 'Initializing Token'
pkcs11-tool --module $PYKCS11LIB --init-token --label testtoken --so-pin $SOPIN || exit -1

echo 'Initializing User PIN'
pkcs11-tool --module $PYKCS11LIB --login --init-pin --pin $PYKCS11PIN --so-pin $SOPIN

echo 'Generating RSA key'
pkcs11-tool --module $PYKCS11LIB --login --keypairgen --key-type rsa:2048 -d 1 --label testkey --pin $PYKCS11PIN || exit -1

echo 'Checking objects on card'
pkcs11-tool --module $PYKCS11LIB --login -O --pin $PYKCS11PIN || exit -1
