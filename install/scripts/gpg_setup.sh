#!/usr/bin/env bash

# import & trust key; set gpg options

main() {
    set_image_signature_args
    gpg2 --card-status
    import_pub_key
    trust_pub_key
}


set_image_signature_args() {
    export GPG_SIGNER='rh@identinetics.com'
    export GPG_SIGN_OPTIONS='--default-key 904F1906'
}


import_pub_key() {
    gpg2 --import rhIdentineticsCom_pub.gpg 
}


trust_pub_key() {
    echo -e "trust\n5\ny" > /tmp/gpg_editkey.cmd
    gpg2 --command-file /tmp/gpg_editkey.cmd --edit-key 904F1906
}


main $@

