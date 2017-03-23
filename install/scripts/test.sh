#!/usr/bin/env bash

main() {
    start_pcscd
    opensc_list_reades_and_drivers
    dump_pkcs11_info
    dump_smartcard_objects
    exec bash
}


start_pcscd() {
    init_sudo
    echo
    echo "=== Starting Smartcard Service ==="
    $sudo /usr/sbin/pcscd
}


init_sudo() {
    if [ $(id -u) -ne 0 ]; then
        sudo="sudo"
    fi
}


dump_pkcs11_info() {
    echo
    echo "=== dump pkcs11 info ==="
    pkcs11-tool --module $PKCS11_CARD_DRIVER --show-info
    pkcs11-tool --module $PKCS11_CARD_DRIVER --list-slots
    pkcs11-tool --module $PKCS11_CARD_DRIVER --list-mechanisms
}


dump_smartcard_objects() {
    echo
    echo "=== dump pkcs15 info ==="
    pkcs15-tool -D
}


opensc_list_reades_and_drivers() {
    echo
    echo "=== opensc list readers and drivers ==="
    opensc-tool --list-readers
    opensc-tool --list-drivers
}

main
