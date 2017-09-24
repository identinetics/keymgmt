#!/usr/bin/env bash


SCRIPT=$(basename $0)
SCRIPT=${SCRIPT%.*}
LOGDIR="/tmp/${SCRIPT%.*}"
mkdir -p $LOGDIR
echo "    Logfiles in $LOGDIR"
set +e

testid=10
printf "Test ${testid}: HSM USB device"
if [[ $SOFTHSM ]]; then
    echo " .. skipping, Soft HSM configured "
else
    lsusb | grep "$HSMUSBDEVICE" > $LOGDIR/test${testid}.log
    if (( $? != 0 )); then
        echo -e "\n  HSM USB device not found - failed HSM test"
        cat $LOGDIR/test${testid}.log
        exit 1
    else
        echo " .. OK"
    fi
fi

#=============
let testid=testid+1
printf "Test ${testid}: PKCS11 driver lib"
if [[ -z ${PYKCS11LIB+x} ]]; then
    echo " .. ERROR: PYKCS11LIB not set - failed HSM test"
    exit 1
else
    echo " .. OK"
fi


if [[ ! -e ${PYKCS11LIB} ]]; then
    echo "PYKCS11LIB not found"
    exit 1
fi


if [[ -z ${PYKCS11PIN+x} ]]; then
    echo "PYKCS11PIN not set - failed HSM test"
    exit 1
fi


#=============
let testid=testid+1
printf  "Test ${testid}: PCSCD running "
if [[ $SOFTHSM ]]; then
    echo " .. Soft HSM  - no pcscd needed"
else
    pid=$(pidof /usr/sbin/pcscd) > /dev/null
    if (( $? == 1 )); then
        (( $(id -u) == 0 )) || sudo='sudo'
        echo " .. not found; starting pcscd"
        $sudo /usr/sbin/pcscd
        sleep 1
        pid=$(pidof /usr/sbin/pcscd) > /dev/null
        if (( $? == 1 )); then
            echo " .. ERROR: pcscd process not running"
            exit 1
        fi
    else
        echo " .. OK"
    fi
fi


#=============
let testid=testid+1
printf  "Test ${testid}: HSM PKCS#11 device  "
pkcs11-tool --module $PYKCS11LIB --list-token-slots | grep "$HSMP11DEVICE" 2>&1 \
    > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    echo " .. ERROR: HSM Token not connected"
    cat $LOGDIR/test${testid}.log
    exit 1
else
    echo " .. OK"
fi


#=============
let testid=testid+1
printf  "Test ${testid}: Initializing HSM Token "
pkcs11-tool --module $PYKCS11LIB --init-token --label test --so-pin $SOPIN \
    > $LOGDIR/test${testid}.log 2>&1
if (( $? > 0 )); then
    echo " .. ERROR: HSM Token not initailized, failed with code $?"
    cat $LOGDIR/test${testid}.log
    exit 1
else
    echo " .. OK"
fi


#=============
let testid=testid+1
printf  "Test ${testid}: Initializing User PIN "
pkcs11-tool --module $PYKCS11LIB --login --init-pin --pin $PYKCS11PIN --so-pin $SOPIN \
    > $LOGDIR/test${testid}.log 2>&1
if (( $? > 0 )); then
    echo " .. ERROR: User PIN not initialized, failed with code $?"
    cat $LOGDIR/test${testid}.log
    exit 1
else
    echo " .. OK"
fi


#=============
let testid=testid+1
printf  "Test ${testid}: Login to HSM"
pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --show-info 2>&1 \
    | grep 'present token' > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --show-info
    echo " .. ERROR: Login failed"
    cat $LOGDIR/${testid}.log
    exit 1
else
    echo " .. OK"
fi

#=============
let testid=testid+1
printf  "Test ${testid}a: create SW-certificate in ramdisk"
rm -f /ramdisk/*
/scripts/x509_create_keys_on_disk.sh -n testcert \
    -s /C=AT/ST=Wien/L=Wien/O=TEST/OU=TEST/CN=testcert \
    > $LOGDIR/test${testid}.log 2>&1
if (( $? > 0 )); then
    echo " .. ERROR: Creating SW-cert failed with code=$?"
    cat $LOGDIR/test${testid}a.log
    exit 1
else
    echo " .. OK"
fi

printf  "Test ${testid}b: write certificate + private key to HSM "
/scripts/pkcs11_key_to_token.sh -c /ramdisk/testcert_crt.der -k /ramdisk/testcert_key.der \
    -l mdsign -n test -s $SOPIN -t $PYKCS11PIN> $LOGDIR/test${testid}.log 2>&1
if (( $? > 0 )); then
    echo " .. ERROR: Writing key and certificate to HSM token failed with code=$?"
    cat $LOGDIR/test${testid}b.log
    exit 1
else
    echo " .. OK"
fi


#=============
let testid=testid+1
printf  "Test ${testid}: List certificate(s)"
pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --list-objects --type cert \
    | grep 'Certificate Object' 2>&1 > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    echo " .. ERROR: No certificate found"
    exit 1
else
    echo " .. OK"
fi


#=============
let testid=testid+1
printf  "Test ${testid}: List private key(s)"
pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN --list-objects  --type privkey \
    | grep 'Private Key Object' 2>&1  > $LOGDIR/test${testid}.log
if (( $? > 0 )); then
    echo " .. ERROR: No private key found"
    cat $LOGDIR/test${testid}.log
    exit 1
else
    echo " .. OK"
fi

#=============
let testid=testid+1
printf  "Test ${testid}: Sign test data"
if [[ $SOFTHSM ]]; then
    echo " .. skipping, SoftHSMv2 does not support signing"
else
    echo "foo" > /tmp/bar
    pkcs11-tool --module $PYKCS11LIB --login --pin $PYKCS11PIN  \
        --sign --input /tmp/bar --output /tmp/bar.sig > $LOGDIR/test${testid}.log
    if (( $? > 0 )); then
        echo " .. ERROR: Signature failed"
        cat $LOGDIR/test${testid}.log
        exit 1
    else
        echo " .. OK"
    fi
fi


#=============
let testid=testid+1
printf  "Test ${testid}: Count objects using PyKCS11"

obj_count=$(/tests/pykcs11_getkey.py --pin=$PYKCS11PIN --slot=0 --lib=$PYKCS11LIB | grep -a -c '=== Object ')
if (( $obj_count != 2 )); then
    echo " .. ERROR: Expected 2 objects in HSM token, but listed ${obj_count}"
    exit 1
else
    echo " .. OK"
fi


#=============
let testid=testid+1
printf  "Test ${testid}: List objects and PKCS11-URIs with p11tool"
export GNUTLS_PIN=$PYKCS11PIN
p11tool --provider $PYKCS11LIB --list-all --login pkcs11: > $LOGDIR/test${testid}.log 2>&1
obj_count=$(grep -c ^Object $LOGDIR/test${testid}.log)
if (( $obj_count != 2 )); then
    echo " .. ERROR: Expected 2 objects in HSM token, but listed ${obj_count}"
    exit 1
else
    echo " .. OK"
fi

#=============
let testid=testid+1
echo  "Test ${testid}: List objects with Java keytool (no test criterium defined yet)"
# fit into single line:
keytool -list -storetype PKCS11 -storepass $PYKCS11PIN -providerClass sun.security.pkcs11.SunPKCS11 -providerArg $JCE_CONF -J-Djava.security.debug=sunpkcs11 || true