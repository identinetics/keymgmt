#!/usr/bin/env bash

# take care that ssh-agent is not running, as it would conflict with gpg-agent


function add_line_if_not_found() {
    STRING_TO_ADD=$1
    FILE_TO_EDIT=$2
    mkdir -p $(dirname $FILE_TO_EDIT)
    touch $FILE_TO_EDIT
    grep -c "$STRING_TO_ADD" $FILE_TO_EDIT > /dev/null || \
        echo "$STRING_TO_ADD" >> $FILE_TO_EDIT
}


add_line_if_not_found "use-agent" ~/.gnupg/gpg.conf
add_line_if_not_found "keyserver hkp://pgp.mit.edu" ~/.gnupg/gpg.conf

# start gpg-agent
add_line_if_not_found "enable-ssh-support" ~/.gnupg/gpg-agent.conf
add_line_if_not_found "write-env-file " ~/.gnupg/gpg-agent.conf
add_line_if_not_found "default-cache-ttl 1800" ~/.gnupg/gpg-agent.conf
gpg-agent --daemon > ~.gpg-agent-info.sh # this one includes 'export'

# fetch key from card
gpg --card-edit
# fetch
# quit

gpg --list-keys

# import keys into OpenSSH
source ~/.gpg-agent-info.sh
ssh-add -L   # output of -L can be used to add kes to authorzized_keys