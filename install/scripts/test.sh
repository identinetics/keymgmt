#!/usr/bin/env bash
set -e -o pipefail

main() {
    init_sudo
    start_pcscd
    dump_pkcs11_info
    dump_smartcard_objects
    opensc_list_reades_and_drivers
    exec bash
}


init_sudo() {
    if [ $(id -u) -ne 0 ]; then
        sudo="sudo"
    fi
}


start_pcscd() {
    echo "Starting Smartcard Service"
    $sudo /usr/sbin/pcscd
}


dump_pkcs11_info() {
    echo "dump pkcs11 info"
    export MODULE='--module /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so'
    pkcs11-tool $MODULE --show-info
    pkcs11-tool $MODULE --list-slots
    pkcs11-tool $MODULE --list-mechanisms
}


dump_smartcard_objects() {
    echo "dump pkcs15 info"
    pkcs15-tool -D
}


opensc_list_reades_and_drivers() {
    echo "opensc list readers and drivers"
    opensc-tool --list-readers
    opensc-tool --list-drivers
}

main
