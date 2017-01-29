FROM debian:jessie
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN apt-get update \
 && apt-get -y install haveged gnupg2 gnupg-agent libpth20 pinentry-curses libccid pcscd scdaemon libksba8 paperkey opensc \
 && apt-get clean \
 && mkdir ~/.gnupg

COPY install/gpg.conf /root/.gnupg/gpg.conf


