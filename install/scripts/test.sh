#!/usr/bin/env bash

/start.sh

pkcs15-tool -D

export MODULE='--module /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so'
pkcs11-tool $MODULE --show-info
pkcs11-tool $MODULE --list-slots
pkcs11-tool $MODULE --list-mechanisms

opensc-tool --list-readers
opensc-tool --list-drivers

