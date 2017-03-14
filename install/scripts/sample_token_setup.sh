#!/usr/bin/env bash

/create_keys_on_disk.sh -v \
    -n localhost \
    -s /C=AT/ST=Wien/L=Wien/O=ABCfirma/OU=IT/CN=localhost

cd /ramdisk

/key_to_token.sh -d -i -n testtoken -s 12345678 -t 123456 \
    -c localhost_crt.pem \
    -k localhost_key_pkcs8.pem

