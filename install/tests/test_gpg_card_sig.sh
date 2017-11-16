#!/usr/bin/env bash

source /scripts/gpg_setup.sh

cd tests/testdata

if [[ ! $JENKINS_HOME ]]; then
    /scripts/gpg_sign.sh testdoc.txt  # requires user interaction
fi

gpg2 --verify testdoc.txt.sig testdoc.txt