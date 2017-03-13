#!/usr/bin/env bash

/create_keys_on_disk.sh -v \
    -n metadataaggregator \
    -s /C=AT/ST=Wien/L=Wien/O=ABCfirma/OU=IT/CN=localhost

cd /ramdisk

/key_to_token.sh -d -i -n testtoken -s 12345678 -t 123456 \
    -c metadataaggregator_crt.pem \
    -k metadataaggregator_key_pkcs8.pem