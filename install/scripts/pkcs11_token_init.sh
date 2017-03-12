#!/usr/bin/env bash
#
 
[ -z "$TOKENPW" ] && TOKENPW='secret1'
[ -z "$SecurityOfficerPIN" ] && SecurityOfficerPIN='secret2'
echo 'Initializing Token'
pkcs11-tool --module $PKCS11_CARD_DRIVER --init-token --label test --pin $TOKENPW --so-pin $SecurityOfficerPIN || exit -1

echo 'Initializing User PIN'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --init-pin --pin $TOKENPW --so-pin $SecurityOfficerPIN

echo 'Generating RSA key'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --keypairgen --key-type rsa:2048 -d 1 --label test --pin $TOKENPW || exit -1

echo 'Checking objects on card'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login -O --pin $TOKENPW || exit -1
