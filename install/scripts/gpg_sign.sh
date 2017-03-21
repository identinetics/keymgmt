#!/bin/bash

[[ -z "$GPG_SIGN_OPTIONS" ]] && echo "GPG_SIGN_OPTIONS not set" && exit 1
[[ -z "$GPG_SIGNER" ]] && echo "GPG_SIGNER not set" && exit 1
gpg2 --detach-sig $GPG_SIGN_OPTIONS -a --local-user $GPG_SIGNER --output $1.sig $1

