#!/usr/bin/env bash

# setup gpg and keep script running

# this is useful to start keymgmt as a permanent docker container in background

/scripts/gpg_setup.sh

sleep infinity  # keep docker container running
