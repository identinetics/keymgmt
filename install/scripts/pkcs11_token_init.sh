#!/usr/bin/env bash
#
 
[ -z "$TOKENPW" ] && TOKENPW='secret1'
[ -z "$SecurityOfficerPIN" ] && SecurityOfficerPIN='secret2'
echo 'Initializing Token'
pkcs11-tool --module /usr/lib64/libeToken.so --init-token --label test --pin $TOKENPW --so-pin $SecurityOfficerPIN || exit -1

echo 'Initializing User PIN'
pkcs11-tool --module /usr/lib64/libeToken.so --login --init-pin --pin $TOKENPW --so-pin $SecurityOfficerPIN

echo 'Generating RSA key'
pkcs11-tool --module /usr/lib64/libeToken.so --login --keypairgen --key-type rsa:2048 -d 1 --label test --pin $TOKENPW || exit -1

echo 'Checking objects on eToken'
pkcs11-tool --module /usr/lib64/libeToken.so --login -O --pin $TOKENPW || exit -1
