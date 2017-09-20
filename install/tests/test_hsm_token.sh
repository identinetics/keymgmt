#!/usr/bin/env bash


SCRIPT=$(basename $0)
SCRIPT=${SCRIPT%.*}
LOGDIR="/tmp/${SCRIPT%.*}"
mkdir -p $LOGDIR
echo "    Logfiles in $LOGDIR"
set +e

testid=10
echo "Test ${testid}: HSM USB device"
if [[ $SOFTHSM ]]; then
    echo "Soft HSM configured"
else
    lsusb | grep "$HSMUSBDEVICE" > $LOGDIR/test${testid}.log
    if (( $? != 0 )); then
        echo "HSM USB device not found - failed HSM test"
        cat $LOGDIR/test39.log
        exit 1
    fi
fi

let testid=testid+1
echo "Test ${testid}: PKCS11 driver lib"
if [[ -z ${PYKCS11LIB+x} ]]; then
    echo "PYKCS11LIB not set - failed HSM test"
    exit 1
fi


if [[ ! -e ${PYKCS11LIB} ]]; then
    echo "PYKCS11LIB not found"
    exit 1
fi


if [[ -z ${PYKCS11PIN+x} ]]; then
    echo "PYKCS11PIN not set - failed HSM test"
    exit 1
fi


let testid=testid+1
echo "Test ${testid}: PCSCD"
if [[ $SOFTHSM ]]; then
    echo "Soft HSM  - no pcscd needed"
else
    pid=$(pidof /usr/sbin/pcscd) > /dev/null
    if (( $? == 1 )); then
        echo "pcscd process not running"
        exit 1
    fi
fi


let testid=testid+1
echo "Test ${testid}: HSM PKCS#11 device"
pkcs11-tool --module $PYKCS11LIB --list-token-slots | grep "$HSMP11DEVICE"  > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    echo "HSM Token not connected"
    cat $LOGDIR/test39.log
    exit 1
fi


let testid=testid+1
echo "Test ${testid}: Initializing HSM Token"
pkcs11-tool --module $PYKCS11LIB --init-token --label test --so-pin $SOPIN
if (( $? > 0 )); then
    echo "HSM Token not initailized, failed with code $?"
    cat $LOGDIR/test39.log
    exit 1
fi


let testid=testid+1
echo "Test ${testid}: Initializing User PIN"
pkcs11-tool --module $PYKCS11LIB --login --init-pin --pin $PYKCS11PIN --so-pin $SOPIN
if (( $? > 0 )); then
    echo "User PIN not initialized, failed with code $?"
    cat $LOGDIR/test39.log
    exit 1
fi


let testid=testid+1
echo "Test ${testid}: Login to HSM"
pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --show-info 2>&1 \
    | grep 'present token' > $LOGDIR/test34.log
if (( $? > 0 )); then
    pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --show-info
    echo "Login failed"
    cat $LOGDIR/test39.log
    exit 1
fi

let testid=testid+1
echo "Test ${testid}a: create certificate in ramdisk"
rm -f /ramdisk/*
/scripts/x509_create_keys_on_disk.sh -n testcert \
     -s /C=AT/ST=Wien/L=Wien/O=TEST/OU=TEST/CN=testcert
if (( $? > 0 )); then
    echo "Creating SW-cert failed with code=$?"
    cat $LOGDIR/test39.log
    exit 1
fi

echo "Test ${testid}b: write certificate + private key to HSM"
/scripts/pkcs11_key_to_token.sh -c /ramdisk/testcert_crt.der -k /ramdisk/testcert_key.der \
    -l mdsign -n test -s $SOPIN -t $PYKCS11PIN -v
if (( $? > 0 )); then
    echo "Writing key and certificate to HSM token failed with code=$?"
    cat $LOGDIR/test39.log
    exit 1
fi


let testid=testid+1
echo "Test ${testid}: List certificate(s)"
pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --list-objects  --type cert 2>&1 \
    | grep 'Certificate Object' > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    echo "No certificate found"
    exit 1
fi


let testid=testid+1
echo "Test ${testid}: List private key(s)"
pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --list-objects  --type privkey 2>&1 \
    | grep 'Private Key Object' > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    echo "No private key found" 
    cat $LOGDIR/test39.log
    exit 1
fi

let testid=testid+1
echo "Test ${testid}: Sign test data"
if [[ $SOFTHSM ]]; then
    echo "SoftHSMv2 does not support signing"
else
    echo "foo" > /tmp/bar
    pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN  \
        --sign --input /tmp/bar --output /tmp/bar.sig > $LOGDIR/test${testid}.log 2>&1
    if (( $? > 0 )); then
        echo "Signature failed"
        cat $LOGDIR/test39.log
        exit 1
    fi
fi


let testid=testid+1
echo "Test ${testid}: Count objects using PyKCS11"

obj_count=$(/tests/pykcs11_getkey.py --pin=$PYKCS11PIN --slot=0 --lib=$PYKCS11LIB | grep -a -c '=== Object ')
if (( $obj_count != 2 )); then
    echo "Expected 2 objects in HSM token, but listed ${obj_count}"
    exit 1
fi

let testid=testid+1
echo "Test ${testid}: List objects and PKCS11-URIs with p11tool"
export GNUTLS_PIN=$PYKCS11PIN
p11tool --provider $PYKCS11LIB --list-all --login pkcs11: > $LOGDIR/test${testid}.log 2>&1
obj_count=$(grep -c ^Object $LOGDIR/test${testid}.log)
if (( $obj_count != 2 )); then
    echo "Expected 2 objects in HSM token, but listed ${obj_count}"
    exit 1
fi
