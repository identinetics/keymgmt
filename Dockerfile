FROM debian:jessie
MAINTAINER r2h2 <rainer@hoerbe.at>

RUN apt-get update \
 && apt-get -y install gnupg2 gnupg-agent haveged libccid libksba8 libpth20 \
    opensc openssh-client pinentry-curses \
    paperkey pcscd scdaemon usbutils vim \
 && apt-get clean \
 && mkdir ~/.gnupg

COPY install/gpg.conf /root/.gnupg/gpg.conf
COPY install/scripts/*.sh /
RUN chmod +x /*.sh

VOLUME /root
VOLUME /var/log