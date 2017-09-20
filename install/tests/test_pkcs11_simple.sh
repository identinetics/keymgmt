#!/usr/bin/env bash

main() {
    start_pcscd
    test_carddriver_setting
    opensc_list_reades_and_drivers
    show_pkcs11_info
    run_pykcs11
    # show_pkcs15_objects
    # exec bash
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


test_carddriver_setting() {
    if [[ -z "$PYKCS11LIB" ]]; then
        echo "Env variable PYKCS11LIB not set"
        exit 1
    fi
}


show_pkcs11_info() {
    [ -z "$PYKCS11PIN" ] && PYKCS11PIN='Secret.1'
    echo
    echo "=== show token info ==="
    pkcs11-tool --module $PYKCS11LIB --show-info
    echo
    echo "=== show token slots ==="
    pkcs11-tool --module $PYKCS11LIB --list-token-slots
    echo
    echo "=== show token objects ==="
    pkcs11-tool --module $PYKCS11LIB --list-objects
    echo
    echo "=== test token ==="
    pkcs11-tool --module $PYKCS11LIB --login -O --pin $PYKCS11PIN --test
}


run_pykcs11() {
    export PYKCS11LIB=$PYKCS11LIB
    python ./pykcs11_getinfo.py
}


show_pkcs15_objects() {
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
