#!/bin/bash


logger -p local0.info "Starting PC/SC Smartcard Service"
$sudo /usr/sbin/pcscd

#logger -p local0.info "Starting DBUS Service"
#$sudo /bin/dbus-daemon --system --nofork --nopidfile

#logger -p local0.info "Starting HAVEGE Entropy Service"
# disabled because gpg2 --sign is failing with "signing failed: Operation cancelled"
# may be useful for speeding up splitkey utility
#$sudo /usr/sbin/haveged
