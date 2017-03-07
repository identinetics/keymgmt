FROM centos:centos7
LABEL maintainer="Rainer Hörbe <r2h2@hoerbe.at>" \
      version="0.2.0" \
      capabilites=''

# Key Management App for PVZDliveCD

# general tools
RUN yum -y update \
 && yum -y install curl git ip lsof net-tools openssl sudo unzip wget which \
 && yum clean all

# development & admin tools
#RUN yum -y groupinstall "Development Tools" \
RUN yum -y install epel-release \
 && yum -y install curl gcc gcc-c++ net-tools \
 && yum clean all

# X.11
RUN yum -y install xorg-x11-xinit xorg-x11-fonts-100dpi xterm \
 && yum clean all

# Smart card support
RUN yum -y install opensc openssl pcsc-lite usbutils \
 && yum clean all \
 && systemctl enable pcscd.service

# key management stuff
#RUN yum -y install gnupg2 gnupg-agent haveged libccid libksba8 libpth20 \
#    pinentry-curses paperkey scdaemon

# python: pip, -devel
RUN yum -y install python-pip python-devel \
 && yum clean all \
 && pip install --upgrade pip

# using pykcs11 1.3.0 because of missing wrapper in v 1.3.1
# using easy_install solves install bug
RUN pip install six \
 && easy_install --upgrade six \
 && pip install importlib pykcs11==1.3.0

# secret-key splitting utility
RUN mkdir -p /opt \
 && cd /opt \
 && git clone https://github.com/schlatterbeck/secret-splitting.git \
 && cd secret-splitting \
 && /usr/bin/python setup.py install

ARG USERNAME=livecd
ARG UID=1000
RUN groupadd --gid $UID $USERNAME \
 && useradd --gid $UID --uid $UID $USERNAME \
 && chown $USERNAME:$USERNAME /run /var/log

USER $USERNAME