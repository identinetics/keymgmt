#!/bin/bash

gpg2 --detach-sig $GPG_SIGN_OPTIONS -a --local-user $GPG_SIGNER --output $1.sig $1

