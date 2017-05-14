#!/usr/bin/env bash

source /scripts/gpg_setup.sh
echo 'lore ipsum saget majstro humat kolunme zwazich loitra' > testdoc.txt
/scripts/gpg_sign.sh testdoc.txt

gpg2 --verify testdoc.txt.sig testdoc.txt