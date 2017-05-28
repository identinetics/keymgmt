#!/usr/bin/env bash

HSMUSBDEVICE='Aladdin Knowledge Systems Token JC'  # output of lsusb
HSMP11DEVICE='eToken 5110'                         # output of pkcs11-tool --list-token-slots

set -e

echo 'Test 20: HSM USB device'
lsusb | grep "$HSMUSBDEVICE"
if (( $? != 0 )); then
    echo 'HSM USB device not found - failed HSM test'
    exit 1
fi


echo 'Test 21: PKCS11 driver lib'
if [[ -z ${PYKCS11LIB+x} ]]; then
    echo 'PYKCS11LIB not set - failed HSM test'
    exit 1
fi


if [[ -e ${PYKCS11LIB} ]]; then
    echo 'PYKCS11LIB not found'
    exit 1
fi


if [[ -z ${PYKCS11PIN+x} ]]; then
    echo 'PYKCS11PIN not set - failed HSM test'
    exit 1
fi


echo 'Test 22: PCSCD'
if (( $(pidof /usr/sbin/pcscd) > 0 )); then
    echo 'pcscd process not running'
    exit 1
fi


echo 'Test 23: HSM Token'
pkcs11-tool --module $PKCS11_CARD_DRIVER --list-token-slots | grep "$HSMP11DEVICE"
if (( $? > 0 )); then
    echo 'HSM Token not connected'
    exit 1
fi


echo 'Test 24: Login to HSM'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --pin $PYKCS11PIN --show-info \
    | grep 'present token'
if (( $? > 0 )); then
    pkcs11-tool --module $PKCS11_CARD_DRIVER --login --pin $PYKCS11PIN --show-info
    echo 'Login failed'
    exit 1
fi


echo 'Test 25: List certificate(s)'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --pin $PYKCS11PIN --list-objects  --type cert \
    | grep 'Certificate Object'
if (( $? > 0 )); then
    echo 'No certificate found'
    exit 1
fi


echo 'Test 26: List private key(s)'
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --pin $PYKCS11PIN --list-objects  --type privkey \
    | grep 'Private Key Object'
if (( $? > 0 )); then
    echo 'No private key found'
    exit 1
fi


echo 'Test 27: Sign test data'
echo "foo" > /tmp/bar
pkcs11-tool --module $PKCS11_CARD_DRIVER --login --pin $PYKCS11PIN \
    --sign --input /tmp/bar --output /tmp/bar.sig
if (( $? > 0 )); then
    echo 'Signature failed'
    exit 1
fi


echo 'Test 28: List objects using PyKCS11'
/tests/pykcs11_getkey.py --pin=$PYKCS11PIN --slot=0 --lib=$PKCS11_CARD_DRIVER \
    | grep -a -c '=== Object '
if (( $? > 0 )); then
    echo 'Listing HSM token object with PyKCS11 lib failed'
    exit 1
fi


