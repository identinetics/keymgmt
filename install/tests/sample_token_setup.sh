#!/usr/bin/env bash

/scripts/x509_create_keys_on_disk.sh -v \
    -n localhost \
    -s /C=AT/ST=Wien/L=Wien/O=ABCfirma/OU=IT/CN=localhost

cd /ramdisk

/scripts/pkcs11_key_to_token.sh -d -i -n testtoken -s 12345678 -t 123456 \
    -c localhost_crt.der \
    -k localhost_key.der

