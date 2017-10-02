FROM centos:centos7
LABEL maintainer="Rainer Hörbe <r2h2@hoerbe.at>" \
      version="0.5.0" \
      didi_dir="https://raw.githubusercontent.com/identinetics/keymgmt/master/didi" \
      capabilities=''

# Caveat: home directory is not persistent -> mapped to /tmp when started from LiveCD

# Key Management App for PVZDliveCD

# general tools
RUN yum -y update \
 && yum -y install curl git ip lsof net-tools openssl sudo sysvinit-tools unzip wget which \
 && yum clean all

# EPEL, development tools +  X.11
#RUN yum -y groupinstall "Development Tools" \
RUN yum -y install epel-release \
 && yum -y install gcc gcc-c++ \
 && yum -y install xorg-x11-xinit xorg-x11-fonts-100dpi xterm \
 && yum clean all

# Crypto + Smart card support
RUN yum -y install openssl engine_pkcs11 opensc p11tool pcsc-lite pcsc-scan softhsm usbutils gnutls-utils \
 && yum clean all \
 && systemctl enable pcscd.service

# Java keytool plus pkcs11 crypto provider
ENV JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
COPY install/java_crypto/softhsm_JCE.cfg /etc/pki/java/
RUN yum -y install java-1.8.0-openjdk-devel.x86_64 \
 && ln -s /etc/pki/java/softhsm_JCE.cfg /etc/pki/java/pkcs11.cfg \
 && printf "\nsecurity.provider.10=sun.security.pkcs11.SunPKCS11 /etc/pki/java/pkcs11.cfg\n" \
        >> $JAVA_HOME/lib/security/java.security

# python: pip, -devel
RUN yum -y install python-pip python-devel \
 && yum clean all \
 && pip install --upgrade pip

RUN pip install six \
 && easy_install --upgrade six \
 && pip install importlib pykcs11>1.3.1
# using pykcs11 1.3.0 because of missing wrapper in v 1.3.1
# && pip install importlib pykcs11==1.3.0

# secret-key splitting utility
RUN mkdir -p /opt \
 && cd /opt \
 && git clone https://github.com/schlatterbeck/secret-splitting.git \
 && cd secret-splitting \
 && /usr/bin/python setup.py install

# key management stuff
RUN yum -y install gnupg2 gnupg-agent gnupg2-smime haveged libccid libksba8 libpth20 \
    pinentry-curses paperkey qrencode scdaemon zbar

# --- XMLDSig tools ---
RUN yum -y install libxslt xmlsec1 xmlsec1-openssl \
 && yum clean all

# xmlsectool (shibboleth)
ENV version='2.0.0'
RUN mkdir -p /opt && cd /opt \
 && wget "https://shibboleth.net/downloads/tools/xmlsectool/${version}/xmlsectool-${version}-bin.zip" \
 && unzip "xmlsectool-${version}-bin.zip" \
 && ln -s "xmlsectool-${version}" 'xmlsectool' \
 && rm "xmlsectool-${version}-bin.zip"
ENV XMLSECTOOL=/opt/xmlsectool/xmlsectool.sh


COPY install/scripts/* /scripts/
COPY install/tests/* /tests/
COPY install/tests/testdata/* /tests/testdata
COPY install/etc/* /etc/
RUN mkdir -p /usr/local/etc/gpg
COPY install/gpg/* /usr/local/etc/gpg/

ARG USERNAME=liveuser
ARG UID=1000
RUN groupadd --gid $UID $USERNAME \
 && useradd --gid $UID --uid $UID $USERNAME \
 && chown $USERNAME:$USERNAME /run /var/log /scripts/* \
 && chmod +x /scripts/* /tests/*

VOLUME /root /ramdisk
# need start as root to start pcscd
CMD ["/scripts/start.sh"]