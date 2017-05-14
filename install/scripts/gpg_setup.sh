#!/usr/bin/env bash

# import & trust key; set gpg options

main() {
    #TODO: test for GPG version - this works with gpg2 >=2.1
    set_image_signature_args
    import_pub_key
    gpg2 --card-status  # create secret key stub
    trust_pub_key
}


set_image_signature_args() {
    export GPG_SIGNER='rh@identinetics.com'
    GPG_KEYID='904F1906'
    export GPG_SIGN_OPTIONS="--default-key $GPG_KEYID"
    GPG_PUBKEY_FILE='/usr/local/etc/gpg/rhIdentineticsCom_pub.gpg'
}


import_pub_key() {
    gpg2 --import $GPG_PUBKEY_FILE
}


trust_pub_key() {
    echo -e "trust\n5\ny" > /tmp/gpg_editkey.cmd
    gpg2 --command-file /tmp/gpg_editkey.cmd --edit-key $GPG_KEYID
}


main $@

