FROM intra/centos7_py36_base
LABEL maintainer="Rainer Hörbe <r2h2@hoerbe.at>"

# Key Management App

# general tools
RUN yum -y update \
 && yum -y install curl git ip lsof net-tools openssl sudo unzip wget which \
 && yum clean all

# EPEL, development tools +  X.11
#RUN yum -y groupinstall "Development Tools" \
RUN yum -y install epel-release \
 && yum -y install gcc gcc-c++ \
 && yum -y install xorg-x11-xinit xorg-x11-fonts-100dpi xterm \
 && yum clean all

# Crypto + Smart card support
RUN yum -y install openssl engine_pkcs11 p11tool pcsc-lite pcsc-scan softhsm usbutils gnutls-utils \
 && yum clean all \
 && systemctl enable pcscd.service

# Centos 7 stock OpenSC is version 0.16 with bugs and key support limited to RSA<=2048
WORKDIR /root
RUN yum -y install autoconf automake gcc gcc-c++ git libtool pcsc-lite-devel \
 && wget https://github.com/OpenSC/OpenSC/releases/download/0.19.0/opensc-0.19.0.tar.gz \
 && tar xfvz opensc-*.tar.gz \
 && cd opensc-* \
 && ./bootstrap \
 && ./configure --prefix=/usr/local --sysconfdir=/etc/opensc \
 && make \
 && make install


# Java keytool plus pkcs11 crypto provider
ENV JAVA_HOME=/etc/alternatives/jre_1.8.0_openjdk
COPY install/java_crypto/softhsm_JCE.cfg /etc/pki/java/
RUN yum -y install java-1.8.0-openjdk-devel.x86_64 \
 && ln -s /etc/pki/java/softhsm_JCE.cfg /etc/pki/java/pkcs11.cfg

# Do NOT configure JCA statically - dyn + stat yields "org.apache.xml.security.signature.XMLSignatureException: No installed provider supports this key: sun.security.pkcs11.P11Key$P11PrivateKey"
#RUN printf "\nsecurity.provider.10=sun.security.pkcs11.SunPKCS11 /etc/pki/java/pkcs11.cfg\n" \
#        >> $JAVA_HOME/lib/security/java.security

# python: pip, -devel
RUN yum -y install python36u-devel swig \
 && yum clean all
RUN pip3 install six virtualenv \
 && pip3 install pykcs11 \
 && mkdir -p /opt/venv \
 && virtualenv --system-site-packages /opt/venv/py3

# secret-key splitting utility
RUN cd /opt \
 && git clone https://github.com/schlatterbeck/secret-splitting.git \
 && cd secret-splitting \
 && source /opt/venv/py3/bin/activate \
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
COPY install/tests /tests
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