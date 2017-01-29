FROM debian:jessie
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN apt-get update \
 && apt-get install haveged gnupg2 gnupg-agent libpth20 pinentry-curses libccid pcscd scdaemon libksba8 paperkey opensc \
 && apt-get clean

RUN mkdir ~/.gnupg \
 && cat > ~/.gnupg/gpg.conf << EOF
no-emit-version
no-comments
keyid-format 0xlong
with-fingerprint
use-agent
personal-cipher-preferences AES256 AES192 AES CAST5
personal-digest-preferences SHA512 SHA384 SHA256 SHA224
cert-digest-algo SHA512
default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
EOF

